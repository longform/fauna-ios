//
//  FaunaSecurityToken.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResource.h"

/*!
 Fauna Abstract Token.
 
 See https://fauna.org/API#access_model-tokens
 */
@interface FaunaToken : FaunaResource

/*!
 (token/key) The Actual Token Code.
 */
@property (nonatomic, strong) NSString *code;

@end
