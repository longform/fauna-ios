//
//  FaunaUser.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaUsers.h"
#import "FaunaAFNetworking.h"

#define kPassword @"password"
#define kNewPassword @"new_password"
#define kNewPasswordConfirmation @"new_password_confirmation"

@interface FaunaUsers ()

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@property (nonatomic, strong) FaunaAFHTTPClient * userClient;

@end

@implementation FaunaUsers

- (void)create:(NSDictionary*)user callback:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = user;
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary: responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation callback:(FaunaSimpleResultBlock)block {
  NSDictionary *sendParams = @{
    kPassword : oldPassword,
    kNewPassword: newPassword,
    kNewPasswordConfirmation: confirmation
  };
  NSString * path = [NSString stringWithFormat:@"/%@/users/self/settings/password", FaunaAPIVersion];
  [self.userClient putPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    block(nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(error);
  }];
}

@end
