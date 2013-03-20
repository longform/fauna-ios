//
//  FNFuture.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFutureScope.h"

@class FNFuture;

NSException * FNInvalidFutureValue(NSString *format, ...);

NSException * FNFutureAlreadyCompleted(NSString *method, id value);

FOUNDATION_EXPORT NSObject * const FNUnit;

FNFuture * FNAccumulate(NSArray *futures, id seed, id (^accumulator)(id accum, id value));

/*!
 Returns a new future that contains an array of the results of the passed in array of futures.
 */
FNFuture * FNSequence(NSArray *futures);

FNFuture * FNJoin(NSArray *futures);

@interface FNFuture : NSObject

# pragma mark Class methods

/*!
 Returns a successful future completed with the provided value. The provided value must not be nil.
 */
+ (FNFuture *)value:(id)value;

/*!
 Returns a failed future completed with the provided error. The provided error must not be nil.
 */
+ (FNFuture *)error:(NSError *)error;

/*!
 Runs a computation on a background thread and returns a future of the result. The provided block should return a non-nil value or an NSError if it failed.
 */
+ (FNFuture *)inBackground:(id (^)(void))block;

/*!
 Runs a computation on the main thread and returns a future of the result. The provided block should return a non-nil value or an NSError if it failed.
 */
+ (FNFuture *)onMainThread:(id (^)(void))block;

/*! 
 Returns the future-local storage for the current scope. May be shared across threads.
 */
+ (NSMutableDictionary *)currentScope;

# pragma mark Instance methods

/*!
 Returns the result of the future represented if set.
 */
- (id)value;

/*!
 Returns the error result of the future represented if set.
 */
- (NSError *)error;

/*!
 Returns whether or not the future has been completed.
 */
- (BOOL)isCompleted;

/*!
 Returns whether or not the operation has been cancelled.
 */
- (BOOL)isCancelled;

/*!
 Returns the result of the operation represented by this object or nil, if there was an error, blocking if necessary.
 */
- (id)get;

/*!
 Sends a cancellation signal upstream. The future's source may or may not respond to cancellation.
 */
- (void)cancel;

# pragma mark Non-Blocking and Functional API

/*!
 Add callbacks upon success or failure of the future. The applied callback will run on the main thread.
 */
- (void)onSuccess:(void (^)(id value))succBlock onError:(void (^)(NSError *error))errBlock;

/*!
 Add a callback to run upon success of the future. The callback will run on the main thread.
 */
- (void)onSuccess:(void (^)(id value))block;

/*!
 Add a callback to run upon failure of the future. The callback will run on the main thread.
 */
- (void)onError:(void (^)(NSError *error))block;

/*!
 Add a callback to run upon completion of the future. The callback will run on an unspecified thread.
 */
- (void)onCompletion:(void (^)(FNFuture *result))block;

/*!
 Returns a new future that contains this future's value transformed by the provided block. The block will run on an unspecified thread.
 */
- (FNFuture *)map:(id (^)(id value))block;

/*!
 Returns a new future that contains the result of the future returned by the provided block if this future is successful, or this future's error. The block will run on an unspecified thread.
 */
- (FNFuture *)flatMap:(FNFuture * (^)(id value))block;

/*!
 Returns a new result object that attempts to recover from errors with the provided block. The block should return a new result object or nil (to propagate the error). The block will run on an unspecified thread.
 */
- (FNFuture *)rescue:(FNFuture * (^)(NSError *error))block;

/*!
 Returns a new future with the same result this one, but which is completed after running the provided block. The block will run on an unspecified thread.
 */
- (FNFuture *)ensure:(void (^)(void))block;

/*!
 Returns a new future with the result of transforming this one. The block will run on an unspecified thread.
 */
- (FNFuture *)transform:(FNFuture *(^)(FNFuture *result))block;

@end
