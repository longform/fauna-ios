//
//  FaunaInstance.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResource.h"

@interface FaunaInstance : FaunaResource

+ (FaunaInstance*)get:(NSString *)ref error:(NSError**)error;

@end
