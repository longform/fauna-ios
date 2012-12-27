//
//  FaunaContext.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaContext.h"
#import "FaunaClientKey.h"
#import "FaunaPublisherKey.h"
#import "FaunaAFNetworking.h"
#define kFaunaTokenUserKey @"FaunaContextUserToken"

@interface FaunaContext (Internal)

+ (FaunaAFHTTPClient*)createHTTPClient;

@end

@implementation FaunaContext

- (id)init {
  self = [super init];
  if(self) {
    _keyClient = [FaunaContext createHTTPClient];
    _userClient = [FaunaContext createHTTPClient];
    
    // Load persisted user token
    NSString *persistedTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kFaunaTokenUserKey];
    self.userToken = persistedTokenString;
  }
  return self;
}

+ (FaunaAFHTTPClient*)createHTTPClient {
  FaunaAFHTTPClient *client = [[FaunaAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://rest.fauna.org"]];
  [client setDefaultHeader:@"Accept" value:@"application/json"];
  [client registerHTTPOperationClass:[FaunaAFJSONRequestOperation class]];
  client.stringEncoding = NSUnicodeStringEncoding;
  client.parameterEncoding = FaunaAFJSONParameterEncoding;
  return client;
}

- (id)initWithKey:(FaunaKey *)key {
  NSAssert(key, @"Key instance must be provided");
  self = [self init];
  if(self) {
    self.key = key;
    if(key) {
      // set authorization header
      [self.keyClient setAuthorizationHeaderWithUsername:self.key.keyString password:nil];
    }
  }
  return self;
}

- (id)initWithPublisherKey:(NSString*)keyString {
  return [self initWithKey:[FaunaPublisherKey keyFromKeyString:keyString]];
}

- (id)initWithClientKey:(NSString*)keyString {
  return [self initWithKey:[FaunaClientKey keyFromKeyString:keyString]];
}

- (void)setUserToken:(NSString *)userToken {
  _userToken = userToken;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:userToken forKey:kFaunaTokenUserKey];
  [defaults synchronize];
  [self.userClient setAuthorizationHeaderWithUsername:userToken password:nil];
}

@end
