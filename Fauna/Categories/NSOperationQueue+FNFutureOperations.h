//
//  NSOperationQueue+FNFutureOperations.h
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

@interface NSOperationQueue (FNFutureOperations)

- (FNFuture *)futureOperationWithBlock:(id (^)(void))block;

@end