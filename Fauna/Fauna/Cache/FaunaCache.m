//
//  FaunaCache.m
//  Fauna
//
//  Created by Johan Hernandez on 1/18/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaCache.h"
#import <sqlite3.h>

#define SQLITE_STATUS int

#define kRefColumnOrdinal 1
#define kDataColumnOrdinal 2

#define kPathColumnOrdinal 1
#define kResourcesColumnOrdinal 2
#define kReferencesColumnOrdinal 3
#define kTLSCachePolicyKey @"FaunaCachePolicy"
#define TLS [[NSThread currentThread] threadDictionary]
#define kMaxRetrySeconds 10

@interface FaunaCache () {
  sqlite3 *database;
}

- (BOOL)createTables;

- (int)stepQuery:(sqlite3_stmt *)stmt;

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
      NSLog(@"FaunaCache: Failed to open database with status %d", status);
      return nil;
    }
    if(mustCreateTables) {
      if(![self createTables]) {
        return nil;
      }
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

- (void)saveResource:(NSDictionary*)resource {
  NSParameterAssert(resource);
  NSString *ref = resource[@"ref"];
  NSAssert(ref, @"resource ref is invalid");
  
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  status = sqlite3_prepare_v2(database, "INSERT OR REPLACE INTO RESOURCES (REF, DATA) VALUES (?, ?)", -1, &statement, NULL);
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
    NSLog(@"FaunaCache: Failed to bind blobk data column with status %d", status);
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

- (NSDictionary*)loadResource:(NSString*)ref {
  NSParameterAssert(ref);
  
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  status = sqlite3_prepare_v2(database, "SELECT ROWID, REF, DATA FROM RESOURCES WHERE REF = ?", -1, &statement, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: Failed to prepare insert statement with status %d", status);
    return nil;
  }
  status = sqlite3_bind_text(statement, kRefColumnOrdinal, [ref UTF8String], -1, SQLITE_TRANSIENT);
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

- (BOOL)createTables {
  // Creates the Resources table.
  SQLITE_STATUS status = sqlite3_exec(database,
               "CREATE TABLE IF NOT EXISTS RESOURCES (REF TEXT PRIMARY KEY, DATA BLOB)",
               NULL, NULL, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: failed to create table");
    return NO;
  }
  status = sqlite3_exec(database,
                        "CREATE TABLE IF NOT EXISTS RESPONSES (PATH TEXT PRIMARY KEY, REFS BLOB, RESS BLOB)",
                        NULL, NULL, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: failed to create table: %@", [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
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

- (void)saveResponse:(FaunaResponse*)response {
  NSParameterAssert(response);
  
  // save references data separately
  for (NSMutableDictionary *resource in response.references.allValues) {
    [self saveResource:resource];
  }
  NSMutableArray * resourcesRef = [[NSMutableArray alloc] initWithCapacity:response.resources.count];
  
  // save resources data separately
  for (NSMutableDictionary *resource in response.resources) {
    [self saveResource:resource];
    [resourcesRef addObject:resource[@"ref"]];
  }
  
  // only store ref strings of the references, we hydrate them later
  NSArray *references = response.references.allKeys;
  
  NSString *requestPath = response.requestPath;
  
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  
  status = sqlite3_prepare_v2(database, "INSERT OR REPLACE INTO RESPONSES (PATH, REFS, RESS) VALUES (?, ?, ?)", -1, &statement, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: Failed to prepare insert statement with status %d: %@", status, [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
    return;
  }
  
  status = sqlite3_bind_text(statement, kPathColumnOrdinal, [requestPath UTF8String], -1, SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind ref column with status %d", status);
    return;
  }
  
  NSData * referencesData = [NSKeyedArchiver archivedDataWithRootObject:references];
  status = sqlite3_bind_blob(statement, kReferencesColumnOrdinal, [referencesData bytes], [referencesData length], SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind references blob data column with status %d", status);
    return;
  }
  
  NSData * resourcesData = [NSKeyedArchiver archivedDataWithRootObject:resourcesRef];
  status = sqlite3_bind_blob(statement, kResourcesColumnOrdinal, [resourcesData bytes], [resourcesData length], SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind resources blob data column with status %d", status);
    return;
  }
  
  status = [self stepQuery:statement];
  if(status != SQLITE_DONE) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to insert response in cache with status %d", status);
    return;
  }
  sqlite3_finalize(statement);
}

static id readBlob(sqlite3_stmt *statement, int ordinal) {
  int bytes = sqlite3_column_bytes(statement, ordinal);
  NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(statement, ordinal) length:bytes];
  return [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
}

- (FaunaResponse*)loadResponse:(NSString*)responsePath {
  NSParameterAssert(responsePath);
  SQLITE_STATUS status;
  sqlite3_stmt *statement;
  status = sqlite3_prepare_v2(database, "SELECT ROWID, PATH, REFS, RESS FROM RESPONSES WHERE PATH = ?", -1, &statement, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: Failed to prepare insert statement with status %d", status);
    return nil;
  }
  status = sqlite3_bind_text(statement, kPathColumnOrdinal, [responsePath UTF8String], -1, SQLITE_TRANSIENT);
  if(status != SQLITE_OK) {
    sqlite3_finalize(statement);
    NSLog(@"FaunaCache: Failed to bind path column with status %d", status);
    return nil;
  }
  FaunaResponse * response = nil;
  NSArray * referencesList = nil;
  NSArray * resourcesList = nil;
  NSString * cachedResponsePath = nil;
  while([self stepQuery:statement] == SQLITE_ROW) {
    cachedResponsePath = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, kPathColumnOrdinal)];
    referencesList = readBlob(statement, kReferencesColumnOrdinal);
    resourcesList = readBlob(statement, kResourcesColumnOrdinal);
  }
  sqlite3_finalize(statement);
  if(!cachedResponsePath) {
    return nil;
  }
  
  // hydrate resources
  NSMutableArray * resources = [[NSMutableArray alloc] initWithCapacity:resourcesList.count];
  for (NSString* ref in resourcesList) {
    NSDictionary * res = [self loadResource:ref];
    [resources addObject:res];
  }
  
  // hydrate references
  NSMutableDictionary * references = [[NSMutableDictionary alloc] initWithCapacity:referencesList.count];
  for (NSString* ref in referencesList) {
    NSDictionary * refResource = [self loadResource:ref];
    references[ref] = refResource;
  }
  
  response = [FaunaResponse responseWithDictionary:@{@"resources" : resources, @"references": references} cached:YES requestPath:cachedResponsePath];
  return response;
}

+ (BOOL)shouldIgnoreCache {
  return [TLS[kTLSCachePolicyKey] boolValue];
}

+ (void)ignoreCache:(FaunaCacheScopeBlock)block {
  NSParameterAssert(block);
  TLS[kTLSCachePolicyKey] = [NSNumber numberWithBool:YES];
  block();
  TLS[kTLSCachePolicyKey] = [NSNumber numberWithBool:NO];
}

@end
