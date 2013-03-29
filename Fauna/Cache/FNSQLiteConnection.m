//
//  FNSQLiteConnection.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <sqlite3.h>
#import "FNError.h"
#import "FNSQLiteConnection.h"

typedef int SQLITE_STATUS;

static NSError * PrepareStatementError() {
  return [NSError errorWithDomain:@"org.fauna.FNCache" code:1 userInfo:@{@"msg":@"Unable to prepare statement."}];
}

static NSError * BindValueError() {
  return [NSError errorWithDomain:@"FNCache" code:2 userInfo:@{@"msg":@"Unable to bind value to statement."}];
}

static NSError * CacheInsertError() {
  return [NSError errorWithDomain:@"org.fauna.FNCache" code:3 userInfo:@{@"msg": @"Cache insert failed"}];
}

@interface FNSQLiteConnection ()

@property (nonatomic, readonly) sqlite3 *database;

@end

@implementation FNSQLiteConnection

- (id)initWithSQLitePath:(NSString *)path {
  if(self = [super init]) {
    SQLITE_STATUS status = sqlite3_open([path fileSystemRepresentation], &_database);
    if(status != SQLITE_OK) {
      const char *errMsg;
      if (_database) {
        errMsg = sqlite3_errmsg(_database);
      } else {
        errMsg = "Database handle could not be allocated.";
      }

      NSLog(@"FNSQLite: Unable to open database %@ (%i): %s", path, status, errMsg);
      return nil;
    }

    _isClosed = NO;
  }

  return self;
}

- (void)dealloc {
  [self close];
}

#pragma mark Public methods

- (NSError *)withTransaction:(BOOL(^)(void))block {
  [self performQuery:@"BEGIN TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];

  if (block()) {
    [self performQuery:@"COMMIT TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];
    return nil;
  } else {
    [self performQuery:@"ROLLBACK TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];
    return [NSError errorWithDomain:@"failed" code:1231 userInfo:@{}];
  }
}

static SQLITE_STATUS step(sqlite3_stmt *stmt) {
  int status = sqlite3_step(stmt);

  if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
    // TODO: Backoff
    // [self performSelector:@selector(executeNextStep:) withObject:(__bridge id)stmt afterDelay:.005];
    usleep(5000);
    return step(stmt);
  } else {
    return status;
  }
}

- (NSError *)performQuery:(NSString *)sql prepare:(int (^)(sqlite3_stmt *))prepareBlock result:(int (^)(sqlite3_stmt *))resultBlock {
  sqlite3_stmt *stmt;
  SQLITE_STATUS status;

  status = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);
  if (status != SQLITE_OK) {
    return PrepareStatementError();
  }

  if (SQLITE_OK != prepareBlock(stmt)) {
    sqlite3_finalize(stmt);
    return PrepareStatementError();
  }

  status = step(stmt);

  while (status == SQLITE_ROW) {
    if (SQLITE_OK != resultBlock(stmt)) {
      sqlite3_finalize(stmt);
      return BindValueError();
    }
    status = step(stmt);
  }

  switch (sqlite3_finalize(stmt)) {
    case SQLITE_OK:
      return nil;
    case SQLITE_DONE:
      return nil;
    default:
      return [NSError errorWithDomain:@"blak" code:1231 userInfo:@{}];
  }
}

- (NSError *)performQuery:(NSString *)sql prepare:(int (^)(sqlite3_stmt *))prepareBlock {
  return [self performQuery:sql prepare:prepareBlock result:^int(sqlite3_stmt __unused *stmt){ return SQLITE_OK; }];
}

- (void)close {
  _isClosed = YES;
  sqlite3_close(self.database);
}

@end
