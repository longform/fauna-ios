//
//  FaunaSecurityToken.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResource.h"
#import "FaunaConstants.h"

/*!
 Fauna User Token.
 
 See https://fauna.org/API#access_model-tokens
 */
@interface FaunaToken : FaunaResource

/*!
 (token) The Actual Token.
 */
@property (nonatomic, strong) NSString *token;

/*!
 (user) The User Reference Id.
 */
@property (nonatomic, strong) NSString *user;

/*!
 Creates a Token with the given Email and Password
 @param email User's Email
 @param password User's Password
 */
+ (void)tokenWithEmail:(NSString*)email password:(NSString*)password block:(FaunaResponseResultBlock)block;

/*!
 Creates a Token with the given Email and Password
 @param email User's Email
 @param context Context to use in the call
 @param password User's Password
 */
+ (void)tokenWithEmail:(NSString*)email password:(NSString*)password context:(FaunaContext*)context block:(FaunaResponseResultBlock)block;

/*!
 Creates a Token with the given Email and Password
 @param externalId User's External Id
 @param password User's Password
 */
+ (void)tokenWithExternalId:(NSString*)externalId password:(NSString*)password block:(FaunaResponseResultBlock)block;

/*!
 Creates a Token with the given Email and Password
 @param externalId User's External Id
 @param context Context to use in the call
 @param password User's Password
 */
+ (void)tokenWithExternalId:(NSString*)externalId password:(NSString*)password context:(FaunaContext*)context block:(FaunaResponseResultBlock)block;

@end
