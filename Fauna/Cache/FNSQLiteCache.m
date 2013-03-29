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
#import <sqlite3.h>

typedef int SQLITE_STATUS;

@interface FNSQLiteCache () {
  @property (nonatomic, readonly) FNSQLiteConnectionThread *connection;
}
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

- (FNFuture *)valueForKey:(NSString *)key {
  // TODO: Assert???
  return [self.connection withConnection:^(FNSQLiteConnection *db) {
    NSDictionary __block *value;
    NSError __block *err;

    SQLITE_STATUS status = withStatement(database, "SELECT ROWID, REF, DATA, CREATED_AT FROM RESOURCES WHERE REF = ?", &err, ^(sqlite3_stmt* stmt) {
      SQLITE_STATUS status = sqlite3_bind_text(stmt, kRefColumnOrdinal, [key UTF8String], -1, SQLITE_TRANSIENT);
      if (status != SQLITE_OK) {
        err = BindValueError();
      }

      return status;
    }, ^(sqlite3_stmt *stmt){
      int bytes = sqlite3_column_bytes(stmt, kDataColumnOrdinal);
      NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(stmt, kDataColumnOrdinal) length:bytes];
      value = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
      return SQLITE_OK;
    });

    return status == SQLITE_OK ? value : err;
  }];
}

- (FNFuture *)addObjectToCache:(NSDictionary *)dict forKey:(NSString *)key at:(FNTimestamp)timestamp {
  // TOOD: Assert?
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];

  return [connection withConnectionPerform:^id(sqlite3* database) {
    NSError __block *err;
    SQLITE_STATUS status;

    status = withStatement(database, "INSERT OR ABORT INTO RESOURCES (REF, DATA, CREATED_AT) VALUES (?, ?, ?)", &err, ^(sqlite3_stmt* stmt) {
      SQLITE_STATUS status = SQLITE_OK;

      if (status == SQLITE_OK) {
        status = sqlite3_bind_text(stmt, 0, [key UTF8String], -1, SQLITE_TRANSIENT);
      }

      if (status == SQLITE_OK) {
        status = sqlite3_bind_blob(stmt, kDataColumnOrdinal, [data bytes], [data length], SQLITE_TRANSIENT);
      }

      if (status == SQLITE_OK) {
        status = sqlite3_bind_int64(stmt, kCreatedAtColumnOrdinal, timestamp);
      }

      if (status != SQLITE_OK) {
        err = BindValueError();
      }

      return status;
    }, ^(sqlite3_stmt __unused *stmt){ return SQLITE_OK; });

    if (status == SQLITE_OK) {
      return nil;
    } else if (status == SQLITE_CONSTRAINT) {
      status = withStatement(database, "UPDATE RESOURCES SET DATA = ?, CREATED_AT = ? WHERE REF = ? AND CREATED_AT < ?", &err, ^(sqlite3_stmt* stmt) {
        SQLITE_STATUS status = sqlite3_bind_blob(stmt, 1, [data bytes], [data length], SQLITE_TRANSIENT);

        if (status == SQLITE_OK) {
          status = sqlite3_bind_int64(stmt, 2, timestamp);
        }

        if (status == SQLITE_OK) {
          status = sqlite3_bind_text(stmt, 3, [key UTF8String], -1, SQLITE_TRANSIENT);
        }

        if (status == SQLITE_OK) {
          status = sqlite3_bind_int64(stmt, 4, timestamp);
        }

        if (status != SQLITE_OK) {
          err = BindValueError();
        }

        return status;
      }, ^(sqlite3_stmt __unused *stmt){ return SQLITE_OK; });

      return status == SQLITE_OK ? nil : err;
    } else {
      return err ?: CacheInsertError();
    }
  }];
}

#pragma mark Private methods

- (BOOL)createTables {
  // Creates the Resources table.
  return [[connection withConnectionPerform:^(sqlite3* database) {
    SQLITE_STATUS status = sqlite3_exec(database,
                 "CREATE TABLE IF NOT EXISTS RESOURCES (REF TEXT PRIMARY KEY, DATA BLOB, CREATED_AT INTEGER)",
                 NULL, NULL, NULL);
    if(status != SQLITE_OK) {
      NSLog(@"FNCache: failed to create table");
      return @(NO);
    }
    return @(YES);
  }] get];
}

@end
