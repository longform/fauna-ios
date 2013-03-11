//
//  FNValueFuture.h
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

@interface FNValueFuture : FNFuture

@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) NSError *error;

- (BOOL)isCompleted;

- initWithValue:(id) value;

- initWithError:(NSError *)error;

@end
