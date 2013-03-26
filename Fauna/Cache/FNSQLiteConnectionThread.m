//
// FNSQLiteCache.h
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

#import "FNSQLiteConnectionThread.h"
#import <sqlite3.h>
#import "FNMutableFuture.h"
#import "FNFuture.h"

typedef int SQLITE_STATUS;

@interface FNPerformContext : NSObject
typedef id(^PerformBlock)(sqlite3*);
@property (nonatomic,readonly,strong) PerformBlock block;
@property (nonatomic,readonly,strong) FNMutableFuture* future;

- (id)initWithBlock:(PerformBlock)block future:(FNMutableFuture*)future;
@end

@implementation FNPerformContext
- (id)initWithBlock:(PerformBlock)block future:(FNMutableFuture*)future {
  if (self = [super init]) {
    _block = block;
    _future = future;
  }
  return self;
}
@end

@interface FNSQLiteConnectionThread () {
  NSPort *port;
  sqlite3 *database;
}
@end

@implementation FNSQLiteConnectionThread

- (id)initWithConnection:(sqlite3*)db {
  if (self = [super init]) {
    database = db;
  }
  return self;
}

- (void)close {
  [self cancel];
  sqlite3_close(database);
}

- (void)main {
  NSRunLoop *loop = [NSRunLoop currentRunLoop];
  port = [NSPort port];
  [loop addPort:port forMode:NSDefaultRunLoopMode];
  while (![self isCancelled] && [loop runMode:NSDefaultRunLoopMode beforeDate:[[NSDate alloc] initWithTimeIntervalSinceNow:60]]);
}

- (FNFuture*)withConnectionPerform:(id(^)(sqlite3*))block {
  if (![self isCancelled]) {
    FNMutableFuture *future = [[FNMutableFuture alloc] init];
    FNPerformContext *context = [[FNPerformContext alloc] initWithBlock:block future:future];
    [self performSelector:@selector(runBlock:) onThread:self withObject:context waitUntilDone:NO];
    return future;
  } else {
    @throw @"Thread has been canceled.";
  }
}

- (void)runBlock:(FNPerformContext*)context {
  id rv = context.block(database);
  [context.future update:rv];
}
@end