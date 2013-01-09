//
//  FaunaContext.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaAFNetworking.h"
#import "FaunaTimelines.h"
#import "FaunaUsers.h"
#import "FaunaTokens.h"
#import "FaunaInstances.h"

@interface FaunaContext : NSObject

- (id)init;

/*!
 Initializes this context with a FaunaClientKey instance.
 @param keyString Client key string. Required.
 */
- (id)initWithClientKeyString:(NSString *)keyString;

/*!
 User Token currently associated with this context.
 */
@property (nonatomic, strong) NSString *userToken;

/*!
 Returns the HTTP Client enabled with Client Key.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *keyClient;

/*!
 Returns the HTTP Client enabled with the current User Token.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *userClient;

/*!
 Manage Fauna Timelines
 */
@property (nonatomic, strong, readonly) FaunaTimelines * timelines;

/*!
 Manage Fauna Users
 */
@property (nonatomic, strong, readonly) FaunaUsers * users;

/*!
 Manage Fauna Tokens
 */
@property (nonatomic, strong, readonly) FaunaTokens * tokens;

/*!
 Manage Fauna Instances
 */
@property (nonatomic, strong, readonly) FaunaInstances * instances;

@end