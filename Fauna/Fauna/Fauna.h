//
//  Fauna.h
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaClient.h"
#import "FaunaContext.h"
#import "FaunaTimeline.h"
#import "FaunaResource.h"
#import "FaunaInstance.h"
#import "FaunaCommand.h"

/*!
 Fauna
 */
@interface Fauna : NSObject

/** @name Initializing Fauna */

/*!
 Returns the current FaunaClient instance.
 */
+(FaunaClient*) client;

/*!
 Sets the current FaunaClient associated for the current app.
 @param current new global Client to use in the current app.
 */
+(void)setClient:(FaunaClient*)client;

@end
