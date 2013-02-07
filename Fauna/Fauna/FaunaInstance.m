//
//  FaunaInstance.m
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaInstance.h"

@implementation FaunaInstance

+ (FaunaInstance*)get:(NSString *)ref error:(NSError**)error {
  NSParameterAssert(ref);
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  return (FaunaInstance*)[FaunaResource get:resourcePath error:error];
}

@end
