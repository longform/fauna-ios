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
#import "FNError.h"
#import "NSString+FNStringExtensions.h"

@implementation FNUser

+ (NSString *)faunaClass {
  return @"users";
}

+ (FNFuture *)getSelf {
  return [FNResource get:@"users/self"];
}

+ (FNFuture *)getSettings {
  return [FNResource get:@"settings/self"];
}

+ (FNFuture *)changeSelfPassword:(NSString *)password newPassword:(NSString *)newPassword confirmation:(NSString *)confirmation {
  NSDictionary *params = @{
    @"password": password,
    @"new_password": newPassword,
    @"new_password_confirmation": confirmation
  };

  return [FNContext put:@"users/self/config/password" parameters:params].done;
}

+ (FNFuture *)tokenForEmail:(NSString *)email password:(NSString *)password {
  return [[FNContext post:@"tokens"
               parameters:@{@"email": email, @"password": password}]
          map:^(NSDictionary *resource) {
    return resource[@"secret"];
  }];
}

+ (FNFuture *)tokenForConstraintWithName:(NSString *)name value:(NSString *)value password:(NSString *)password {
  return [[FNContext post:@"tokens"
               parameters:@{@"constraint": @{ name : value }, @"password": password}]
          map:^(NSDictionary *resource) {
            return resource[@"secret"];
          }];
}

+ (FNFuture *)contextForEmail:(NSString *)email password:(NSString *)password {
  return [[self tokenForEmail:email password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
}

+ (FNFuture *)contextForConstraintWithName:(NSString *)name value:(NSString *)value password:(NSString *)password {
  return [[self tokenForConstraintWithName:name value:value password:password] map:^(NSString *token) {
            return [FNContext contextWithKey:token];
          }];
}

+ (FNFuture *)isEmailAvailable:(NSString *)email {
  NSString *path = [NSString stringWithFormat:@"users/email_availability/%@", [email urlEscapedWithEncoding:NSUTF8StringEncoding]];
  return [[FNContext get:path] transform:^(FNFuture *result) {
    if (!result.isError) {
      return [FNFuture value:@NO];
    } else if (result.isError && result.error.isFNNotFound) {
      return [FNFuture value:@YES];
    } else {
      return result;
    }
  }];
}

+ (FNFuture *)isUniqueIDAvailable:(NSString *)uniqueID {
  NSString *path = [NSString stringWithFormat:@"users/unique_id_availability/%@", [uniqueID urlEscapedWithEncoding:NSUTF8StringEncoding]];
  return [[FNContext get:path] transform:^(FNFuture *result) {
    if (!result.isError) {
      return [FNFuture value:@NO];
    } else if (result.isError && result.error.isFNNotFound) {
      return [FNFuture value:@YES];
    } else {
      return result;
    }
  }];
}

- (void)setEmail:(NSString *)email {
  self.dictionary[@"email"] = email;
}

- (void)setPassword:(NSString *)password {
  self.dictionary[@"password"] = password;
}

- (FNFuture *)config {
  return [FNResource get:[self.ref stringByAppendingString:@"/config"]];
}

@end
