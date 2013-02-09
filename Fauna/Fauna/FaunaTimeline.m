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

+ (FaunaTimelinePage*)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count error:(NSError**)error {
  return [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:nil error:error];
}

+ (FaunaTimelinePage*)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  return (FaunaTimelinePage*)[FaunaResource deserialize:[client pageFromTimeline:timelineReference withCount:count error:error]];
}

+ (BOOL)addInstance:(NSString*)ref toTimeline:(NSString*)timelineRef error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  [client addInstance:ref toTimeline:timelineRef error:error];
  if(*error) {
    return NO;
  }
  return YES;
}

@end
