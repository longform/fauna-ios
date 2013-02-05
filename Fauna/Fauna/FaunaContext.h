//
//  FaunaContext.h
//  Fauna
//
//  Created by Johan Hernandez on 2/5/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaConstants.h"

/*!
 Fauna API Context
 */
@interface FaunaContext : NSObject

/*!
 Returns the FaunaContext for the Application
 */
+ (FaunaContext*)applicationContext;

/*!
 Sets the FaunaContet instance for the Application
 */
+ (void)setDefaultApplicationContext:(FaunaContext*)context;

/*!
 Returns a FaunaContext, resolving to applicationContext if scopeContext is not available.
 */
+ (FaunaContext*)current;

/*!
 Returns the context for the current scope.
 */
+ (FaunaContext*)scopeContext;

/*!
 Runs a code block in the current context.
 @param block The block to be executed in the context.
 */
- (void)scoped:(FaunaBlock)block;

/*!
 Runs the given block in background and executes a callback when the results are ready.
 @param backgroundBlock The code block to be executed in background. You can perform syncrhonous/blocking calls in this block.
 @param resultsBlock The code block to execute when the background block finishes. You can update your User Interface here.
 */
- (void)run:(FaunaRunBlock)backgroundBlock results:(FaunaResultsBlock)resultsBlock;

/*!
 Using current, runs the given block in background and executes a callback when the results are ready.
 @param backgroundBlock The code block to be executed in background. You can perform syncrhonous/blocking calls in this block.
 @param resultsBlock The code block to execute when the background block finishes. You can update your User Interface here.
 */
+ (void)run:(FaunaRunBlock)backgroundBlock results:(FaunaResultsBlock)resultsBlock;


@end
