//
//  FaunaTimeline.h
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaTimelinePage.h"

@interface FaunaTimeline : NSObject

+ (FaunaTimelinePage*)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count error:(NSError**)error;

/*!
 Adds an instance to the given timeline.
 @param ref Class Instance Reference.
 @param toTimeline Timeline Reference to add the given intance.
 */
+ (BOOL)addInstance:(NSString*)ref toTimeline:(NSString*)timelineRef error:(NSError**)error;

/*!
 Removes an instance from the given timeline.
 @param ref Class Instance Reference.
 @param fromTimeline Timeline Reference to remove the given instance from.
 */
+ (BOOL)removeInstance:(NSString*)ref fromTimeline:(NSString*)timelineRef error:(NSError**)error;

@end
