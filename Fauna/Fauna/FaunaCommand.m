//
//  FaunaCommand.m
//  Fauna
//
//  Created by Johan Hernandez on 12/30/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaCommand.h"
#import "Fauna.h"

@implementation FaunaCommand

+ (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block {
  return [FaunaCommand execute:commandName params:params callback:block];
}

+ (void)execute:(NSString*)commandName params:(NSDictionary*)params context:(FaunaContext*)context callback:(FaunaResponseResultBlock)block {
  NSAssert(commandName, @"commandName is required");
  NSAssert(context, @"context is required");
  NSAssert(block, @"callback is required");
  NSDictionary *sendParams = params;
  NSString * path = [NSString stringWithFormat:@"/%@/commands/%@", FaunaAPIVersion, commandName];
  [context.userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:context response:responseObject andRootResourceClass:[FaunaResource class]];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
