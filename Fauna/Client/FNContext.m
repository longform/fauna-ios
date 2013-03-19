//
//  FNContext.m
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNContext.h"
#import "FNFuture.h"
#import "FNError.h"
#import "FNClient.h"
#import "NSString+FNBase64Encoding.h"

NSString * const FNFutureScopeContextKey = @"FNContext";

static FNContext* _defaultContext;

@interface FNContext ()

@property (nonatomic, readonly) FNClient *client;

@end

@implementation FNContext

# pragma mark lifecycle

- (id)initWithClient:(FNClient *)client {
  self = [super init];
  if (self) {
    _client = client;
  }
  return self;
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

+ (FNFuture *)get:(NSString *)path
       parameters:(NSDictionary *)parameters {
  return [[self.currentOrRaise.client get:path parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)get:(NSString *)path {
  return [self get:path parameters:nil];
}

+ (FNFuture *)post:(NSString *)path
        parameters:(NSDictionary *)parameters {
  return [[self.currentOrRaise.client post:path parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)post:(NSString *)path {
  return [self post:path parameters:nil];
}

+ (FNFuture *)put:(NSString *)path
       parameters:(NSDictionary *)parameters {
  return [[self.currentOrRaise.client put:path parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)put:(NSString *)path {
  return [self put:path parameters:nil];
}

+ (FNFuture *)delete:(NSString *)path
          parameters:(NSDictionary *)parameters {
  return [[self.currentOrRaise.client delete:path parameters:parameters]
          map:^(FNResponse *response) {
            return response.resource;
  }];
}

+ (FNFuture *)delete:(NSString *)path {
  return [self delete:path parameters:nil];
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
