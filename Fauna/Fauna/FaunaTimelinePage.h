//
//  FaunaTimelinePage.h
//  Fauna
//
//  Created by Johan Hernandez on 12/28/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"

@interface FaunaTimelinePage : FaunaResource

@property (readonly) NSInteger creates;

@property (readonly) NSInteger updates;

@property (readonly) NSInteger deletes;

@property (readonly) NSArray* events;

@property (readonly) NSDate* after;

@property (readonly) NSDate* before;

@end
