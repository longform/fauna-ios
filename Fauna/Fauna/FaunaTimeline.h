//
//  FaunaTimeline.h
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResponse.h"

@interface FaunaTimeline : NSObject

+ (FaunaResponse*)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count error:(NSError**)error;

@end
