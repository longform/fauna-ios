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
  id INTEGER PRIMARY KEY NOT NULL, \
  data BLOB NOT NULL, \
  access_time INTEGER NOT NULL, \
  update_time INTEGER NOT NULL \
); \
CREATE TABLE IF NOT EXISTS resource_aliases ( \
  alias BLOB PRIMARY KEY NOT NULL, \
  resource_id INTEGER NOT NULL, \
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

  self = [self initWithSQLitePath:databasePath];
  if (self) {
    [self createOrUpdateTables];
  }

  return self;
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

- (FNFuture *)objectForPath:(NSString *)path after:(FNTimestamp)after {
  // TODO: Assert???
  return [self.connection withConnection:^(FNSQLiteConnection *db) {
    NSUInteger __block resID;
    NSDictionary __block *value;
    SQLITE_STATUS status;

    status = [db performQuery:@"SELECT r.update_time, r.data, r.id FROM resources AS r JOIN resource_aliases as a on r.id = a.resource_id WHERE a.alias = ?"
                      prepare:^(sqlite3_stmt *stmt){
      return sqlite3_bind_text(stmt, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
    } result:^(sqlite3_stmt *stmt) {
      FNTimestamp updateTime = sqlite3_column_int64(stmt, 0);

      if (updateTime >= after) {
        int bytes = sqlite3_column_bytes(stmt, 1);
        NSData *data = [NSData dataWithBytes:sqlite3_column_blob(stmt, 1) length:bytes];
        value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        resID = sqlite3_column_int(stmt, 2);
      }

      return SQLITE_OK;
    }];

    if (value) {
      status = [db performQuery:@"UPDATE resources SET access_time = ? WHERE id = ?" prepare:^(sqlite3_stmt *stmt) {
        SQLITE_STATUS status = sqlite3_bind_int64(stmt, 1, FNNow());

        if (status == SQLITE_OK) status = sqlite3_bind_int(stmt, 2, resID);

        return status;
      }];
    }

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
    SQLITE_STATUS status = SQLITE_OK;

    if (status == SQLITE_OK) status = [db performQuery:@"CREATE TABLE IF NOT EXISTS version (version INTEGER NOT NULL)"];

    NSInteger __block version = 0;
    if (status == SQLITE_OK) {
      status = [db performQuery:@"SELECT version from version limit 1" result:^int(sqlite3_stmt *stmt) {
        version = sqlite3_column_int(stmt, 1);
        return SQLITE_OK;
      }];
    }

    if (version != CacheVersion) {
      NSLog(@"Initializing new cache tables.");

      if (status == SQLITE_OK) status = [db performQuery:@"DELETE FROM version"];

      if (status == SQLITE_OK) status = [db performQuery:@"DROP TABLE IF EXISTS resources"];

      if (status == SQLITE_OK) status = [db performQuery:@"DROP TABLE IF EXISTS resource_aliases"];

      if (status == SQLITE_OK) status = [db performQuery:ResourcesDDL];

      if (status == SQLITE_OK) {
        status = [db performQuery:@"INSERT INTO VERSION (version) VALUES (?)" prepare:^int(sqlite3_stmt *stmt) {
          return sqlite3_bind_int(stmt, 1, CacheVersion);
        }];
      }
    }

    if(status != SQLITE_OK) {
      NSString *msg = db.lastErrorMessage ?: @"reason unknown";
      NSLog(@"FNCache: failed to create table: %@", msg);
      return @(NO);
    }
    return @(YES);
  }] get];

  return rv.boolValue;
}

@end
