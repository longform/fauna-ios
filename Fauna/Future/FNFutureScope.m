//
//  FNFutureScope.m
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
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
