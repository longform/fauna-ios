//
//  FaunaTimeline.h
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//
#import "FaunaConstants.h"

/*!
 Manages Fauna Timelines
 */
@interface FaunaTimelines : NSObject

#pragma mark - Maintainance

- (void)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block;

- (void)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block;

#pragma mark - Queries

- (void)pageFromTimeline:(NSString*)timelineReference withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference before:(NSDate*)before callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference before:(NSDate*)before withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference after:(NSDate*)after withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

@end
