//
//  FaunaCommand.h
//  Fauna
//
//  Created by Johan Hernandez on 2/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNResource.h"

@interface FaunaCommand : NSObject

/*!
 Executes a Command without parameters.
 @param commandName Name of the Command to Execute
 @param params Parameter of the Command
 @param error Any error found in the execution of the command
 */
+ (FNResource*)execute:(NSString*)commandName error:(NSError**)error;

/*!
 Executes a Command with parameters.
 @param commandName Name of the Command to Execute
 @param params Parameter of the Command
 @param error Any error found in the execution of the command
 */
+ (FNResource*)execute:(NSString*)commandName params:(NSDictionary*)params error:(NSError**)error;

@end
