//
//  FaunaCache.m
//  Fauna
//
//  Created by Johan Hernandez on 1/18/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaCache.h"
#import <sqlite3.h>
#import "FaunaConstants.h"

#define SQLITE_STATUS int

#define kRefColumnOrdinal 1
#define kDataColumnOrdinal 2
#define kPathColumnOrdinal 3

#define kResourcesColumnOrdinal 2
#define kReferencesColumnOrdinal 3
#define kTLSCachePolicyKey @"FaunaCachePolicy"
#define kMaxRetrySeconds 10

@interface FaunaCache () {
  sqlite3 *database;
}

- (BOOL)createTables;

- (int)stepQuery:(sqlite3_stmt *)stmt;

- (NSDictionary*)loadResourceCore:(NSString*)identifier queryByRef:(BOOL)queryByRef;

@end

@implementation FaunaCache

- (id)initWithName:(NSString*)name {
  if(self = [super init]) {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex:0];
    NSString *databasePath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-cache.db", name]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // must create tables if database file doesn't exist yet
    BOOL mustCreateTables = ![fileManager fileExistsAtPath:databasePath];
    
    SQLITE_STATUS status = sqlite3_open([databasePath fileSystemRepresentation], &database);
    if(status != SQLITE_OK) {
      [[NSException exceptionWithName:@"FaunaCacheDatabaseException"
                               reason:[NSString stringWithFormat:@"Failed to open database with status %i",status] userInfo:nil
        ] raise];
    }
    if(mustCreateTables) {
      if(![self createTables]) {
        return nil;
      }
    }
        
  }
  return self;
}

- (id)initTransient {
  if(self = [super init]) {
    SQLITE_STATUS status = sqlite3_open(":memory:", &database);
    if(status != SQLITE_OK) {
      [[NSException exceptionWithName:@"FaunaCacheDatabaseException"
                               reason:[NSString stringWithFormat:@"Failed to open in memory database with status %i",status] userInfo:nil
        ] raise];
      return nil;
    }
    if(![self createTables]) {
      return nil;
    }
  }
  return self;
}

- (int)stepQuery:(sqlite3_stmt *)stmt
{
  int ret;
  // Try direct first
  ret = sqlite3_step(stmt);
  if (ret != SQLITE_BUSY && ret != SQLITE_LOCKED) return ret;
  
  int max_seconds = kMaxRetrySeconds;
  while (max_seconds > 0) {
    NSLog(@"[FaunaCache] SQLITE BUSY - retrying...");
    sleep(1);
    max_seconds--;
    ret = sqlite3_step(stmt);
    if (ret != SQLITE_BUSY && ret != SQLITE_LOCKED) return ret;
  }
  [[NSException exceptionWithName:@"FaunaCache"
                           reason:@"SQLITE BUSY for too long" userInfo:nil
    ] raise];
  return ret;
}

- (void)saveResource:(NSDictionary*)resource withPath:(NSString*)path {
  NSParameterAssert(resource);
  NSParameterAssert(path);
  NSString *ref = resource[@"ref"];
  NSAssert(ref, @"resource ref is invalid");
  
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  status = sqlite3_prepare_v2(database, "INSERT OR REPLACE INTO RESOURCES (REF, DATA, PATH) VALUES (?, ?, ?)", -1, &statement, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: Failed to prepare insert statement with status %d", status);
    return;
  }
  status = sqlite3_bind_text(statement, kRefColumnOrdinal, [ref UTF8String], -1, SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind ref column with status %d", status);
    return;
  }
  
  NSData * data = [NSKeyedArchiver archivedDataWithRootObject:resource];
  status = sqlite3_bind_blob(statement, kDataColumnOrdinal, [data bytes], [data length], SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind blob data column with status %d", status);
    return;
  }
  status = sqlite3_bind_text(statement, kPathColumnOrdinal, [path UTF8String], -1, SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind path column with status %d", status);
    return;
  }
  status = [self stepQuery:statement];
  if(status != SQLITE_DONE) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to insert resource in cache with status %d", status);
    return;
  }
  sqlite3_finalize(statement);
}

- (void)saveResource:(NSDictionary*)resource {
  [self saveResource:resource withPath:@""];
}

- (NSDictionary*)loadResourceCore:(NSString*)identifier queryByRef:(BOOL)queryByRef {
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  NSString * query = [NSString stringWithFormat:@"SELECT ROWID, REF, DATA, PATH FROM RESOURCES WHERE %@ = ?", (queryByRef ? @"REF" : @"PATH")];
  status = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: Failed to prepare select statement with status %d", status);
    return nil;
  }
  status = sqlite3_bind_text(statement, kRefColumnOrdinal, [identifier UTF8String], -1, SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind ref column with status %d", status);
    return nil;
  }
  NSDictionary * data = nil;
  while([self stepQuery:statement] == SQLITE_ROW) {
    int bytes = sqlite3_column_bytes(statement, kDataColumnOrdinal);
    NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(statement, kDataColumnOrdinal) length:bytes];
    data = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
  }
  sqlite3_finalize(statement);
  return data;
}

- (NSDictionary*)loadResource:(NSString*)ref {
  NSParameterAssert(ref);
  return [self loadResourceCore:ref queryByRef:YES];
}

- (BOOL)createTables {
  // Creates the Resources table.
  SQLITE_STATUS status = sqlite3_exec(database,
               "CREATE TABLE IF NOT EXISTS RESOURCES (REF TEXT PRIMARY KEY, DATA BLOB, PATH TEXT)",
               NULL, NULL, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: failed to create table");
    return NO;
  }
  return YES;
}

- (void)dealloc {
  SQLITE_STATUS status = sqlite3_close(database);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: database closed with status %d", status);
  }
}

static id readBlob(sqlite3_stmt *statement, int ordinal) {
  int bytes = sqlite3_column_bytes(statement, ordinal);
  NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(statement, ordinal) length:bytes];
  return [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
}

- (NSDictionary*)loadResourceWithPath:(NSString*)path {
  return [self loadResourceCore:path queryByRef:NO];
}

+ (BOOL)shouldIgnoreCache {
  return [FaunaTLS[kTLSCachePolicyKey] boolValue];
}

+ (void)ignoreCache:(FaunaCacheScopeBlock)block {
  NSParameterAssert(block);
  FaunaTLS[kTLSCachePolicyKey] = [NSNumber numberWithBool:YES];
  block();
  FaunaTLS[kTLSCachePolicyKey] = [NSNumber numberWithBool:NO];
}

@end
