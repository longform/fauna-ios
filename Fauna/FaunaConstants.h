//
//  FaunaConstants.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#ifndef Fauna_FaunaConstants_h
#define Fauna_FaunaConstants_h

#define FaunaTLS [[NSThread currentThread] threadDictionary]

#import "NSError+FaunaErrors.h"

#define FaunaAPIVersion @"v1"

typedef void (^FaunaBlock)();

typedef id (^FaunaResultBlock)();

typedef id (^FaunaBackgroundBlock)();

typedef void (^FaunaResultsBlock)(id results);

typedef void (^FaunaErrorBlock)(NSError *error);

typedef void (^FaunaCacheScopeBlock)();

#endif
