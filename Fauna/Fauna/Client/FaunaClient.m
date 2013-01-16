//
//  FaunaContext.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaClient.h"
#import "FaunaAFNetworking.h"
#define kFaunaTokenUserKey @"FaunaContextUserToken"

@interface FaunaClient ()

+ (FaunaAFHTTPClient*)createHTTPClient;

/*!
 Returns the HTTP Client enabled with Client Key.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *keyClient;

/*!
 Returns the HTTP Client enabled with the current User Token.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *userClient;

@end

@implementation FaunaClient

- (id)init {
  self = [super init];
  if(self) {
    _keyClient = [FaunaClient createHTTPClient];
    _userClient = [FaunaClient createHTTPClient];
    
    // Load persisted user token
    NSString *persistedTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kFaunaTokenUserKey];
    self.userToken = persistedTokenString;
    
    _timelines = [[FaunaTimelines alloc] init];
    [_timelines performSelector:@selector(setClient:) withObject:_userClient];
    
    _users = [[FaunaUsers alloc] init];
    [_users performSelector:@selector(setClient:) withObject:_keyClient];
    [_users performSelector:@selector(setUserClient:) withObject:_userClient]; // also needed to change the password
    
    _tokens = [[FaunaTokens alloc] init];
    [_tokens performSelector:@selector(setClient:) withObject:_keyClient];
    
    _instances = [[FaunaInstances alloc] init];
    [_instances performSelector:@selector(setClient:) withObject:_userClient];
    
    _commands = [[FaunaCommands alloc] init];
    [_commands performSelector:@selector(setClient:) withObject:_userClient];
    
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

- (id)initWithClientKeyString:(NSString *)keyString {
  NSAssert(keyString, @"keyString instance must be provided");
  self = [self init];
  if(self) {
    if(keyString) {
      // set authorization header
      [self.keyClient setAuthorizationHeaderWithUsername:keyString password:nil];
    }
  }
  return self;
}

- (void)setUserToken:(NSString *)userToken {
  _userToken = userToken;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:userToken forKey:kFaunaTokenUserKey];
  [defaults synchronize];
  [self.userClient setAuthorizationHeaderWithUsername:userToken password:nil];
}

@end
