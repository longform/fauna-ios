//
//  FaunaUser.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaUser.h"
#define kEmailKey @"email"
#define kExternalIdKey @"external_id"
#define kNameKey @"name"
#define kPasswordKey @"password"
#define kSkipEmailConfirmationKey @"skip_email_confirmation"

@implementation FaunaUser

- (void)save:(FaunaResponseResultBlock)block {
  NSMutableDictionary *sendParams = [self resourceDictionary];
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  [self.context.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:self.context response:responseObject andRootResourceClass:[FaunaUser class]];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)setEmail:(NSString *)email {
  [self.resourceDictionary setValue:email forKey:kEmailKey];
}

- (NSString*)email {
  return [self.resourceDictionary valueForKey:kEmailKey];
}

- (void)setExternalId:(NSString *)externalId {
  [self.resourceDictionary setValue:externalId forKey:kExternalIdKey];
}

- (NSString*)externalId {
  return [self.resourceDictionary valueForKey:kExternalIdKey];
}

- (void)setPassword:(NSString *)password {
  [self.resourceDictionary setValue:password forKey:kPasswordKey];
}

- (NSString*)password {
  return [self.resourceDictionary valueForKey:kPasswordKey];
}

- (void)setSkipEmailConfirmation:(BOOL)skipEmailConfirmation {
  [self.resourceDictionary setValue:[NSNumber numberWithBool:skipEmailConfirmation] forKey:kSkipEmailConfirmationKey];
}

- (BOOL)skipEmailConfirmation {
  NSNumber * n = [self.resourceDictionary valueForKey:kSkipEmailConfirmationKey];
  return [n boolValue];
}

- (void)setName:(NSString *)name {
  [self.resourceDictionary setValue:name forKey:kNameKey];
}

- (NSString*)name {
  return [self.resourceDictionary valueForKey:kNameKey];
}

@end
