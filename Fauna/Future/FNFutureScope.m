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

+ (void)restoreCurrent:(NSMutableDictionary *)saved {
  NSAssert(!self.tls[FNFutureScopeTLSKey], @"Setting Future locals over previous scope.");

  if (saved) {
    self.tls[FNFutureScopeTLSKey] = saved;
  }
}

+ (void)removeCurrent {
  [self.tls removeObjectForKey:FNFutureScopeTLSKey];
}

# pragma mark Private methods

+ (NSMutableDictionary *)tls {
  return NSThread.currentThread.threadDictionary;
}

@end
