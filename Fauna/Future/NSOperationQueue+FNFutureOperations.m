//
//  NSOperationQueue+FNFutureOperations.m
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSOperationQueue+FNFutureOperations.h"
#import "FNFuture_Internal.h"

@implementation NSOperationQueue (FNFutureOperations)

- (FNFuture *)futureOperationWithBlock:(id (^)(void))block {
  FNMutableFuture *res = [FNMutableFuture new];
  NSMutableDictionary *scope = [FNFutureScope saveCurrent];

  [self addOperationWithBlock:^{
    [FNFutureScope restoreCurrent:scope];
    id rv = res.isCancelled ? FaunaOperationCancelled() : block();

    if (rv == nil) {
      [NSException raise:@"Invalid future value." format:@"Result of future operation cannot be nil."];
    }

    if ([rv isKindOfClass:[NSError class]]) {
      [res updateError:rv];
    } else {
      [res update:rv];
    }
    [FNFutureScope removeCurrent];
  }];

  return res;
}

@end
