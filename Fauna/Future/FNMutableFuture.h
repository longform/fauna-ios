//
//  FNMutableFuture.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

@interface FNMutableFuture : FNFuture

/*!
 Complete the future with a successful result.
 */
- (void)update:(id)value;

/*!
 Complete the future with a failure result.
 */
- (BOOL)updateIfEmpty:(id)value;

/*!
 Complete the future with a successful result if it has not been completed already.
 */
- (void)updateError:(NSError *)error;

/*!
 Complete the future with a failure result if it has not been completed already.
 */
- (BOOL)updateErrorIfEmpty:(NSError *)error;

@end
