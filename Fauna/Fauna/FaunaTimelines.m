//
//  FaunaTimeline.m
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaTimelines.h"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"

#import "FaunaAFNetworking.h"

@interface FaunaTimelines ()

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSInteger)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

@property (nonatomic, strong) FaunaAFHTTPClient * client;

@end

@implementation FaunaTimelines

- (void)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference callback:
(FaunaResponseResultBlock)block {
  NSAssert(instanceReference, @"instanceReference is required");
  NSAssert(timelineReference, @"timelineReference is required");
  NSAssert(block, @"block is required");
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [self.client postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:count before:nil after:nil callback:block];
}

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSInteger)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block {
  NSMutableDictionary *sendParams = [[NSMutableDictionary alloc] initWithCapacity:3];
  if(count) {
    [sendParams setObject:[NSNumber numberWithInteger:count] forKey:kCountKey];
  }
  if(before) {
    [sendParams setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:kBeforeKey];
  }
  if(after) {
    [sendParams setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:kAfterKey];
  }
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [self.client getPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
