//
//  FaunaTimelinePage.h
//  Fauna
//
//  Created by Johan Hernandez on 2/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResource.h"

@interface FaunaTimelinePage : FaunaResource

@property (readonly) NSInteger creates;

@property (readonly) NSInteger updates;

@property (readonly) NSInteger deletes;

@property (readonly) NSArray* events;

@property (readonly) NSDate* after;

@property (readonly) NSDate* before;

@end
