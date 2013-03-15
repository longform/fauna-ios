//
//  FNContext.m
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNContext.h"
#import "FNFuture.h"
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

- (id)inContext:(id (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  @try {
    self.class.scopedContext = self;
    return block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

- (void)performInContext:(void (^)(void))block {
  FNContext *prev = self.class.scopedContext;
  @try {
    self.class.scopedContext = self;
    block();
  } @finally {
    self.class.scopedContext = prev;
  }
}

+ (FNFuture *)get:(NSString *)path
       parameters:(NSDictionary *)parameters {
  return [[self.currentContext.client get:path
                               parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)post:(NSString *)path
        parameters:(NSDictionary *)parameters {
  return [[self.currentContext.client post:path
                                parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)put:(NSString *)path
       parameters:(NSDictionary *)parameters {
  return [[self.currentContext.client put:path
                               parameters:parameters]
          map:^(FNResponse *response) {
    return response.resource;
  }];
}

+ (FNFuture *)delete:(NSString *)path
          parameters:(NSDictionary *)parameters {
  return [[self.currentContext.client delete:path
                                  parameters:parameters]
          map:^(FNResponse *response) {
            return response.resource;
  }];
}

# pragma mark Private methods

+ (FNContext *)scopedContext {
  return FNFuture.currentScope[FNFutureScopeContextKey];
}

+ (void)setScopedContext:(FNContext *)ctx {
  NSMutableDictionary *scope = FNFuture.currentScope;

  if (ctx) {
    scope[FNFutureScopeContextKey] = scope;
  } else {
    [scope removeObjectForKey:FNFutureScopeContextKey];
  }
}

@end
