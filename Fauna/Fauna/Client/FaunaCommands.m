//
//  FaunaCommand.m
//  Fauna
//
//  Created by Johan Hernandez on 12/30/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaCommands.h"
#import "FaunaAFHTTPClient.h"

@interface FaunaCommands ()

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@end

@implementation FaunaCommands

- (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block {
  NSAssert(commandName, @"commandName is required");
  NSAssert(block, @"callback is required");
  NSDictionary *sendParams = params;
  NSString * path = [NSString stringWithFormat:@"/%@/commands/%@", FaunaAPIVersion, commandName];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
