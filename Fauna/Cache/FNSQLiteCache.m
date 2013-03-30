//
// FNSQLiteCache.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import "FNSQLiteCache.h"
#import "FNFuture.h"
#import "FNResource.h"
#import "FNSQLiteConnectionThread.h"
#import "FNSQLiteConnection.h"
#import <sqlite3.h>

typedef int SQLITE_STATUS;

static NSInteger const CacheVersion = 1;

static NSString * const ResourcesDDL = @"\
CREATE TABLE IF NOT EXISTS resources ( \
  id INTEGER PRIMARY KEY NOT NULL \
  data BLOB NOT NULL \
  access_time INTEGER NOT NULL \
  update_time INTEGER NOT NULL \
); \
CREATE TABLE IF NOT EXISTS resource_aliases ( \
  alias BLOB PRIMARY KEY NOT NULL \
  resource_id INTEGER NOT NULL \
  is_derived INTEGER NOT NULL \
); \
CREATE INDEX IF NOT EXISTS by_resource_id on resource_aliases (resource_id ASC)";

@interface FNSQLiteCache ()

@property (nonatomic, readonly) FNSQLiteConnectionThread *connection;

@end

@implementation FNSQLiteCache

#pragma mark lifecycle

- (id)initWithSQLitePath:(NSString *)path {
  if(self = [super init]) {
    _connection = [[FNSQLiteConnectionThread alloc] initWithSQLitePath:path];
  }
  return self;
}

- (id)initWithName:(NSString *)name {
  NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *documentFolderPath = [searchPaths objectAtIndex:0];
  NSString *databasePath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-cache.db", name]];
  NSFileManager *fileManager = [NSFileManager defaultManager];

  // must create tables if database file doesn't exist yet
  BOOL mustCreateTables = ![fileManager fileExistsAtPath:databasePath];
  FNSQLiteCache *rv = [self initWithSQLitePath:databasePath];
  if (mustCreateTables && ![rv createTables]) {
    return nil;
  }
  return rv;
}

- (void)dealloc {
  [self close];
}

#pragma mark Class methods

+ (id)cacheWithName:(NSString*)name {
  return [[FNSQLiteCache alloc] initWithName:name];
}

#pragma mark Public methods

- (void)close {
  [self.connection close];
}

- (FNFuture *)objectForPath:(NSString *)path {
  // TODO: Assert???
  return [self.connection withConnection:^(FNSQLiteConnection *db) {
    NSDictionary __block *value;
    SQLITE_STATUS status;

    status = [db performQuery:@"SELECT ROWID, REF, DATA, CREATED_AT, FROM RESOURCES WHERE REF = ?" prepare:^(sqlite3_stmt *stmt){
      return sqlite3_bind_text(stmt, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
    } result:^(sqlite3_stmt *stmt) {
      int bytes = sqlite3_column_bytes(stmt, 2);
      NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 2) length:bytes];
      value = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
      return SQLITE_OK;
    }];

    return status == SQLITE_OK ? value : CacheReadError();
  }];
}

- (FNFuture *)setObject:(NSDictionary *)value extraPaths:(NSArray *)paths timestamp:(FNTimestamp)timestamp {
  // TOOD: Assert?
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];

  return [self.connection withConnection:^id(FNSQLiteConnection *db) {
    SQLITE_STATUS status;

    status = [db performQuery:@"INSERT OR ABORT INTO RESOURCES (REF, DATA, CREATED_AT) VALUES (?, ?, ?)" prepare:^(sqlite3_stmt *stmt) {
      SQLITE_STATUS status = sqlite3_bind_text(stmt, 1, [paths[0] UTF8String], -1, SQLITE_TRANSIENT);
    
      if (status == SQLITE_OK) {
        status = sqlite3_bind_blob(stmt, 2, [data bytes], [data length], SQLITE_TRANSIENT);
      }

      if (status == SQLITE_OK) {
        status = sqlite3_bind_int64(stmt, 3, timestamp);
      }

      return status;
    }];

    if (status == SQLITE_OK) {
      return nil;
    } else if (status == SQLITE_CONSTRAINT) {

      status = [db performQuery:@"UPDATE RESOURCES SET DATA = ?, CREATED_AT = ? WHERE REF = ? AND CREATED_AT < ?" prepare:^(sqlite3_stmt *stmt) {
        SQLITE_STATUS status = sqlite3_bind_blob(stmt, 1, [data bytes], [data length], SQLITE_TRANSIENT);

        if (status == SQLITE_OK) {
          status = sqlite3_bind_int64(stmt, 2, timestamp);
        }

        if (status == SQLITE_OK) {
          status = sqlite3_bind_text(stmt, 3, [paths[0] UTF8String], -1, SQLITE_TRANSIENT);
        }

        if (status == SQLITE_OK) {
          status = sqlite3_bind_int64(stmt, 4, timestamp);
        }

        return status;
      }];

      if (status == SQLITE_OK) {
        return nil;
      }
    }

    return CacheWriteError();
  }];
}

#pragma mark Private methods

- (BOOL)createOrUpdateTables {
  // Creates the Resources table.
  NSNumber *rv = [[self.connection withConnection:^id(FNSQLiteConnection *db) {
    SQLITE_STATUS status;
    NSInteger __block version = 0;

    [db performQuery:@"CREATE TABLE IF NOT EXISTS version (version INTEGER NOT NULL)" prepare:^(sqlite3_stmt *stmt) { return SQLITE_OK; }];

    [db performQuery:@"SELECT version from version limit 1" prepare:^int(sqlite3_stmt *stmt) {
      return SQLITE_OK;
    } result:^int(sqlite3_stmt *stmt) {
      version = sqlite3_column_int(stmt, 1);
      return SQLITE_OK;
    }];

    if (version != CacheVersion) {
      [db performQuery:@"BEGIN" prepare:^int(sqlite3_stmt *stmt) { return SQLITE_OK; }];
      [db performQuery:@"COMMIT" prepare:^int(sqlite3_stmt *stmt) { return SQLITE_OK; }];

    }

    status = [db performQuery:@"CREATE TABLE IF NOT EXISTS 'resources' ('ref' TEXT PRIMARY KEY, 'data' BLOB, 'timestamp' INT" prepare:^(sqlite3_stmt *stmt) {
      return SQLITE_OK;
    }];

    if(status != SQLITE_OK) {
      NSLog(@"FNCache: failed to create table");
      return @(NO);
    }
    return @(YES);
  }] get];

  return rv.boolValue;
}

@end
