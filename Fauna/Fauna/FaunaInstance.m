//
//  FaunaInstance.m
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaInstance.h"
#import "FaunaContext.h"

#define kExternalIdKey @"external_id"
#define kClassKey @"class"
#define kReferencesKey @"references"
#define kDataKey @"data"

@implementation FaunaInstance


- (void)setExternalId:(NSString *)externalId {
  [self.resourceDictionary setValue:externalId forKey:kExternalIdKey];
}

- (NSString*)externalId {
  return [self.resourceDictionary valueForKey:kExternalIdKey];
}

- (void)setClassName:(NSString *)className {
  [self.resourceDictionary setValue:className forKey:kClassKey];
}

- (NSString*)className {
  return [self.resourceDictionary valueForKey:kClassKey];
}

- (void)setReferences:(NSDictionary *)references {
  [self.resourceDictionary setValue:references forKey:kReferencesKey];
}

- (NSDictionary*)references {
  return [self.resourceDictionary valueForKey:kReferencesKey];
}

- (void)setData:(NSDictionary *)data {
  [self.resourceDictionary setValue:data forKey:kDataKey];
}

- (NSDictionary*)data {
  return [self.resourceDictionary valueForKey:kDataKey];
}

+ (FaunaInstance*)get:(NSString *)ref error:(NSError**)error {
  NSParameterAssert(ref);
  NSArray * arr = [ref componentsSeparatedByString:@"/"];
  // works when ref is just the number of the instance.
  // E.g. "123445678" and also for "instances/123445678"
  NSString * resourcePath = [NSString stringWithFormat:@"instances/%@", arr[arr.count -1]];
  return (FaunaInstance*)[FaunaResource get:resourcePath error:error];
}

+ (BOOL)create:(FaunaInstance *)resource error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  NSDictionary * resourceDictionary = [client createInstance:resource.resourceDictionary error:error];
  if(*error || !resourceDictionary) {
    return NO;
  }
  resource.resourceDictionary = [[NSMutableDictionary alloc] initWithDictionary:resourceDictionary];
  return YES;
}

@end
