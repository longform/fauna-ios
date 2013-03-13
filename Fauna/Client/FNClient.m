//
//  FNClient.m
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNClient.h"
#import "FaunaAFNetworking.h"
#import "FaunaAFJSONRequestOperation.h"
#import "FaunaAFJSONUtilities.h"
#import "FaunaError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"
#import "NSObject+FNBlockObservation.h"

NSString * const FaunaAPIBaseURL = @"https://rest.fauna.org";
NSString * const FaunaAPIVersion = @"v1";

@interface FNClient ()

/*!
 Underlying HTTP client.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *httpClient;

@end

@implementation FNClient

#pragma mark lifecycle

- (id)init {
  if (self = [super init]) {
    _httpClient = [FNClient createHTTPClient];
  }

  return self;
}

#pragma mark Public methods

+ (FNClient *)sharedClient {
  static FNClient *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self new];
  });

  return shared;
}

- (FNFuture *)performRequest:(NSURLRequest *)request {
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

# pragma mark Private methods

+ (FaunaAFHTTPClient *)createHTTPClient {
  NSString *baseURL = [NSString stringWithFormat:@"%@/%@", FaunaAPIBaseURL, FaunaAPIVersion];

  LOG(@"Creating client with base url: %@", baseURL);

  FaunaAFHTTPClient *client = [[FaunaAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: baseURL]];

  [client setDefaultHeader:@"Accept" value:@"application/json"];
  [client registerHTTPOperationClass:[FaunaAFJSONRequestOperation class]];
  client.stringEncoding = NSUnicodeStringEncoding;
  client.parameterEncoding = FaunaAFJSONParameterEncoding;

  return client;
}

@end
