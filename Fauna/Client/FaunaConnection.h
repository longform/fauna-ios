//
//  FaunaConnection.h
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaunaConnection : NSObject

/*!
 Returns the version of the Fauna API the library supports.
 */
+ (NSString *)APIVersion;

/*!
 Returns the global shared connection instance.
 */
+ (FaunaConnection *)sharedConnection;

- (id)init;

@end
