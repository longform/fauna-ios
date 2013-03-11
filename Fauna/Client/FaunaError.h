//
//  FaunaError.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef FaunaError_h
#define FaunaError_h

FOUNDATION_EXPORT NSString * const FaunaErrorDomain;

FOUNDATION_EXPORT NSInteger const FaunaErrorOperationFailedCode;
FOUNDATION_EXPORT NSInteger const FaunaErrorRequestTimeoutCode;
FOUNDATION_EXPORT NSInteger const FaunaErrorBadRequestCode;
FOUNDATION_EXPORT NSInteger const FaunaErrorNotFoundCode;
FOUNDATION_EXPORT NSInteger const FaunaErrorInternalServerErrorCode;

NSError * FaunaOperationFailed();

NSError * FaunaRequestTimeout();

NSError * FaunaBadRequest(NSString *field, NSString *reason);

NSError * FaunaNotFound();

NSError * FaunaInternalServerError();

#endif