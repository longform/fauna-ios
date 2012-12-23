//
//  FaunaSecurityToken.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaToken.h"
#import "Fauna.h"
#define kTokenKey @"token"
#define kUserKey @"user"
#define kPasswordKey @"password"
#define kEmailKey @"email"
#define kExternalIdKey @"external_id"

@implementation FaunaToken

- (void)setToken:(NSString *)token {
  [self.resourceDictionary setValue:token forKey:kTokenKey];
}

- (NSString*)token {
  return [self.resourceDictionary valueForKey:kTokenKey];
}

- (void)setUser:(NSString *)user {
  [self.resourceDictionary setValue:user forKey:kUserKey];
}

- (NSString*)user {
  return [self.resourceDictionary valueForKey:kUserKey];
}

+ (void)tokenWithEmail:(NSString*)email password:(NSString*)password block:(FaunaResponseResultBlock)block {
  return [self tokenWithEmail:email password:password context:[Fauna current] block:block];
}

+ (void)tokenWithEmail:(NSString *)email password:(NSString *)password context:(FaunaContext *)context block:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = @{kPasswordKey : password, kEmailKey: email};
  NSString * path = [NSString stringWithFormat:@"/%@/tokens", FaunaAPIVersion];
  [context.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:context response:responseObject andRootResourceClass:[FaunaToken class]];
    
    FaunaToken * token = (FaunaToken*)response.resource;
    context.userToken = token;
    
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

+ (void)tokenWithExternalId:(NSString*)externalId password:(NSString*)password block:(FaunaResponseResultBlock)block {
  return [self tokenWithExternalId:externalId password:password context:[Fauna current] block:block];
}

+ (void)tokenWithExternalId:(NSString*)externalId password:(NSString*)password context:(FaunaContext*)context block:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = @{kPasswordKey : password, kExternalIdKey:externalId};
  NSString * path = [NSString stringWithFormat:@"/%@/tokens", FaunaAPIVersion];
  [context.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:context response:responseObject andRootResourceClass:[FaunaToken class]];
    
    FaunaToken * token = (FaunaToken*)response.resource;
    context.userToken = token;
    
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}
@end
