//
//  FaunaContext.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaTimelines.h"
#import "FaunaUsers.h"
#import "FaunaTokens.h"
#import "FaunaInstances.h"
#import "FaunaCommands.h"
#import "FaunaCache.h"

@interface FaunaClient : NSObject

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

/*!
 Manage Fauna Commands
 */
@property (nonatomic, strong, readonly) FaunaCommands * commands;

/*!
 Returns FaunaCache instance in use by the client.
 */
@property (nonatomic, strong, readonly) FaunaCache *cache;

@end