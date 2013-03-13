//
//  FaunaTimeline.m
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaTimeline.h"
#import "FaunaContext.h"
#import "FaunaCache.h"
#import "FaunaAFNetworking.h"

@implementation FaunaTimeline

+ (FaunaTimelinePage*)pageFromTimeline:(NSString *)timelineReference count:(NSInteger)count error:(NSError**)error {
  return [self pageFromTimeline:timelineReference before:nil after:nil count:[NSNumber numberWithInteger:count] error:error];
}

+ (FaunaTimelinePage*)pageFromTimeline:(NSString *)timelineReference before:(NSDate*)before count:(NSInteger)count error:(NSError**)error {
  return [self pageFromTimeline:timelineReference before:before after:nil count:[NSNumber numberWithInteger:count] error:error];
}

+ (FaunaTimelinePage*)pageFromTimeline:(NSString *)timelineReference after:(NSDate*)after count:(NSInteger)count error:(NSError**)error {
  return [self pageFromTimeline:timelineReference before:nil after:after count:[NSNumber numberWithInteger:count] error:error];
}

+ (FaunaTimelinePage*)pageFromTimeline:(NSString*)timelineReference before:(NSDate*)before after:(NSDate*)after count:(NSInteger)count error:(NSError**)error {
  return [FaunaContext.current wrap:^{
    return (FaunaTimelinePage*)[FaunaResource deserialize:[FaunaContext.current.client pageFromTimeline:timelineReference before:before after:after count:[NSNumber numberWithInteger:count] error:error]];
  }];
}

+ (BOOL)addInstance:(NSString*)ref toTimeline:(NSString*)timelineRef error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  return [[FaunaContext.current wrap:^{
    [client addInstance:ref toTimeline:timelineRef error:error];
    if(*error) {
      return @NO;
    }
    return @YES;
  }] boolValue];
}

+ (BOOL)removeInstance:(NSString*)ref fromTimeline:(NSString*)timelineRef error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  return [[FaunaContext.current wrap:^{
    return @([client removeInstance:ref fromTimeline:timelineRef error:error]);
  }] boolValue];
}

@end
