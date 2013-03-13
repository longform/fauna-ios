//
//  FaunaConnection.h
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const FaunaAPIBaseURL;
FOUNDATION_EXPORT NSString * const FaunaAPIVersion;

@interface FaunaConnection : NSObject

/*!
 Returns the global shared connection instance.
 */
+ (FaunaConnection *)sharedConnection;

@end
