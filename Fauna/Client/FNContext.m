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

@property (nonatomic, readonly) FNClient *client;
@property (nonatomic, readonly) FNContext *parent;
@property (nonatomic, readonly) FNCache *cache;

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

+ (FNFuture *)get:(NSString *)path
       parameters:(NSDictionary *)parameters
      rawResponse:(BOOL)rawResponse {
    FNContext *context = self.currentOrRaise;
    
    return [[context.client get:path parameters:parameters] flatMap:^(FNResponse *res){
        return [[context cacheResource:res.resource references:res.references] map_:^ id {
            if (rawResponse) {
                return res;
            }
            else {
                return res.resource;
            }
        }];
    }];
}


+ (FNFuture *)get:(NSString *)path
       parameters:(NSDictionary *)parameters {
    return [self get:path parameters:parameters rawResponse:NO];
}

+ (FNFuture *)get:(NSString *)path {
  return [self get:path parameters:nil];
}

+ (FNFuture *)post:(NSString *)path
        parameters:(NSDictionary *)parameters {
  FNContext* context = self.currentOrRaise;

  return [[context.client post:path parameters:parameters] flatMap:^(FNResponse *res) {
    return [[context cacheResource:res.resource references:res.references] map_:^{
      return res.resource;
    }];
  }];
}

+ (FNFuture *)post:(NSString *)path {
  return [self post:path parameters:nil];
}

+ (FNFuture *)put:(NSString *)path
       parameters:(NSDictionary *)parameters {
  FNContext *context = self.currentOrRaise;

  return [[context.client put:path parameters:parameters] flatMap:^(FNResponse *res) {
    return [[context cacheResource:res.resource references:res.references] map_:^{
      return res.resource;
    }];
  }];
}

+ (FNFuture *)put:(NSString *)path {
  return [self put:path parameters:nil];
}

+ (FNFuture *)delete:(NSString *)path
          parameters:(NSDictionary *)parameters {
  FNContext *context = self.currentOrRaise;

  return [[context.client delete:path parameters:parameters] flatMap:^(FNResponse *res) {
    return [[context cacheResource:@{@"ref": path, @"deleted": @YES} references:@{}] map_:^{
      return @{};
    }];
  }];
}

+ (FNFuture *)delete:(NSString *)path {
  return [self delete:path parameters:nil];
}

- (void)setLogHTTPTraffic:(BOOL)log {
  self.client.logHTTPTraffic = log;
}

#pragma equality

- (BOOL)isEquivalentToContext:(FNContext *)context {
  return self == context || (context && [self.client isEqualToClient:context.client]);
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

# pragma mark Private cache methods

- (FNFuture *)cachedResourceForRef:(NSString *)ref {
  return [self.cache valueForKey:ref];
}

- (FNFuture *)cacheResource:(NSDictionary *)resource references:(NSDictionary *)references {
  if (!self.cache) return [FNFuture value:nil];

  NSMutableArray *futures = [[NSMutableArray alloc] initWithCapacity:(references.count + 2)];

  if (resource && resource[@"ref"]) {
    [futures addObject:[self.cache setObject:resource forKey:resource[@"ref"]]];
  }

  [references enumerateKeysAndObjectsUsingBlock:^(NSString *ref, NSDictionary *resource, BOOL *stop) {
    [futures addObject:[self.cache setObject:resource forKey:ref]];
  }];

  if (self.parent) {
    [futures addObject:[self.parent cacheResource:resource references:references]];
  }

  return FNFutureJoin(futures);
}

@end
