//
// FNUser.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
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

+ (FNFuture *)changeSelfPassword:(NSString *)password newPassword:(NSString *)newPassword confirmation:(NSString *)confirmation {
  NSDictionary *params = @{
    @"password": password,
    @"new_password": newPassword,
    @"new_password_confirmation": confirmation
  };

  return [[FNContext put:@"users/self/config/password" parameters:params] map:^id(id value) {
    return @YES;
  }];
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
