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

#define kRefKey @"ref"
#define kCountKey @"count"
#define kBeforeKey @"before"
#define kAfterKey @"after"
#import "FaunaAFNetworking.h"

@implementation FaunaTimeline

+ (FaunaResponse*)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count error:(NSError**)error {
  return [self pageFromTimeline:timelineReference count:[NSNumber numberWithInteger:count] before:nil after:nil error:error];
}

+ (FaunaResponse*)pageFromTimeline:(NSString*)timelineReference count:(NSNumber*)count before:(NSDate*)before after:(NSDate*)after error:(NSError**)error {
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  return [client pageFromTimeline:timelineReference withCount:count error:error];
}

@end
