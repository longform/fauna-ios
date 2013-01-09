//
//  FaunaInstance.m
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaInstances.h"
#import "FaunaAFHTTPClient.h"

@interface FaunaInstances ()

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@end

@implementation FaunaInstances

- (void)create:(NSDictionary*)instance callback:(FaunaResponseResultBlock)block {
  NSDictionary *sendParams = instance;
  NSString * path = [NSString stringWithFormat:@"/%@/instances", FaunaAPIVersion];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error creating instance: %@", error);
    block(nil, error);
  }];  
}

@end
