//
//  FNUser.h
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"

@interface FNUser : FNResource

/*!
 Retrieve the current user, if applicable to the current context.
 */
+ (FNFuture *)getSelf;

/*!
 Retrieve the current user's configuration resource, if applicable to the current context.
 */
+ (FNFuture *)getSelfConfig;

/*!
 (email) the user's email. Set on a new user in order to create with an email address.
 */
@property (nonatomic) NSString *email;

/*!
 (password) the user's password. Set on a new user in order to create with a password.
 */
@property (nonatomic) NSString *password;

/*!
 Retrieve the user's configuration.
 */
- (FNFuture *)config;

@end

@interface FNUser (StandardFields)

/*!
 (uniqueID) The resource's unique id if present, or nil.
 */
@property (nonatomic) NSString *uniqueID;

/*!
 (data) The custom data dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *data;

/*!
 (references) The custom references dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *references;

@end
