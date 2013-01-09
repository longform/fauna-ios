//
//  FaunaUser.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaUsers.h"
#import "FaunaAFNetworking.h"

@class FaunaContext;

@interface FaunaUsers ()

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@end

@implementation FaunaUsers

- (void)create:(NSDictionary*)user callback:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = user;
  NSString * path = [NSString stringWithFormat:@"/%@/users", FaunaAPIVersion];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary: responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
