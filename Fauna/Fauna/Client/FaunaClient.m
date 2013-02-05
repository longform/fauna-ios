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
#define kCacheName @"client"
#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"
#define kPassword @"password"
#define kNewPassword @"new_password"
#define kNewPasswordConfirmation @"new_password_confirmation"

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

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

@end

@implementation FaunaClient

- (id)init {
  self = [super init];
  if(self) {
    _cache = [[FaunaCache alloc] initWithName:kCacheName];
    _keyClient = [FaunaClient createHTTPClient];
    _userClient = [FaunaClient createHTTPClient];
    
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

#pragma mark - Instances

- (void)createInstance:(NSDictionary*)instance callback:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = instance;
  NSString * path = [NSString stringWithFormat:@"/%@/instances", FaunaAPIVersion];
  [_userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error creating instance: %@", error);
    block(nil, error);
  }];
}

- (void)destroyInstance:(NSString*)ref callback:(FaunaSimpleResultBlock)block {
  NSAssert(ref, @"ref is required");
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  [_userClient deletePath:path parameters:nil success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    block(nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error creating instance: %@", error);
    block(error);
  }];
}

- (void)updateInstance:(NSString*)ref changes:(NSDictionary*)changes callback:(FaunaResponseResultBlock)block {
  NSAssert(ref, @"ref is required");
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  
  NSDictionary *sendParams = changes;
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  [_userClient putPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error updating instance: %@", error);
    block(nil, error);
  }];
}

- (void)instanceDetails:(NSString*)ref callback:(FaunaResponseResultBlock)block {
  NSAssert(ref, @"ref is required");
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  [_userClient getPath:path parameters:nil success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error querying instance details: %@", error);
    block(nil, error);
  }];
}

#pragma mark - Timelines


- (void)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference callback:
(FaunaResponseResultBlock)block {
  NSAssert(instanceReference, @"instanceReference is required");
  NSAssert(timelineReference, @"timelineReference is required");
  NSAssert(block, @"block is required");
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [_userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block {
  NSAssert(instanceReference, @"instanceReference is required");
  NSAssert(timelineReference, @"timelineReference is required");
  NSAssert(block, @"block is required");
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [_userClient deleteBodyPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:nil callback:block];
}

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block {
  NSMutableDictionary *sendParams = [[NSMutableDictionary alloc] initWithCapacity:3];
  if(count) {
    [sendParams setObject:count forKey:kCountKey];
  }
  if(before) {
    [sendParams setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:kBeforeKey];
  }
  if(after) {
    [sendParams setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:kAfterKey];
  }
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  NSString * responsePath = [FaunaResponse requestPathFromPath:path andMethod:@"GET"];
  if(![FaunaCache shouldIgnoreCache]) {
    // if response is cached, return it.
    FaunaResponse * response = [_cache loadResponse:responsePath];
    if(response) {
      block(response, nil);
      return;
    }
  }
  
  [_userClient getPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject cached:NO requestPath:responsePath];
    [_cache saveResponse:response];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    // if there is an error, return from cache if current policy allow it.
    if(![FaunaCache shouldIgnoreCache] && error.shouldRespondFromCache) {
      FaunaResponse *response = [_cache loadResponse:responsePath];
      if(response) {
        block(response, nil);
        return;
      }
    }
    block(nil, error);
  }];
}

- (void)pageFromTimeline:(NSString *)timelineReference after:(NSDate *)after callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:nil before:nil after:after callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference after:(NSDate *)after withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:after callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference before:(NSDate *)before callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:nil before:before after:nil callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference before:(NSDate *)before withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:before after:nil callback:block];
}


- (void)createUser:(NSDictionary*)user callback:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = user;
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  [_keyClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary: responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation callback:(FaunaSimpleResultBlock)block {
  NSDictionary *sendParams = @{
                               kPassword : oldPassword,
                               kNewPassword: newPassword,
                               kNewPasswordConfirmation: confirmation
                               };
  NSString * path = [NSString stringWithFormat:@"/%@/users/self/settings/password", FaunaAPIVersion];
  [self.userClient putPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    block(nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(error);
  }];
}

- (void)createToken:(NSDictionary*)credentials block:(FaunaResponseResultBlock)block; {
  NSDictionary *sendParams = credentials;
  NSString * path = [NSString stringWithFormat:@"/%@/tokens", FaunaAPIVersion];
  [_keyClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block {
  NSAssert(commandName, @"commandName is required");
  NSAssert(block, @"callback is required");
  NSDictionary *sendParams = params;
  NSString * path = [NSString stringWithFormat:@"/%@/commands/%@", FaunaAPIVersion, commandName];
  [_userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
