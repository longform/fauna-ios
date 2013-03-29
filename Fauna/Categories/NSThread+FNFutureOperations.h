//
//  NSThread+FNFutureOperations.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

@class FNFuture;

@interface NSThread (FNFutureOperations)

- (FNFuture *)runBlock:(id (^)(void))block modes:(NSArray *)modes;

- (FNFuture *)runBlock:(id (^)(void))block;

@end
