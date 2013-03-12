//
//  FaunaError.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaError.h"

NSString * const FaunaErrorDomain = @"org.fauna";

NSInteger const FaunaErrorOperationCancelledCode = 0;
NSInteger const FaunaErrorOperationFailedCode = 1;
NSInteger const FaunaErrorRequestTimeoutCode = 2;
NSInteger const FaunaErrorBadRequestCode = 400;
NSInteger const FaunaErrorNotFoundCode = 404;
NSInteger const FaunaErrorInternalServerErrorCode = 500;

NSError *FaunaOperationCancelled() {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorOperationCancelledCode
                         userInfo:@{}];
}

NSError *FaunaOperationFailed() {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorOperationFailedCode
                         userInfo:@{}];
}

NSError *FaunaRequestTimeout() {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorRequestTimeoutCode
                         userInfo:@{}];
}

NSError *FaunaBadRequest(NSString *field, NSString *reason) {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorBadRequestCode
                         userInfo:@{ @"field": field, @"error": reason}];
}

NSError *FaunaNotFound() {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorNotFoundCode
                         userInfo:@{}];
}

NSError *FaunaInternalServerError() {
  return [NSError errorWithDomain:FaunaErrorDomain
                             code:FaunaErrorInternalServerErrorCode
                         userInfo:@{}];
}