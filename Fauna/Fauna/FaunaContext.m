//
//  FaunaContext.m
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaContext.h"
#define kFaunaContextTLSKey @"FaunaContext"

static FaunaContext *_defaultContext;

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

@implementation FaunaContext {
  NSOperationQueue *_queue;
}

- (id)initWithClientKeyString:(NSString*)keyString {
  if (self = [self init]) {
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    
    _client = [[FaunaClient alloc] initWithClientKeyString:keyString];
  }
  return self;
}

+ (FaunaContext*)applicationContext {
  return _defaultContext;
}

+ (void)setApplicationContext:(FaunaContext*)context {
  _defaultContext = context;
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
    id result = backgroundBlock();
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

@end
