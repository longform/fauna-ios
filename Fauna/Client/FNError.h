//
//  FNError.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef FNError_h
#define FNError_h

FOUNDATION_EXPORT NSString * const FNErrorDomain;

FOUNDATION_EXPORT NSInteger const FNErrorOperationCancelledCode;
FOUNDATION_EXPORT NSInteger const FNErrorOperationFailedCode;
FOUNDATION_EXPORT NSInteger const FNErrorRequestTimeoutCode;
FOUNDATION_EXPORT NSInteger const FNErrorBadRequestCode;
FOUNDATION_EXPORT NSInteger const FNErrorNotFoundCode;
FOUNDATION_EXPORT NSInteger const FNErrorInternalServerErrorCode;

NSError * FNOperationCancelled();

NSError * FNOperationFailed();

NSError * FNRequestTimeout();

NSError * FNBadRequest(NSString *field, NSString *reason);

NSError * FNNotFound();

NSError * FNInternalServerError();

#endif