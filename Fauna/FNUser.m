//
//  FNUser.m
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNUser.h"
#import "FNContext.h"

@implementation FNUser

+ (NSString *)faunaClass {
  return FNUserClassName;
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

@end
