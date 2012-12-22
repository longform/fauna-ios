//
//  FaunaUser.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"
#import "FaunaConstants.h"

@class FaunaUser;

@interface FaunaUser : FaunaResource

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *externalId;

@property (nonatomic, strong) NSString *password;

@property (nonatomic) BOOL skipEmailConfirmation;

- (void)save:(FaunaResponseResultBlock)block;

@end
