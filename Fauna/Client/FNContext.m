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
#import "FNContextConfig.h"
#import "FNFuture.h"
#import "FNError.h"
#import "FNClient.h"
#import "FNNetworkStatus.h"
#import "FNCache.h"
#import "FNSQLiteCache.h"
#import "NSString+FNStringExtensions.h"

NSString * const FNFutureScopeContextKey = @"FNContext";

static FNContext *_defaultContext;

static FNContextConfig *_defaultConfig;

static FNContextConfig *DefaultDefaultConfig() {
  static FNContextConfig *config;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    config = [FNContextConfig configWithMaxAge:60 WWANAge:60 timeout:120 fallbackOnError:NO];
  });

  return config;
}

@interface FNContext ()

@property (nonatomic, readonly) FNContextConfig *config;

@end

@implementation FNContext

#pragma mark lifecycle

- (id)initWithClient:(FNClient *)client cache:(FNCache *)cache config:(FNContextConfig *)config {
  self = [super init];
  if (self) {
    _client = client;
    _cache = cache;
    _config = config;
  }
  return self;
}

- (id)initWithClient:(FNClient *)client {
  FNContextConfig *config = [FNContext defaultConfig] ?: DefaultDefaultConfig();
  FNCache *cache = [FNSQLiteCache cacheWithName:[client getAuthHash]];
  return [self initWithClient:client cache:cache config:config];
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

#pragma mark Public methods

- (instancetype)asUser:(NSString *)userRef {
  return [[self.class alloc] initWithClient:[self.client asUser:userRef]];
}

+ (FNContext *)defaultContext {
  return _defaultContext;
}

+ (void)setDefaultContext:(FNContext *)context {
  _defaultContext = context;
}

+ (FNContextConfig *)defaultConfig {
  return _defaultConfig;
}

+ (void)setDefaultConfig:(FNContextConfig *)config {
  _defaultConfig = config;
}

+ (FNContext *)currentContext {
  return self.scopedContext ?: self.defaultContext;
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

- (void)setLogHTTPTraffic:(BOOL)log {
  self.client.logHTTPTraffic = log;
}

#pragma mark HTTP methods

+ (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self.currentOrRaise.client get:path parameters:parameters];
}

+ (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self.currentOrRaise.client post:path parameters:parameters];
}

+ (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self.currentOrRaise.client put:path parameters:parameters];
}

+ (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self.currentOrRaise.client delete:path parameters:parameters];
}


+ (FNFuture *)getResource:(NSString *)path {
  FNStatus status = [FNNetworkStatus status];
}

+ (FNFuture *)postResource:(NSString *)path parameters:(NSDictionary *)parameters {

}

+ (FNFuture *)putResource:(NSString *)path parameters:(NSDictionary *)parameters {

}

+ (FNFuture *)deleteResource:(NSString *)path {
  
}

#pragma mark Private methods

+ (FNContext *)currentOrRaise {
  FNContext *ctx = self.currentContext;
  if (!ctx) @throw FNContextNotDefined();
  return ctx;
}

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
