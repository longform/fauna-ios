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
#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"
#define kPassword @"password"
#define kNewPassword @"new_password"
#define kNewPasswordConfirmation @"new_password_confirmation"

extern NSString * AFJSONStringFromParameters(NSDictionary *parameters);
NSString * const GetMethod = @"GET";

NSString* extractResourcePath(NSString* path) {
  // extract the fauna api version and the leading and trailing slash
  return [path substringFromIndex:FaunaAPIVersion.length + 2];
}

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
  [self.userClient setAuthorizationHeaderWithUsername:userToken password:nil];
}

- (BOOL)destroyInstance:(NSString*)ref error:(NSError**)error {
  NSParameterAssert(ref);
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, ref];
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
  FaunaCache * cache = [FaunaCache scopeCache];
  NSString * resourcePath = extractResourcePath(path);
  
  NSDictionary * resource = nil;
  BOOL useResourceCache = [GetMethod isEqualToString:method];
  if(useResourceCache) {
    // if response is cached, return it.
    resource = [cache loadResource:resourcePath];
    if(resource) {
      NSLog(@"FaunaCache(Read): %@", resourcePath);
      return resource;
    }
  }
  NSLog(@"FaunaRemote: %@", resourcePath);
  NSURLResponse *httpResponse;
  NSData* data = [self performRawOperationWithPath:path method:method parameters:parameters body:body response:&httpResponse client:client error:error];
  NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  if(*error) {
    NSLog(@"Fauna HTTP Error: %@, response: %@", *error, dataString);
    return nil;
  }
  NSDictionary* responseObject = FaunaAFJSONDecode(data, error);
  if(*error) {
    NSLog(@"Fauna JSON Error: %@, response: %@", *error, dataString);
    return nil;
  }
  NSDictionary * references = [responseObject objectForKey:@"references"];
  resource = [responseObject objectForKey:@"resource"];
  if(resource && useResourceCache) {
    [cache saveResource:resource];
    if(cache.isTransient) {
      [cache.parentContextCache saveResource:resource];
    }
  }
  if(references) {
    for (NSDictionary *resource in references.allValues) {
      NSLog(@"FaunaCache (Write): %@", resource[@"ref"]);
      [cache saveResource:resource];
      if(cache.isTransient) {
        NSLog(@"FaunaCache (Write-Context): %@", resource[@"ref"]);
        [cache.parentContextCache saveResource:resource];
      }
    }
  }
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
  NSString * className = resource[@"class"];
  NSString * path = [NSString stringWithFormat:@"/%@/classes/%@", FaunaAPIVersion, className];
  return [self performOperationWithPath:path method:@"POST" parameters:resource error:error];
}

- (NSDictionary*)updateInstance:(NSString*)ref changes:(NSDictionary*)changes error:(NSError**)error {
  NSParameterAssert(ref);
  NSParameterAssert(changes);
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, ref];
  return [self performOperationWithPath:path method:@"PUT" parameters:changes error:error];
}

- (NSDictionary*)createUser:(NSDictionary*)userInfo error:(NSError**)error {
  NSParameterAssert(userInfo);
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  return [self performOperationWithPath:path method:@"POST" parameters:userInfo client:_keyClient error:error];
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
  return tokenInfo[@"token"];
}

@end
