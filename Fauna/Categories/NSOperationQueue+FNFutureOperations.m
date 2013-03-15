//
//  NSOperationQueue+FNFutureOperations.m
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSOperationQueue+FNFutureOperations.h"
#import "FNMutableFuture.h"
#import "FNError.h"

@implementation NSOperationQueue (FNFutureOperations)

- (FNFuture *)futureOperationWithBlock:(id (^)(void))block {
  FNMutableFuture *res = [FNMutableFuture new];
  NSMutableDictionary *scope = [FNFutureScope saveCurrent];

  [self addOperationWithBlock:^{
    @try {
      [FNFutureScope restoreCurrent:scope];
      id rv = res.isCancelled ? FNOperationCancelled() : block();

      if (rv == nil) @throw FNInvalidFutureValue(@"Result of future operation cannot be nil.");

      if ([rv isKindOfClass:[NSError class]]) {
        [res updateError:rv];
      } else {
        [res update:rv];
      }
    } @finally {
      [FNFutureScope removeCurrent];
    }
  }];

  return res;
}

@end
