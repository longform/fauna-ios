//
//  FaunaContext.m
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaContext.h"
#define kFaunaContextTLSKey @"FaunaContext"
#define kFaunaTokenUserKey @"FaunaContextUserToken"

static FaunaContext* _applicationContext;

static NSMutableArray* ensureContextStack() {
  NSMutableArray* stack = FaunaTLS[kFaunaContextTLSKey];
  if(stack) {
    return stack;
  }
  stack = FaunaTLS[kFaunaContextTLSKey] = [[NSMutableArray alloc] initWithCapacity:5];
  return stack;
}

static FaunaContext* pushContext(FaunaContext* context) {
  NSMutableArray* stack = ensureContextStack();
  [stack addObject:context];
  return context;
}

static FaunaContext* popContext() {
  NSMutableArray* stack = ensureContextStack();
  if(stack.count == 0) {
    return nil;
  }
  FaunaContext* context = stack.lastObject;
  [stack removeLastObject];
  return context;
}

@interface FaunaContext()
  
- (NSString*)keyStringPreferenceKey:(NSString*)key;

- (void)reloadCache;

@end

@implementation FaunaContext {
  NSOperationQueue *_queue;
}

- (id)initWithClientKeyString:(NSString*)keyString {
  if (self = [self init]) {
    self.keyString = keyString;
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    
    _client = [[FaunaClient alloc] initWithClientKeyString:keyString];
    
    // Load persisted user token
    NSString *persistedTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:[self keyStringPreferenceKey:kFaunaTokenUserKey]];
    self.userToken = persistedTokenString;
  }
  return self;
}

- (void)reloadCache {
  if(self.userToken) {
    _cache = [[FaunaCache alloc] initWithName:self.userToken];
  } else {
    _cache = [[FaunaCache alloc] initWithName:self.keyString];
  }
}

-(NSString*)keyStringPreferenceKey:(NSString*)key {
  return [NSString stringWithFormat:@"%@-%@", self.keyString, key];
}

- (void)setUserToken:(NSString *)userToken {
  _userToken = userToken;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:userToken forKey:[self keyStringPreferenceKey:kFaunaTokenUserKey]];
  [defaults synchronize];
  self.client.userToken = userToken;
  [self reloadCache];
}

+ (FaunaContext*)applicationContext {
  return _applicationContext;
}

+ (void)setApplicationContext:(FaunaContext*)context {
  _applicationContext = context;
}

+ (FaunaContext*)scopeContext {
  return ensureContextStack().lastObject;
}

+ (FaunaContext*)current {
  FaunaContext* scopeContext = [self scopeContext];
  return scopeContext ? scopeContext : [self applicationContext];
}

- (void)scoped:(FaunaBlock)block {
  pushContext(self);
  @try {
    block(block);
  }  @finally {
    popContext();
  }
}

+ (NSOperation*)background:(FaunaBackgroundBlock)backgroundBlock success:(FaunaResultsBlock)successBlock failure:(FaunaErrorBlock)failureBlock {
  return [[self current] background:backgroundBlock success:successBlock failure:failureBlock];
}

- (NSOperation*)background:(FaunaBackgroundBlock)backgroundBlock success:(FaunaResultsBlock)successBlock failure:(FaunaErrorBlock)failureBlock {
  NSParameterAssert(backgroundBlock);
  NSParameterAssert(successBlock);
  NSParameterAssert(failureBlock);
  NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock: ^{
    id result = [self wrap:^id{
      return backgroundBlock();
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
      if([result isKindOfClass:[NSError class]]) {
        failureBlock(result);
      } else {
        successBlock(result);
      }
    }];
  }];
  [_queue addOperation:op];
  return op;
}

- (id)wrap:(FaunaResultBlock)block {
  NSParameterAssert(block);
  FaunaCache* scopeCache = [FaunaCache scopeCache];
  BOOL requiresCacheScope = !scopeCache;
  if(requiresCacheScope && self.cache) {
    id __block result = nil;
    [self.cache scoped:^{
      result = block();
    }];
    return result;
  } else {
    FaunaCache * originalContextCache = scopeCache.parentContextCache;
    @try {
      scopeCache.parentContextCache = self.cache;
      return block();
    }
    @finally {
      scopeCache.parentContextCache = originalContextCache;
    }
  }
}

@end
