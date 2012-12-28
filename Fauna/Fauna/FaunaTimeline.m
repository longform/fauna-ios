//
//  FaunaTimeline.m
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaTimeline.h"
#define kResourceKey @"resource"
#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"

@interface FaunaTimeline ()

- (void)pageWithCount:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

@end

@implementation FaunaTimeline

+ (FaunaTimeline*)timelineForReference:(NSString*)reference {
  NSAssert(reference, @"reference is required");
  FaunaTimeline * timeline = [[FaunaTimeline alloc] initWithDictionary:[NSMutableDictionary dictionaryWithDictionary:@{kRefKey: reference}]];
  return timeline;
}

- (void)add:(FaunaInstance*)instance callback:(FaunaResponseResultBlock)block {
  NSAssert(instance, @"instance is required");
  NSAssert(block, @"block is required");
  NSDictionary *sendParams = @{kResourceKey : instance.reference};
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, self.reference];
  [self.context.userClient postPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:self.context response:responseObject andRootResourceClass:[FaunaTimelinePage class]];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

- (void)pageWithCount:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  return [self pageWithCount:[NSNumber numberWithInteger:count] before:nil after:nil callback:block];
}

- (void)pageBefore:(NSDate*)before callback:(FaunaResponseResultBlock)block {
  return [self pageWithCount:nil before:before after:nil callback:block];
}

- (void)pageBefore:(NSDate*)before count:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  return [self pageWithCount:[NSNumber numberWithInteger:count] before:before after:nil callback:block];
}

- (void)pageAfter:(NSDate*)after callback:(FaunaResponseResultBlock)block {
  return [self pageWithCount:nil before:nil after:after callback:block];
}

- (void)pageAfter:(NSDate*)after count:(NSInteger)count callback:(FaunaResponseResultBlock)block {
  return [self pageWithCount:[NSNumber numberWithInteger:count] before:nil after:after callback:block];
}


- (void)pageWithCount:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after callback:(FaunaResponseResultBlock)block {
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
  NSString * path = [NSString stringWithFormat:@"/%@/%@", FaunaAPIVersion, self.reference];
  [self.context.userClient getPath:path parameters:sendParams success:^(FaunaAFHTTPRequestOperation *operation, id responseObject) {
    FaunaResponse *response = [[FaunaResponse alloc] initWithContext:self.context response:responseObject andRootResourceClass:[FaunaTimelinePage class]];
    block(response, nil);
  } failure:^(FaunaAFHTTPRequestOperation *operation, NSError *error) {
    block(nil, error);
  }];
}

@end
