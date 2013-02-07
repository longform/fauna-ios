//
//  FaunaResponse.m
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResponse.h"

#define kResourceKey @"resource"
#define kResourcesKey @"resources"
#define kReferencesKey @"references"

@implementation FaunaResponse

+ (NSString*) requestPathFromPath:(NSString*)path andMethod:(NSString*)method {
  NSParameterAssert(path);
  NSParameterAssert(method);
  return [[NSString stringWithFormat:@"%@ %@", method, path] uppercaseString];
}

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary {
  return [[self alloc] initWithDictionary:responseDictionary cached:NO requestPath:nil];
}

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary cached:(BOOL)cached requestPath:(NSString*)requestPath {
  return [[self alloc] initWithDictionary:responseDictionary cached:cached requestPath:requestPath];
}

- (id)initWithDictionary:(NSDictionary*)responseDictionary cached:(BOOL)cached requestPath:(NSString*)requestPath {
  NSAssert(responseDictionary, @"responseDictionary is required to initialize FaunaResponse");
  if(self = [super init]) {
    _requestPath = requestPath;
    _cached = cached;
    self.resources = responseDictionary[kResourcesKey];
    self.resource = responseDictionary[kResourceKey];
    if(!_resources && _resource) {
      _resources = @[_resource];
    }
    if(!_resource && _resources.count > 0) {
      _resource = _resources[0];
    }
    self.references = responseDictionary[kReferencesKey];
  }
  return self;
}

@end
