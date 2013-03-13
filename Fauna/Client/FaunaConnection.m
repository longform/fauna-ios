//
//  FaunaConnection.m
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaConnection.h"
#import "FaunaAFNetworking.h"
#import "FaunaAFJSONRequestOperation.h"
#import "FaunaAFJSONUtilities.h"
#import "FaunaError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"

#define FaunaAPIBaseURL @"https://rest.fauna.org"
#define FaunaAPIVersion @"v1"

@interface FaunaConnection ()

/*!
 Underlying HTTP client.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *httpClient;

@end

@implementation FaunaConnection

#pragma mark lifecycle

- (id)init {
  if (self = [super init]) {
    _httpClient = [FaunaConnection createHTTPClient];
  }

  return self;
}

#pragma mark Public methods

+ (FaunaConnection *)sharedConnection {
  static FaunaConnection *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self new];
  });

  return shared;
}

- (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers {
  NSMutableURLRequest *req = [self requestWithMethod:@"GET" path:path parameters:parameters headers:headers];
  return [self performRequest:req];
}

- (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers {
  NSMutableURLRequest *req = [self requestWithMethod:@"POST" path:path parameters:parameters headers:headers];
  return [self performRequest:req];
}

- (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers {
  NSMutableURLRequest *req = [self requestWithMethod:@"PUT" path:path parameters:parameters headers:headers];
  return [self performRequest:req];
}

- (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers {
  NSMutableURLRequest *req = [self requestWithMethod:@"DELETE" path:path parameters:parameters headers:headers];
  return [self performRequest:req];
}

# pragma mark Private methods

+ (FaunaAFHTTPClient *)createHTTPClient {
  NSString *baseURL = [NSString stringWithFormat:@"https://%@/%@", FaunaAPIBaseURL, FaunaAPIVersion];

  FaunaAFHTTPClient *client = [[FaunaAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: baseURL]];

  [client setDefaultHeader:@"Accept" value:@"application/json"];
  [client registerHTTPOperationClass:[FaunaAFJSONRequestOperation class]];
  client.stringEncoding = NSUnicodeStringEncoding;
  client.parameterEncoding = FaunaAFJSONParameterEncoding;

  return client;
}

- (FNFuture *)performRequest:(NSURLRequest *)request {
  FNMutableFuture *res = [FNMutableFuture new];
  NSMutableDictionary *scope = [FNFutureScope saveCurrent];

  FaunaAFJSONRequestOperation *op = [FaunaAFJSONRequestOperation new];
  FaunaAFJSONRequestOperation * __weak wkOp = op;

  op.completionBlock = ^{
    FaunaAFJSONRequestOperation *op = wkOp;
    [FNFutureScope restoreCurrent:scope];

    if (op.isCancelled) {
      [res updateError:FaunaOperationCancelled()];
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
    [FNFutureScope removeCurrent];
  };

  [self.httpClient enqueueHTTPRequestOperation:op];
  
  return res;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                   headers:(NSDictionary *)headers {

  // AFHTTPClient appends parameters to the end of the url for delete, but fauna requires
  // them to be in the body. Fake out AFHTTPClient and then reset the method.
  NSString *afMethod = [method isEqual:@"DELETE"] ? @"POST" : method;

  NSMutableURLRequest *req = [self.httpClient requestWithMethod:afMethod
                                                           path:path
                                                     parameters:parameters];

  req.HTTPMethod = method;

  [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [req setValue:obj forHTTPHeaderField:key];
  }];

  return req;
}

@end
