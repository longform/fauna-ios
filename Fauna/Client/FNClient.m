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
#import "FaunaAFNetworking.h"
#import "FaunaAFJSONRequestOperation.h"
#import "FaunaAFJSONUtilities.h"
#import "FNError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"
#import "NSObject+FNBlockObservation.h"
#import "NSString+FNBase64Encoding.h"

#define API_VERSION @"v1"

NSString * const FaunaAPIVersion = API_VERSION;
NSString * const FaunaAPIBaseURL = @"https://rest.fauna.org";
NSString * const FaunaAPIBaseURLWithVersion = @"https://rest.fauna.org/" API_VERSION @"/";

@implementation FNResponse

- (id)initWithResource:(NSDictionary *)resource references:(NSDictionary *)references {
  self = [super init];
  if (self) {
    _resource = resource;
    _references = references;
  }
  return self;
}

@end

@interface FNClient ()

@property (nonatomic, readonly) NSString *authString;
@property (nonatomic, readonly) NSString *authHeaderValue;

@end

@implementation FNClient

#pragma mark lifecycle

- (id)initWithAuthString:(NSString *)authString {
  self = [super init];
  if (self) {
    _authString = authString;
    _authHeaderValue = [@"Basic " stringByAppendingString:authString.base64Encoded];
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

#pragma mark Private methods

- (FNFuture *)performRequestWithMethod:(NSString *)method
                                             path:(NSString *)path
                                       parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *req = [self.class requestWithMethod:method path:path parameters:parameters];

  [req setValue:self.authHeaderValue forHTTPHeaderField:@"Authorization"];
  if (self.traceID) [req setValue:self.traceID forHTTPHeaderField:@"X-TRACE-ID"];

  return [[self.class performRequest:req] transform:^FNFuture *(FNFuture *f) {

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

+ (NSOperationQueue *)operationQueue {
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
    url = [NSURL URLWithString:FaunaAPIBaseURLWithVersion];
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
      NSString *params = AFQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding);
      NSString *sep = [path rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
      url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"%@%@", sep, params]];
      req.URL = url;
    }
  } else {
    [req setValue:@"application/json charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSError __autoreleasing *err;
    NSData *json = FaunaAFJSONEncode(parameters, &err);
    if (!json) return nil;
    req.HTTPBody = json;
  }

  return req;
}

+ (FNFuture *)performRequest:(NSURLRequest *)request {
  FNMutableFuture *res = [FNMutableFuture new];
  FaunaAFJSONRequestOperation *op = [[FaunaAFJSONRequestOperation alloc] initWithRequest:request];
  FaunaAFJSONRequestOperation * __weak wkOp = op;

  id cancelledToken = [res addObserverForKeyPath:@"isCancelled" task:^(FNFuture *res, NSDictionary *change) {
    if (res.isCancelled) [wkOp cancel];
  }];

  op.completionBlock = ^{
    FaunaAFJSONRequestOperation *op = wkOp;
    [res removeObserverWithBlockToken:cancelledToken];

    if (op.isCancelled) {
      [res updateError:FNOperationCancelled()];
    } else if (op.error) {
      [res updateError:op.error];
    } else {
      id json = op.responseJSON;

      // check error again, as calling responseJSON may have set it as a side-effect.
      if (op.error) {
        [res updateError:op.error];
      } else {
        [res update:json];
      }
    }
  };

  [self.operationQueue addOperation:op];

  return res;
}

@end
