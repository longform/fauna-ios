//
//  FNContext.h
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"
#import "FNError.h"

/*!
 Fauna API Context
 */
@interface FNContext : NSObject

#pragma mark lifecycle

/*!
 Initializes the Context with the given key or user token.
 @param keyString key or user token
 */
- (id)initWithKey:(NSString *)keyString;

/*!
 Initializes the Context with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123').
 */
- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Initializes the Context with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password;

/*!
 Returns a new Context with the given key or user token.
 @param keyString key or user token
 */
+ (instancetype)contextWithKey:(NSString *)keyString;

/*!
 Returns a new Context with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123').
 */
+ (instancetype)contextWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Returns a new Context with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
+ (instancetype)contextWithPublisherEmail:(NSString *)email password:(NSString *)password;

#pragma mark user masquerading

/*!
 Returns a new Client that masquerades as a specific user. Only valid if this Client was initialized with a publisher key.
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (instancetype)asUser:(NSString *)userRef;

#pragma mark context management

/*!
 Returns the default FNContext for the Application.
 */
+ (FNContext*)defaultContext;

/*!
 Sets the default FNContext for the Application.
 */
+ (void)setDefaultContext:(FNContext *)context;

/*!
 Returns the innermost active FNContext, falling back to defaultContext if none is available.
 */
+ (FNContext *)currentContext;

/*!
 Runs a code block in the current context, returning the result of the block.
 @param block The block to be executed in the context.
 */
- (id)inContext:(id (^)(void))block;

/*!
 Runs a code block in the current context.
 @param block The block to be executed in the context.
 */
- (void)performInContext:(void (^)(void))block;

#pragma mark HTTP requests

+ (FNFuture *)get:(NSString *)path
       parameters:(NSDictionary *)parameters;

+ (FNFuture *)get:(NSString *)path;

+ (FNFuture *)post:(NSString *)path
        parameters:(NSDictionary *)parameters;

+ (FNFuture *)post:(NSString *)path;

+ (FNFuture *)put:(NSString *)path
       parameters:(NSDictionary *)parameters;

+ (FNFuture *)put:(NSString *)path;

+ (FNFuture *)delete:(NSString *)path
          parameters:(NSDictionary *)parameters;

+ (FNFuture *)delete:(NSString *)path;

@end