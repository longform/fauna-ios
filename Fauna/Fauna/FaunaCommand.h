//
//  FaunaCommand.h
//  Fauna
//
//  Created by Johan Hernandez on 12/30/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaContext.h"
#import "FaunaConstants.h"

@interface FaunaCommand : NSObject

/*!
 Executes a the given command.
 @param commandName Command Name. (required)
 @param params Command Parameters to be sent. (optional)
 @param callback FaunaResponseResultBlock result block. (required)
 */
+ (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block;

/*!
 Executes a the given command.
 @param commandName Command Name. (required)
 @param params Command Parameters to be sent. (optional)
 @param context FaunaContext to use. (required)
 @param callback FaunaResponseResultBlock result block. (required)
 */
+ (void)execute:(NSString*)commandName params:(NSDictionary*)params context:(FaunaContext*)context callback:(FaunaResponseResultBlock)block;

@end
