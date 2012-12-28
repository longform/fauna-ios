//
//  FaunaTimeline.h
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaInstance.h"
#import "FaunaTimelinePage.h"

@interface FaunaTimeline : FaunaResource

+ (FaunaTimeline*)timelineForReference:(NSString*)reference;

- (void)add:(FaunaInstance*)instance callback:(FaunaResponseResultBlock)block;

- (void)pageWithCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageBefore:(NSDate*)before callback:(FaunaResponseResultBlock)block;

- (void)pageBefore:(NSDate*)before count:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageAfter:(NSDate*)after callback:(FaunaResponseResultBlock)block;

- (void)pageAfter:(NSDate*)after count:(NSInteger)count callback:(FaunaResponseResultBlock)block;

@end
