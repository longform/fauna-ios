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

- (BOOL)withTransaction:(BOOL(^)(void))block {
  [self performQuery:@"BEGIN TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];

  if (block()) {
    [self performQuery:@"COMMIT TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];
    return YES;
  } else {
    [self performQuery:@"ROLLBACK TRANSACTION" prepare:^int(sqlite3_stmt __unused *stmt) { return SQLITE_OK; }];
    return NO;
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

- (int)performQuery:(NSString *)sql prepare:(int(^)(sqlite3_stmt *stmt))prepareBlock result:(int(^)(sqlite3_stmt *stmt))resultBlock {
  sqlite3_stmt *stmt;
  SQLITE_STATUS status;

  status = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);
  if (status != SQLITE_OK) {
    return status;
  }

  if (SQLITE_OK != prepareBlock(stmt)) {
    return sqlite3_finalize(stmt);
  }

  status = step(stmt);

  while (status == SQLITE_ROW) {
    if (SQLITE_OK != resultBlock(stmt)) {
      return sqlite3_finalize(stmt);
    }
    status = step(stmt);
  }

  status = sqlite3_finalize(stmt);

  if (status == SQLITE_OK || status == SQLITE_DONE) {
    return SQLITE_OK;
  } else {
    return status;
  }
}

- (SQLITE_STATUS)performQuery:(NSString *)sql prepare:(int (^)(sqlite3_stmt *))prepareBlock {
  return [self performQuery:sql prepare:prepareBlock result:^int(sqlite3_stmt __unused *stmt){ return SQLITE_OK; }];
}

- (void)close {
  _isClosed = YES;
  sqlite3_close(self.database);
}

@end
