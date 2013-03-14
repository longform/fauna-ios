//
//  FaunaUser.h
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNResource.h"

@interface FaunaUser : FNResource

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *externalId;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic) BOOL skipEmailConfirmation;

+ (BOOL)create:(FaunaUser*)user error:(NSError**)error;

+ (BOOL)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation error:(NSError**)error;

+ (BOOL)loginWithEmail:(NSString*)email password:(NSString*)password error:(NSError**)error;

+ (BOOL)loginWithExternalId:(NSString*)externalId password:(NSString*)password error:(NSError**)error;

@end
