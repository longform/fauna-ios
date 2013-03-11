//
//  FaunaConnection.m
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaConnection.h"
#import "FaunaAFNetworking.h"
#import "FaunaAFJSONUtilities.h"
#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"

#define FaunaAPIBaseURL @"https://rest.fauna.org"
#define FaunaAPIVersion @"v1"

@interface FaunaConnection ()

/*!
 Underlying HTTP client.
 */
@property (nonatomic, strong, readonly) FaunaAFHTTPClient *httpClient;

@end

@implementation FaunaConnection

#pragma mark Class Methods

+ (NSString *)APIVersion {
  return FaunaAPIVersion;
}

+ (FaunaConnection *)sharedConnection {
  static FaunaConnection *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ shared = [self new]; });

  return shared;
}

#pragma mark Instance Methods

- (id)init {
  if (self = [super init]) {
    _httpClient = [FaunaConnection createHTTPClient];
  }

  return self;
}

# pragma mark Private Methods/Helpers

+ (FaunaAFHTTPClient *)createHTTPClient {
  NSString *baseURL = [NSString stringWithFormat:@"https://%@/%@", FaunaAPIBaseURL, FaunaAPIVersion];

  FaunaAFHTTPClient *client = [[FaunaAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: baseURL]];

  [client setDefaultHeader:@"Accept" value:@"application/json"];
  [client registerHTTPOperationClass:[FaunaAFJSONRequestOperation class]];
  client.stringEncoding = NSUnicodeStringEncoding;
  client.parameterEncoding = FaunaAFJSONParameterEncoding;

  return client;
}



@end
