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

- (id)initWithContext:(FaunaContext*) context response:(NSDictionary*)responseDictionary andRootResourceClass:(Class)rootResourceClass {
  NSAssert(context, @"Context is required in order to initialize FaunaResponse");
  if(self = [super init]) {
    self.context = context;
    id res = [rootResourceClass alloc];
    self.resource = [res initWithDictionary:[responseDictionary objectForKey:kResourceKey]];
    
    NSDictionary * refDictionary = [responseDictionary objectForKey:kReferencesKey];
    NSMutableDictionary * references = [NSMutableDictionary dictionaryWithCapacity:refDictionary.count];
    if(refDictionary) {
      // Translate all the references from the API response into a dictionary filled with FaunaResource instances.
      for (NSString *refId in [refDictionary allKeys]) {
        NSMutableDictionary *resourceDict = [refDictionary objectForKey:refId];
        FaunaResource *resource = [[FaunaResource alloc] initWithContext:self.context andDictionary:resourceDict];
        [references setObject:resource forKey:refId];
      }
    }
    self.references = references;
  }
  return self;
}

@end
