//
//  FNFuture.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNFuture : NSObject

# pragma mark Class Methods

+ (FNFuture *)value:(id)value;

+ (FNFuture *)error:(NSError *)error;

+ (FNFuture *)inBackground:(id (^)(void))block;

+ (FNFuture *)onMainThread:(id (^)(void))block;

# pragma mark Accessors

/*!
 Returns the result of the operation represented by this object if set.
 */
- (id)value;

/*!
 Returns the error result of the operation represented by this object if set.
 */
- (NSError *)error;

/*!
 Returns whether or not the operation has been completed.
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
 Sends a cancellation signal upstream. The future's source may or may not respond to the cancellation signal.
 */
- (void)cancel;

# pragma mark Non-Blocking and Functional API

/*!
 Subscribe to both successful completion and error events.
 */
- (void)onSuccess:(void (^)(id value))succBlock onError:(void (^)(NSError *error))errBlock;

/*!
 Subscribe to successful completion.
 */
- (void)onSuccess:(void (^)(id value))block;

/*!
 Subscribe to error event.
 */
- (void)onError:(void (^)(NSError *error))block;

/*!
 Subscribe to completion.
 */
- (void)onCompletion:(void (^)(FNFuture *result))block;

/*!
 Return a new result object that, upon completion of this one, contains the value transformed with the provided block.
 */
- (FNFuture *)map:(id (^)(id value))block;

- (FNFuture *)flatMap:(FNFuture * (^)(id value))block;

/*!
 Returns a new result object that attempts to recover from errors with the provided block. The block should return a new result object or nil (to propagate the error).
 */
- (FNFuture *)rescue:(FNFuture * (^)(NSError *))block;

- (FNFuture *)ensure:(void (^)(void))block;

@end
