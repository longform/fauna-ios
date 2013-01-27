//
//  FaunaConstants.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#ifndef Fauna_FaunaConstants_h
#define Fauna_FaunaConstants_h

#import "FaunaResponse.h"
#import "NSError+FaunaErrors.h"

#define FaunaAPIVersion @"v0"

typedef void (^FaunaResponseResultBlock)(FaunaResponse* response, NSError *error);

typedef void (^FaunaSimpleResultBlock)(NSError *error);

#endif
