//
//  FaunaCommand.h
//  Fauna
//
//  Created by Johan Hernandez on 12/30/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaConstants.h"

@interface FaunaCommands : NSObject

- (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block;

@end
