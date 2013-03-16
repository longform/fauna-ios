//
//  FNUser.m
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNUser.h"

@implementation FNUser

+ (NSString *)faunaClass {
  return FNUserClassName;
}

+ (FNFuture *)getSelf {
  return [FNResource get:@"users/self"];
}

+ (FNFuture *)getSelfConfig {
  return [FNResource get:@"users/self/config"];
}

- (NSString *)email {
  return self.dictionary[FNEmailJSONKey];
}

- (void)setEmail:(NSString *)email {
  self.dictionary[FNEmailJSONKey] = email;
}

- (NSString *)password {
  return self.dictionary[FNPasswordJSONKey];
}

- (void)setPassword:(NSString *)password {
  self.dictionary[FNPasswordJSONKey] = password;
}

- (FNFuture *)config {
  return [FNResource get:[self.ref stringByAppendingString:@"/config"]];
}

+ (BOOL)allowNewResources {
  return YES;
}

@end
