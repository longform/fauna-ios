//
//  FaunaContext.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaAFNetworking.h"

@class FaunaUserToken;
@class FaunaClientKey;
@class FaunaPublisherKey;
@class FaunaKey;

@interface FaunaContext : NSObject

- (id)init;

/** @name API Key */

/*!
 API Key currently associated with this context. Known instances are FaunaPublisherKey and FaunaClientKey.
 */
@property (nonatomic, strong) FaunaKey *key;

/*!
 Initializes this context with a key.
 @param key instance to use. Use FaunaPublisherKey or FaunaClientKey instances. Required.
 */
- (id)initWithKey:(FaunaKey*)key;

/*!
 Initializes this context with a FaunaPublisherKey instance.
 @param publisher key string. Required.
 */
- (id)initWithPublisherKey:(NSString*)keyString;

/*!
 Initializes this context with a FaunaClientKey instance.
 @param publisher key string. Required.
 */
- (id)initWithClientKey:(NSString*)keyString;

/*!
 User Token currently associated with this context.
 
 See FaunaUserToken.
 */
@property (nonatomic, strong) FaunaUserToken *userToken;

/*!
 Returns the HTTP Client related to this Context.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *client;

@end