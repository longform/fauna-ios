//
//  FNMutableFuture.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

@interface FNMutableFuture : FNFuture

@property (readonly) id value;
@property (readonly) NSError *error;
@property (readonly) BOOL isCompleted;

- (void)update:(id) value;

- (BOOL)updateIfEmpty:(id) value;

- (void)updateError:(NSError *)error;

- (BOOL)updateErrorIfEmpty:(NSError *)error;

@end
