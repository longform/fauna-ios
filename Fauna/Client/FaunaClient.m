//
//  FaunaContext.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaClient.h"
#import "FaunaAFNetworking.h"
#import "FaunaAFJSONUtilities.h"

#define kCacheName @"client"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"
#define kPassword @"password"
#define kNewPassword @"new_password"
#define kNewPasswordConfirmation @"new_password_confirmation"
#define kFaunaTokenUserKey @"FaunaContextUserToken"

extern NSString * AFJSONStringFromParameters(NSDictionary *parameters);

@interface FaunaClient ()

+ (FaunaAFHTTPClient*)createHTTPClient;

+ (NSString*) requestPathFromPath:(NSString*)path andMethod:(NSString*)method;

/*!
 Returns the HTTP Client enabled with Client Key.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *keyClient;

/*!
 Returns the HTTP Client enabled with the current User Token.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *userClient;

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters error:(NSError**)error;

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters client:(FaunaAFHTTPClient*)client error:(NSError**)error;

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body error:(NSError**)error;

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body client:(FaunaAFHTTPClient*)client error:(NSError**)error;

- (NSData*)performRawOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body response:(NSURLResponse**)httpResponse client:(FaunaAFHTTPClient*)client error:(NSError**)error;

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

+ (NSString*) requestPathFromPath:(NSString*)path andMethod:(NSString*)method {
  NSParameterAssert(path);
  NSParameterAssert(method);
  return [[NSString stringWithFormat:@"%@ %@", method, path] uppercaseString];
}

- (void)setUserToken:(NSString *)userToken {
  _userToken = userToken;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:userToken forKey:kFaunaTokenUserKey];
  [defaults synchronize];
  [self.userClient setAuthorizationHeaderWithUsername:userToken password:nil];
}

- (BOOL)destroyInstance:(NSString*)ref error:(NSError**)error {
  NSParameterAssert(ref);
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  NSHTTPURLResponse *httpResponse;
  [self performRawOperationWithPath:path method:@"DELETE" parameters:nil body:nil response:&httpResponse client:_userClient error:error];
  if(*error) {
    return NO;
  }
  return YES;
}

#pragma mark - Timelines

- (BOOL)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference error:(NSError**)error {
  NSParameterAssert(instanceReference);
  NSParameterAssert(timelineReference);
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [self performOperationWithPath:path method:@"DELETE" parameters:nil body:sendParams error:error];
  if(*error) {
    return NO;
  }
  return YES;
}

- (NSDictionary*)execute:(NSString*)commandName params:(NSDictionary*)params error:(NSError**)error {
  NSParameterAssert(commandName);
  NSString * path = [NSString stringWithFormat:@"/%@/commands/%@", FaunaAPIVersion, commandName];
  return [self performOperationWithPath:path method:@"POST" parameters:params error:error];
}

- (NSDictionary*)pageFromTimeline:(NSString *)timelineReference before:(NSDate*)before  after:(NSDate*)after count:(NSInteger)count error:(NSError**)error {

  NSMutableDictionary *sendParams = [[NSMutableDictionary alloc] initWithCapacity:3];
  if(count) {
    [sendParams setObject:[NSNumber numberWithInt:count] forKey:kCountKey];
  }
  if(before) {
    [sendParams setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:kBeforeKey];
  }
  if(after) {
    [sendParams setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:kAfterKey];
  }
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  return [self performOperationWithPath:path method:@"GET" parameters:sendParams error:error];
}

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters error:(NSError*__autoreleasing*)error {
  return [self performOperationWithPath:path method:method parameters:parameters body:nil error:error];
}


- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters client:(FaunaAFHTTPClient*)client error:(NSError*__autoreleasing*)error {
  return [self performOperationWithPath:path method:method parameters:parameters body:nil client:client error:error];
}


- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body error:(NSError*__autoreleasing*)error {
  return [self performOperationWithPath:path method:method parameters:parameters body:body client:_userClient error:error];
}

- (NSDictionary*)performOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body client:(FaunaAFHTTPClient*)client error:(NSError*__autoreleasing*)error {
  //FaunaCache * cache = self.cache;
  NSString * responsePath = [self.class requestPathFromPath:path andMethod:method];
  /*if(![FaunaCache shouldIgnoreCache]) {
    // if response is cached, return it.
    FaunaResponse * response = [cache loadResponse:responsePath];
    if(response) {
      return response.resource;
    }
  }*/
  NSURLResponse *httpResponse;
  NSData* data = [self performRawOperationWithPath:path method:method parameters:parameters body:body response:&httpResponse client:client error:error];
  if(*error) {
    // if there is an error, return from cache if current policy allow it.
    /*if(![FaunaCache shouldIgnoreCache] && (*error).shouldRespondFromCache) {
      FaunaResponse *response = [_cache loadResponse:responsePath];
      if(response) {
        return response.resource;
      }
    }*/
    return nil;
  }
  NSDictionary* responseObject = FaunaAFJSONDecode(data, error);
  if(*error) {
    return nil;
  }
  //NSDictionary * references = [responseObject objectForKey:@"references"];
  NSDictionary * resource = [responseObject objectForKey:@"resource"];
  /*if(references) {
    for (NSDictionary *resource in references.allValues) {
      [self saveResource:resource];
    }
  }*/
  /*FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject cached:NO requestPath:responsePath];*/
  /*
   
   // save references data separately
   for (NSMutableDictionary *resource in response.references.allValues) {
   [self saveResource:resource];
   }

   */
  //[cache saveResponse:response];
  return resource;
}

