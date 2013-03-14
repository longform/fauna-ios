//
//  FaunaTimelinePage.h
//  Fauna
//
//  Created by Johan Hernandez on 2/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNResource.h"

@interface FaunaTimelinePage : FNResource

@property (nonatomic, readonly) NSInteger creates;

@property (nonatomic, readonly) NSInteger updates;

@property (nonatomic, readonly) NSInteger deletes;

@property (nonatomic, readonly) NSArray* events;

@property (nonatomic, readonly) NSDate* after;

@property (nonatomic, readonly) NSDate* before;

@end
