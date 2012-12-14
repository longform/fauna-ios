//
//  Fauna.h
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaContext.h"
#import "FaunaResource.h"
#import "FaunaToken.h"

/*!
 Fauna
 */
@interface Fauna : NSObject

/** @name Initializing Fauna */

/*!
 Returns the current FaunaContext instance in use for the current app. The instance is shared across all threads, however, this property is not thread-safe.
 */
+(FaunaContext*) current;

/*!
 Sets the current FaunaContext associated for the current app.
 @param current new global Context to use in the current app.
 */
+(void)setCurrent:(FaunaContext*)current;

@end
