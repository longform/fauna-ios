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
static int const kRefColumnOrdinal = 1;
static int const kDataColumnOrdinal = 2;
static int const kCreatedAtColumnOrdinal = 3;

@interface FNSQLiteCache () {
  FNSQLiteConnectionThread *connection;
}
@end

@implementation FNSQLiteCache

+ (id)persistentCacheWithName:(NSString*)name {
  return [[FNSQLiteCache alloc] initPersistentWithName:name];
}

+ (id)volatileCache {
  return [[FNSQLiteCache alloc] initInMemory];
}

- (id)initWithFilename:(NSString*)name {
  if(self = [super init]) {
    sqlite3 *database;
    SQLITE_STATUS status = sqlite3_open([name fileSystemRepresentation], &database);
    if(status != SQLITE_OK) {
      const char *errMsg;
      if (database) {
        errMsg = sqlite3_errmsg(database);
      } else {
        errMsg = "Database handle could not be allocated.";
      }

      NSLog(@"FNSQLite: Unable to open database %s (%i): %s", [name UTF8String], status, errMsg);
      return nil;
    }

    connection = [[FNSQLiteConnectionThread alloc] initWithConnection:database];
    [connection start];
  }
  return self;
}

- (id)initPersistentWithName:(NSString*) name {
  NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *documentFolderPath = [searchPaths objectAtIndex:0];
  NSString *databasePath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-cache.db", name]];
  NSFileManager *fileManager = [NSFileManager defaultManager];

  // must create tables if database file doesn't exist yet
  BOOL mustCreateTables = ![fileManager fileExistsAtPath:databasePath];
  FNSQLiteCache *rv = [self initWithFilename:databasePath];
  if (mustCreateTables && ![rv createTables]) {
    return nil;
  }
  return rv;
}

- (id)initInMemory {
  FNSQLiteCache *rv = [self initWithFilename:@":memory:"];
  if (![rv createTables]) {
    return nil;
  }
  return rv;
}


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

- (void)dealloc {
  [self close];
}

- (void)close {
  [connection close];
}

- (FNFuture*)valueForKey:(NSString *)key {
  // TODO: Assert???
  NSString *query = @"SELECT ROWID, REF, DATA, CREATED_AT FROM RESOURCES WHERE REF = ?";
  return [self withStatement:query perform:^(sqlite3_stmt* stmt) {
    SQLITE_STATUS status = sqlite3_bind_text(stmt, kRefColumnOrdinal, [key UTF8String], -1, SQLITE_TRANSIENT);
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind key to statement."}];
    }
    status = [self executeNextStep:stmt];
    if (status == SQLITE_ROW) {
      int bytes = sqlite3_column_bytes(stmt, kDataColumnOrdinal);
      NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(stmt, kDataColumnOrdinal) length:bytes];
      NSDictionary *data = nil;
      data = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
      return (id)data;
    } else if (status == SQLITE_DONE) {
      return (id)nil;
    } else {
      return [NSError errorWithDomain:@"poop" code:123 userInfo:@{}];
    }
  }];
}

- (FNFuture *)setObject:(NSDictionary *)dict forKey:(NSString *)key at:(FNTimestamp)timestamp {
  // TOOD: Assert?
  return [self withStatement:@"INSERT OR REPLACE INTO RESOURCES (REF, DATA, CREATED_AT) VALUES (?, ?, ?)" perform:^(sqlite3_stmt* stmt) {
    SQLITE_STATUS status = sqlite3_bind_text(stmt, kRefColumnOrdinal, [key UTF8String], -1, SQLITE_TRANSIENT);
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind key to statement."}];
    }

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    status = sqlite3_bind_blob(stmt, kDataColumnOrdinal, [data bytes], [data length], SQLITE_TRANSIENT);
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind value to statement."}];
    }

    status = sqlite3_bind_int64(stmt, kCreatedAtColumnOrdinal, timestamp);
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind value to statement."}];
    }

    return (id)@([self executeNextStep:stmt]);
  }];
}

- (FNFuture *)updateIfNewer:(NSDictionary *)dict forKey:(NSString *)key date:(FNTimestamp)timestamp {
  return [self withStatement:@"UPDATE RESOURCES SET DATA = ?, CREATED_AT = ? WHERE REF = ? AND CREATED_AT < ?" perform:^(sqlite3_stmt* stmt) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    SQLITE_STATUS status = sqlite3_bind_blob(stmt, 1, [data bytes], [data length], SQLITE_TRANSIENT);
    if (status != SQLITE_OK) {
      // explode
    }

    status = sqlite3_bind_int64(stmt, 2, timestamp);
    if (status != SQLITE_OK) {
      // explode
    }

   status = sqlite3_bind_text(stmt, 3, [key UTF8String], -1, SQLITE_TRANSIENT);
   if (status != SQLITE_OK) {
     // explode
   }

   status = sqlite3_bind_int64(stmt, 4, timestamp);
   if (status != SQLITE_OK) {
     // explode
   }

   return (id)@([self executeNextStep:stmt]);
  }];
}

- (SQLITE_STATUS)executeNextStep:(sqlite3_stmt *)stmt {
  int status;
  status = sqlite3_step(stmt);
  if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
    // TODO: Backoff
    usleep(5000);
    return [self executeNextStep:stmt];
  } else {
    return status;
  }
}

- (FNFuture*)withStatement:(NSString*)sql perform:(id(^)(sqlite3_stmt*))block {
  return [connection withConnectionPerform:^(sqlite3 *database) {
    sqlite3_stmt *stmt;
    SQLITE_STATUS status = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
    if (status != SQLITE_OK) {
      NSLog(@"FNCache: Unable to prepare statement (%d): %s", status, sqlite3_errmsg(database));
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind value to statement."}];
    }
    id rv = block(stmt);
    sqlite3_finalize(stmt);
    return rv;
  }];
}
@end
