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

@implementation FaunaContext

- (id)init {
  self = [super init];
  if(self) {
    _client = [[FaunaAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://rest.fauna.org"]];
    [self.client setDefaultHeader:@"Accept" value:@"application/json"];
    [self.client registerHTTPOperationClass:[FaunaAFJSONRequestOperation class]];
    self.client.stringEncoding = NSUnicodeStringEncoding;
    self.client.parameterEncoding = FaunaAFJSONParameterEncoding;
  }
  return self;
}

- (id)initWithKey:(FaunaKey *)key {
  NSAssert(key, @"Key instance must be provided");
  self = [self init];
  if(self) {
    self.key = key;
    if([self.key isKindOfClass:[FaunaKey class]]) {
      // set authorization header
      [self.client setAuthorizationHeaderWithUsername:self.key.keyString password:nil];
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

@end
