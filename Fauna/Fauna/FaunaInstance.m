//
//  FaunaInstance.m
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaInstance.h"
#import "FaunaTimeline.h"

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

- (void)save:(FaunaResponseResultBlock)block {
  NSMutableDictionary *sendParams = [self resourceDictionary];
  NSString * path = [NSString stringWithFormat:@"/%@/instances", FaunaAPIVersion];
  [self.context.userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:self.context response:responseObject andRootResourceClass:[FaunaInstance class]];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
