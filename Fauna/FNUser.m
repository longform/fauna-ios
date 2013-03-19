//
//  FNUser.m
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"
#import "FNUser.h"
#import "FNContext.h"

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

+ (FNFuture *)tokenForEmail:(NSString *)email password:(NSString *)password {
  return [[FNContext post:@"tokens"
               parameters:@{@"email": email, @"password": password}]
          map:^(NSDictionary *resource) {
    return resource[@"token"];
  }];
}

+ (FNFuture *)tokenForUniqueID:(NSString *)uniqueID password:(NSString *)password {
  return [[FNContext post:@"tokens"
               parameters:@{@"unique_id": uniqueID, @"password": password}]
          map:^(NSDictionary *resource) {
            return resource[@"token"];
          }];
}

+ (FNFuture *)contextForEmail:(NSString *)email password:(NSString *)password {
  return [[self tokenForEmail:email password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
}

+ (FNFuture *)contextForUniqueID:(NSString *)uniqueID password:(NSString *)password {
  return [[self tokenForUniqueID:uniqueID password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
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