- (NSData*)performRawOperationWithPath:(NSString*)path method:(NSString*)method parameters:(NSDictionary*)parameters body:(NSDictionary*)body response:(NSURLResponse**)httpResponse client:(FaunaAFHTTPClient*)client error:(NSError**)error {
  NSMutableURLRequest * request = [client requestWithMethod:method path:path parameters:parameters];
  NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(@"utf-8"));
  
  if(body) {
    [request setHTTPBody:[AFJSONStringFromParameters(body) dataUsingEncoding:@"utf-8"]];
  }
  
  [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
  return [NSURLConnection sendSynchronousRequest:request returningResponse:httpResponse error:error];
}

- (NSDictionary*)getResource:(NSString*)ref error:(NSError*__autoreleasing*)error {
  NSParameterAssert(ref);
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, ref];
  return [self performOperationWithPath:path method:@"GET" parameters:nil error:error];
}

- (NSDictionary*)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference error:(NSError**)error {
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  return [self performOperationWithPath:path method:@"POST" parameters:sendParams error:error];
}

- (NSDictionary*)createInstance:(NSDictionary*)resource error:(NSError*__autoreleasing*)error {
  NSParameterAssert(resource);
  NSString * path = [NSString stringWithFormat:@"/%@/instances", FaunaAPIVersion];
  return [self performOperationWithPath:path method:@"POST" parameters:resource error:error];
}

- (NSDictionary*)updateInstance:(NSString*)ref changes:(NSDictionary*)changes error:(NSError**)error {
  NSParameterAssert(ref);
  NSParameterAssert(changes);
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  return [self performOperationWithPath:path method:@"PUT" parameters:changes error:error];
}

- (NSDictionary*)createUser:(NSDictionary*)userInfo error:(NSError**)error {
  NSParameterAssert(userInfo);
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  return [self performOperationWithPath:path method:@"POST" parameters:userInfo error:error];
}

- (BOOL)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation error:(NSError**)error {
  NSDictionary *sendParams = @{
                               kPassword : oldPassword,
                               kNewPassword: newPassword,
                               kNewPasswordConfirmation: confirmation
                               };
  NSString * path = [NSString stringWithFormat:@"/%@/users/self/settings/password", FaunaAPIVersion];
  [self performOperationWithPath:path method:@"POST" parameters:sendParams error:error];
  if(*error) {
    return NO;
  }
  return YES;
}

- (NSString*)createToken:(NSDictionary*)credentials error:(NSError**)error {
  NSDictionary *sendParams = credentials;
  NSString * path = [NSString stringWithFormat:@"/%@/tokens", FaunaAPIVersion];
  NSDictionary* tokenInfo = [self performOperationWithPath:path method:@"POST" parameters:sendParams client:_keyClient error:error];
  if(*error) {
    return nil;
  }
  return self.userToken = tokenInfo[@"token"];
}

@end
