//
//  FaunaSecurityToken.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaConstants.h"

/*!
 Fauna User Token.
 
 See https://fauna.org/API#access_model-tokens
 */
@interface FaunaTokens : NSObject

- (void)create:(NSDictionary*)credentials block:(FaunaResponseResultBlock)block;

@end
