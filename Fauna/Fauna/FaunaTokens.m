//
//  FaunaSecurityToken.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaTokens.h"
#import "Fauna.h"
#define kTokenKey @"token"
#define kUserKey @"user"
#define kPasswordKey @"password"
#define kEmailKey @"email"
#define kExternalIdKey @"external_id"
#import "FaunaAFHTTPClient.h"

@interface FaunaTokens ()

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@end

@implementation FaunaTokens

- (void)create:(NSDictionary*)credentials block:(FaunaResponseResultBlock)block; {
  NSDictionary *sendParams = credentials;
  NSString * path = [NSString stringWithFormat:@"/%@/tokens", FaunaAPIVersion];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
