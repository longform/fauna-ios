//
//  FNFuture_Internal.h
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"
#import "FNValueFuture.h"
#import "FNFutureScope.h"
#import "NSOperationQueue+FNFutureOperations.h"

@interface FNMutableFuture ()

- (void)forwardCancellationsTo:(FNFuture *)other;

@end
