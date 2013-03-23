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
#import <sqlite3.h>

typedef int SQLITE_STATUS;
static int const kRefColumnOrdinal = 1;
static int const kDataColumnOrdinal = 2;
static int const kCreatedAtColumnOrdinal = 3;

@interface FNSQLiteCache () {
  sqlite3 *database;
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
  SQLITE_STATUS status = sqlite3_exec(database,
               "CREATE TABLE IF NOT EXISTS RESOURCES (REF TEXT PRIMARY KEY, DATA BLOB, CREATED_AT INTEGER)",
               NULL, NULL, NULL);
  if(status != SQLITE_OK) {
    NSLog(@"FNCache: failed to create table");
    return NO;
  }
  return YES;
}

- (void)dealloc {
  [self close];
}

- (void)close {
  SQLITE_STATUS status = sqlite3_close(database);
  if(status != SQLITE_OK) {
    NSLog(@"FNSQLiteCache: database close failed (%d): %s", status, sqlite3_errmsg(database));
  }
}

- (FNFuture*)valueForKey:(NSString *)key {
  // TODO: Assert???
  NSString *query = @"SELECT ROWID, REF, DATA FROM RESOURCES WHERE REF = ?";
  return [self withStatement:query perform:^(sqlite3_stmt* stmt) {
    SQLITE_STATUS status = sqlite3_bind_text(stmt, kRefColumnOrdinal, [key UTF8String], -1, SQLITE_TRANSIENT);
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind key to statement."}];
    }
    return (id)[[self executeNextStep:stmt] map:^(NSNumber* statusNum) {
      int status = [statusNum integerValue];
      if (status == SQLITE_ROW) {
        int bytes = sqlite3_column_bytes(stmt, kDataColumnOrdinal);
        NSData *blobData = [NSData dataWithBytes:sqlite3_column_blob(stmt, kDataColumnOrdinal) length:bytes];
        NSDictionary *data = nil;
        data = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
        return (id)data;
      }
      return [NSError errorWithDomain:@"poop" code:123 userInfo:@{}];
    }];
  }];
}

- (FNFuture *)setObject:(NSDictionary *)dict forKey:(NSString *)key {
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

    status = sqlite3_bind_int64(stmt, kCreatedAtColumnOrdinal, FNTimestampFromNSDate([NSDate date]));
    if (status != SQLITE_OK) {
      return [NSError errorWithDomain:@"FNCache" code:1 userInfo:@{@"msg":@"Unable to bind value to statement."}];
    }

    return (id)[self executeNextStep:stmt];
  }];
}

- (FNFuture*)executeNextStep:(sqlite3_stmt *)stmt {
  return [[FNFuture inBackground:^{
    int status;
    @synchronized(self) {
      status = sqlite3_step(stmt);
    };
    return @(status);
  }] flatMap:^(NSNumber* statusNum) {
    int status = [statusNum intValue];

    if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
      // TODO: Backoff
      usleep(5000);
      return [self executeNextStep:stmt];
    } else {
      return [FNFuture value:statusNum];
    }
  }];
}

- (FNFuture*)withStatement:(NSString*)sql perform:(FNFuture*(^)(sqlite3_stmt*))block {
  sqlite3_stmt *stmt;
  SQLITE_STATUS status = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
  if (status != SQLITE_OK){
    NSLog(@"FNCache: Unable to prepare statement (%d): %s", status, sqlite3_errmsg(database));
    return nil;
  }
  return [block(stmt) ensure:^() {
    id __unused x = self;
    sqlite3_finalize(stmt);
  }];
}
@end
