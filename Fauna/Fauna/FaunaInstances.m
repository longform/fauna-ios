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

- (void)destroy:(NSString*)ref callback:(FaunaSimpleResultBlock)block {
  NSAssert(ref, @"ref is required");
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  [self.client deletePath:path parameters:nil success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    block(nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error creating instance: %@", error);
    block(error);
  }];
}

- (void)update:(NSString*)ref changes:(NSDictionary*)changes callback:(FaunaResponseResultBlock)block {
  NSAssert(ref, @"ref is required");
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  
  NSDictionary *sendParams = changes;
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, resourcePath];
  [self.client putPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error updating instance: %@", error);
    block(nil, error);
  }];
}

@end
