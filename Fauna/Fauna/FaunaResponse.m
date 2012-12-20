//
//  FaunaResponse.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResponse.h"

#define kResourceKey @"resource"

@implementation FaunaResponse

- (id)initWithContext:(FaunaContext*) context response:(NSDictionary*)responseDictionary andRootResourceClass:(Class)rootResourceClass {
  NSAssert(context, @"Context is required in order to initialize FaunaResponse");
  if(self = [super init]) {
    self.context = context;
    id res = [rootResourceClass alloc];
    self.resource = [res initWithDictionary:[responseDictionary objectForKey:kResourceKey]];
    //TODO: Inspect Resources
  }
  return self;
}

@end
