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

@implementation FaunaContext

+ (FaunaContext*)applicationContext {
  return _defaultContext;
}

+ (void)setDefaultApplicationContext:(FaunaContext*)context {
  _defaultContext = context;
}

+ (void)run:(FaunaRunBlock)backgroundBlock results:(FaunaResultsBlock)resultsBlock {
  [[self current] run:backgroundBlock results:resultsBlock];
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

- (void)run:(FaunaRunBlock)backgroundBlock results:(FaunaResultsBlock)resultsBlock {
  
}

@end
