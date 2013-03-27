//
// FNContext.m
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

#import "FNContext.h"
#import "FNFuture.h"
#import "FNError.h"
#import "FNClient.h"
#import "FNCache.h"
#import "FNSQLiteCache.h"
#import "NSString+FNStringExtensions.h"

NSString * const FNFutureScopeContextKey = @"FNContext";

static FNContext* _defaultContext;

@interface FNContext ()

@property (nonatomic, readonly) FNContext *parent;

@end

@implementation FNContext

# pragma mark lifecycle

- (id)initWithClient:(FNClient *)client parent:(FNContext *)parent cache:(FNCache *)cache {
  self = [super init];
  if (self) {
    _client = client;
    _parent = parent;
    _cache = nil;
  }
  return self;
}

- (id)initWithClient:(FNClient *)client {
  return [self initWithClient:client parent:nil cache:[FNSQLiteCache persistentCacheWithName:[client getAuthHash]]];
}

- (id)initWithKey:(NSString*)keyString {
  return [self initWithClient:[[FNClient alloc] initWithKey:keyString]];
}

- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef {
  return [self initWithClient:[[FNClient alloc] initWithKey:keyString asUser:userRef]];
}

- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password {
  return [self initWithClient:[[FNClient alloc] initWithPublisherEmail:email password:password]];
}

+ (instancetype)contextWithKey:(NSString *)keyString {
  return [[self alloc] initWithKey:keyString];
}

+ (instancetype)contextWithKey:(NSString *)keyString asUser:(NSString *)userRef {
  return [[self alloc] initWithKey:keyString asUser:userRef];
}

+ (instancetype)contextWithPublisherEmail:(NSString *)email password:(NSString *)password {
  return [[self alloc] initWithPublisherEmail:email password:password];
}

# pragma mark Public methods

- (instancetype)asUser:(NSString *)userRef {
  return [[self.class alloc] initWithClient:[self.client asUser:userRef]];
}

+ (FNContext *)defaultContext {
  return _defaultContext;
}

+ (void)setDefaultContext:(FNContext *)context {
  _defaultContext = context;
}

+ (FNContext *)currentContext {
  return self.scopedContext ?: self.defaultContext;
}

+ (FNContext *)currentOrRaise {
  FNContext *ctx = self.currentContext;
  if (!ctx) @throw FNContextNotDefined();
  return ctx;
}

- (id)inContext:(id (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  self.class.scopedContext = self;
  @try {
    return block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

- (void)performInContext:(void (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  self.class.scopedContext = self;
  @try {
    block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

- (id)transient:(id (^)(void))block {
  FNContext *child = [[FNContext alloc] initWithClient:self.client parent:self cache:[FNSQLiteCache volatileCache]];
  return [child inContext:block];
}

- (void)setLogHTTPTraffic:(BOOL)log {
  self.client.logHTTPTraffic = log;
}

# pragma mark Private methods

+ (FNContext *)scopedContext {
  return FNFuture.currentScope[FNFutureScopeContextKey];
}

+ (void)setScopedContext:(FNContext *)ctx {
  NSMutableDictionary *scope = FNFuture.currentScope;

  if (ctx) {
    scope[FNFutureScopeContextKey] = ctx;
  } else {
    [scope removeObjectForKey:FNFutureScopeContextKey];
  }
}

@end
