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

@interface FaunaCache () {
  sqlite3 *database;
}

- (BOOL)createTables;

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
  status = sqlite3_step(statement);
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
  while(sqlite3_step(statement) == SQLITE_ROW) {
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
  return YES;
}

- (void)dealloc {
  SQLITE_STATUS status = sqlite3_close(database);
  if(status != SQLITE_OK) {
    NSLog(@"FaunaCache: database closed with status %d", status);
  }
}

@end
