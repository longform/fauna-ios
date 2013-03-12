//
//  FaunaUser.m
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaUser.h"
#import "FaunaContext.h"

#define kEmailKey @"email"
#define kExternalIdKey @"external_id"
#define kNameKey @"name"
#define kPasswordKey @"password"
#define kDataKey @"data"
#define kSkipEmailConfirmationKey @"skip_email_confirmation"

@implementation FaunaUser

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

- (void)setData:(NSDictionary *)data {
  [self.resourceDictionary setValue:data forKey:kDataKey];
}

- (NSDictionary*)data {
  return [self.resourceDictionary valueForKey:kDataKey];
}

+ (BOOL)create:(FaunaUser*)user error:(NSError**)error {
  NSParameterAssert(user);
  NSDictionary * resourceDictionary = [FaunaContext.current.client createUser:user.resourceDictionary error:error];
  if(*error || !resourceDictionary) {
    return NO;
  }
  user.resourceDictionary = [[NSMutableDictionary alloc] initWithDictionary:resourceDictionary];
  return YES;
}

+ (BOOL)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation error:(NSError**)error {
  NSParameterAssert(oldPassword);
  NSParameterAssert(newPassword);
  NSParameterAssert(confirmation);
  return [FaunaContext.current.client changePassword:oldPassword newPassword:newPassword confirmation:confirmation error:error];
}

+ (BOOL)loginWithEmail:(NSString*)email password:(NSString*)password error:(NSError**)error {
  NSString* userToken = [FaunaContext.current.client createToken:@{kEmailKey: email, kPasswordKey: password} error:error];
  if(*error) {
    return NO;
  }
  FaunaContext.current.userToken = userToken;
  return YES;
}

+ (BOOL)loginWithExternalId:(NSString*)externalId password:(NSString*)password error:(NSError**)error {
  NSString* userToken = [FaunaContext.current.client createToken:@{kExternalIdKey: externalId, kPasswordKey: password} error:error];
  if(*error) {
    return NO;
  }
  FaunaContext.current.userToken = userToken;
  return YES;
}

@end
