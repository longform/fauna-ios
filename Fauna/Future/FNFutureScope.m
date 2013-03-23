//
// FNFutureScope.m
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

#import "FNFutureScope.h"

NSString * const FNFutureScopeTLSKey = @"org.fauna.FutureScope";

@implementation FNFutureScope

# pragma mark Class methods

+ (NSMutableDictionary *)currentScope {
  NSMutableDictionary *scope = self.tls[FNFutureScopeTLSKey];
  if (!scope) {
    scope = [NSMutableDictionary dictionaryWithCapacity:1];
    self.tls[FNFutureScopeTLSKey] = scope;
  }

  return scope;
}

+ (NSMutableDictionary *)saveCurrent {
  NSMutableDictionary *scope = self.tls[FNFutureScopeTLSKey];

  if (scope && scope.count > 0) {
    return [NSMutableDictionary dictionaryWithDictionary:scope];
  } else {
    return nil;
  }
}

+ (void)inScope:(NSMutableDictionary *)scope perform:(void (^)(void))block {
  NSMutableDictionary *prev = self.tls[FNFutureScopeTLSKey];
  self.currentScope = scope;

  @try {
    block();
  } @finally {
    self.currentScope = prev;
  }
}

# pragma mark Private methods

+ (void)setCurrentScope:(NSMutableDictionary *)scope {
  if (scope) {
    self.tls[FNFutureScopeTLSKey] = scope;
  } else {
    [self.tls removeObjectForKey:FNFutureScopeTLSKey];
  }
}

+ (NSMutableDictionary *)tls {
  return NSThread.currentThread.threadDictionary;
}

@end
