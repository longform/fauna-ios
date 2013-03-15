//
//  FNError.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNError.h"

NSString * const FNErrorDomain = @"org.fauna";

NSInteger const FNErrorOperationCancelledCode = 0;
NSInteger const FNErrorOperationFailedCode = 1;
NSInteger const FNErrorRequestTimeoutCode = 2;
NSInteger const FNErrorBadRequestCode = 400;
NSInteger const FNErrorNotFoundCode = 404;
NSInteger const FNErrorInternalServerErrorCode = 500;

NSError * FNOperationCancelled() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorOperationCancelledCode
                         userInfo:@{}];
}

NSError * FNOperationFailed() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorOperationFailedCode
                         userInfo:@{}];
}

NSError * FNRequestTimeout() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorRequestTimeoutCode
                         userInfo:@{}];
}

NSError * FNBadRequest(NSString *field, NSString *reason) {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorBadRequestCode
                         userInfo:@{ @"field": field, @"error": reason}];
}

NSError * FNNotFound() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorNotFoundCode
                         userInfo:@{}];
}

NSError * FNInternalServerError() {
  return [NSError errorWithDomain:FNErrorDomain
                             code:FNErrorInternalServerErrorCode
                         userInfo:@{}];
}

NSException * FNContextNotDefined() {
  return [NSException exceptionWithName:@"FNContextNotDefined" reason:@"No default or scoped context defined." userInfo:@{}];
}

NSException * FNInvalidResource(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *reason = [NSString stringWithFormat:format, args];
  va_end(args);
  return [NSException exceptionWithName:@"FNInvalidResource" reason:reason userInfo:@{}];
}