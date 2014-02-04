//
// FNClient.m
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

#import "FNClient.h"
#import "FNError.h"
#import "FNFuture.h"
#import "FNRequestOperation.h"
#import "FNMutableFuture.h"
#import "FNNetworkStatus.h"
#import "NSString+FNStringExtensions.h"
#import "NSDictionary+FNDictionaryExtensions.h"

#import <CommonCrypto/CommonDigest.h>

#define API_VERSION @"v1"

NSString * const FaunaAPIVersion = API_VERSION;
NSString * const FaunaAPIBaseURL = @"https://rest1.fauna.org";

@implementation FNResponse

- (id)initWithResource:(NSDictionary *)resource references:(NSDictionary *)references {
  self = [super init];
  if (self) {
    [FNNetworkStatus start];
    _resource = resource ?: @{};
    _references = references ?: @{};
  }
  return self;
}

@end

@interface FNClient ()

@property (nonatomic, readonly) NSString *authString;
@property (nonatomic, readonly) NSString *authHeaderValue;
@property (nonatomic, readonly) NSString *authHash;

@end

@implementation FNClient

#pragma mark lifecycle

- (id)initWithAuthString:(NSString *)authString {
  self = [super init];
  if (self) {
    _authString = authString;
    _authHeaderValue = [@"Basic " stringByAppendingString:authString.base64Encoded];

    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    _authHash = [NSString stringWithUTF8String:(const char*)digest];
  }
  return self;
}

- (id)initWithKey:(NSString *)keyString {
  return [self initWithAuthString:keyString];
}

- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef {
  return [self initWithAuthString:[keyString stringByAppendingFormat:@":%@", userRef]];
}

- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password {
  return [self initWithAuthString:[email stringByAppendingFormat:@":%@", password]];
}

#pragma mark Public methods

- (NSString*)getAuthHash {
  // todo: copy?
  return self.authHash;
}

- (instancetype)asUser:(NSString *)userRef {
  return [[self.class alloc] initWithKey:self.authString asUser:userRef];
}

- (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self performRequestWithMethod:@"GET" path:path parameters:parameters];
}

- (FNFuture *)get:(NSString *)path {
  return [self get:path parameters:nil];
}

- (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self performRequestWithMethod:@"POST" path:path parameters:parameters];
}

- (FNFuture *)post:(NSString *)path {
  return [self post:path parameters:nil];
}

- (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self performRequestWithMethod:@"PUT" path:path parameters:parameters];
}

- (FNFuture *)put:(NSString *)path {
  return [self put:path parameters:nil];
}

- (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self performRequestWithMethod:@"DELETE" path:path parameters:parameters];
}

- (FNFuture *)delete:(NSString *)path {
  return [self delete:path parameters:nil];
}

#pragma mark equality

- (BOOL)isEqualToClient:(FNClient *)client {
  return self == client || (client && [self.authString isEqualToString:client.authString]);
}

- (BOOL)isEqual:(id)object {
  return self == object || (object && [object isKindOfClass:[self class]] && [self isEqualToClient:object]);
}

- (NSUInteger)hash {
  NSUInteger result = 1;
  NSUInteger prime = 1789;

  result = prime * result + self.authString.hash;
  return result;
}

#pragma mark Private methods

- (FNFuture *)performRequestWithMethod:(NSString *)method
                                             path:(NSString *)path
                                       parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *req = [self.class requestWithMethod:method path:path parameters:parameters];

  [req setValue:self.authHeaderValue forHTTPHeaderField:@"Authorization"];
  [req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
  if (self.traceID) [req setValue:self.traceID forHTTPHeaderField:@"X-TRACE-ID"];

  return [[self.class performRequest:req inBackground:self.isBackgroundEnabled]
          transform:^FNFuture *(FNFuture *f) {

    if (self.logHTTPTraffic) {
      id request = req.description;
      id response = f.value ? f.value : f.error.debugDescription;
      NSLog(@"Request:\n%@\nResponse:\n%@", request, response);
    }

    if (f.value) {
      FNResponse *response = [[FNResponse alloc] initWithResource:f.value[@"resource"]
                                                       references:f.value[@"references"]];
      return [FNFuture value:response];
    } else {
      // FIXME: return an instance of our own subclass of NSError.
      return f;
    }
  }];
}

+ (NSOperationQueue *)sharedOperationQueue {
  static NSOperationQueue *queue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
  });

  return queue;
}

+ (NSURL *)baseURL {
  static NSURL *url = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    url = [NSURL URLWithString:FaunaAPIBaseURL];
  });

  return url;
}

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {

  NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];

  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
  req.HTTPMethod = method;

  [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

  if ([method isEqualToString:@"GET"]) {
    if (parameters) {
      NSString *queryString = [parameters queryStringWithEncoding:NSUTF8StringEncoding];
      NSString *sep = [path rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
      url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"%@%@", sep, queryString]];
      req.URL = url;
    }
  } else {
      if (![path isEqualToString:@"queries"]) {
          [req setValue:@"application/json charset=utf-8" forHTTPHeaderField:@"Content-Type"];
      }

      if (parameters) {
          if (![path isEqualToString:@"queries"]) {
            NSError __autoreleasing *err;
            NSData *json = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&err];
            if (!json) return nil;
            req.HTTPBody = json;
          }
          else {
              req.HTTPBody = [[self keyValueStringForDictionary:parameters] dataUsingEncoding:NSUTF8StringEncoding];
          }
      }
  }

  return req;
}

+ (NSString *)keyValueStringForDictionary:(NSDictionary *)dictionary {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in dictionary) {
        
        NSObject *value = [dictionary valueForKey:key];
        [string appendFormat:@"%@=%@&", key, value];
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

+ (FNFuture *)performRequest:(NSURLRequest *)request inBackground:(BOOL)inBackground {
  FNRequestOperation *op = [[FNRequestOperation alloc] initWithRequest:request];
  op.isBackgroundEnabled = inBackground;
  [self.sharedOperationQueue addOperation:op];
  return op.future;
}

@end
