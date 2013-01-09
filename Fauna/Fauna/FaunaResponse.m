//
//  FaunaResponse.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResponse.h"

#define kResourceKey @"resource"
#define kReferencesKey @"references"

@implementation FaunaResponse

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary {
  return [[self alloc] initWithDictionary:responseDictionary];
}

- (id)initWithDictionary:(NSDictionary*)responseDictionary {
  NSAssert(responseDictionary, @"responseDictionary is required to initialize FaunaResponse");
  if(self = [super init]) {
    self.resource = [responseDictionary objectForKey:kResourceKey];    
    self.references = [responseDictionary objectForKey:kReferencesKey];
  }
  return self;
}

@end
