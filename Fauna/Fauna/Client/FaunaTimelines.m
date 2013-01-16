//
//  FaunaTimeline.m
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaTimelines.h"
#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"

#import "FaunaAFNetworking.h"

@interface FaunaTimelines ()

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

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

- (void)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block {
  NSAssert(instanceReference, @"instanceReference is required");
  NSAssert(timelineReference, @"timelineReference is required");
  NSAssert(block, @"block is required");
  NSDictionary *sendParams = @{kResourceKey : instanceReference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, timelineReference];
  [self.client deleteBodyPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [FaunaResponse responseWithDictionary:responseObject];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:nil callback:block];
}

- (void)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block {
  NSMutableDictionary *sendParams = [[NSMutableDictionary alloc] initWithCapacity:3];
  if(count) {
    [sendParams setObject:count forKey:kCountKey];
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

- (void)pageFromTimeline:(NSString *)timelineReference after:(NSDate *)after callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:nil before:nil after:after callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference after:(NSDate *)after withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:after callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference before:(NSDate *)before callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:nil before:before after:nil callback:block];
}

- (void)pageFromTimeline:(NSString *)timelineReference before:(NSDate *)before withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:before after:nil callback:block];
}

@end
