//
//  FaunaResult.h
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaunaResult : NSObject

# pragma mark Class Methods

+ (FaunaResult *)value:(id)value;

+ (FaunaResult *)error:(NSError *)error;

+ (FaunaResult *)background:(id (^)(void))block;

# pragma mark Blocking API

/*!
 Returns the result of the operation represented by this object or nil, if there was an error, blocking if necessary.
 */
- (id)get;

/*!
 Returns the result of the operation represented by this object if set.
 */
@property (readonly) id value;

/*!
 Returns the error result of the operation represented by this object if set.
 */
@property (readonly) NSError *error;

/*!
 Returns whether or not the operation has been completed.
 */
@property (readonly) BOOL isCompleted;

# pragma mark Non-Blocking and Functional API

/*!
 Subscribe to both successful completion and error events.
 */
- (void)onSuccess:(void (^)(id value)) succBlock onError:(void (^)(NSError *error)) errBlock;

/*!
 Subscribe to successful completion.
 */
- (void)onSuccess:(void (^)(id value)) block;

/*!
 Subscribe to error event.
 */
- (void)onError:(void (^)(NSError *error)) block;

/*!
 Subscribe to completion.
 */
- (void)onCompletion:(void (^)(FaunaResult *result)) block;

/*!
 Return a new result object that, upon completion of this one, contains the value transformed with the provided block.
 */
- (FaunaResult *)map:(id (^)(id value)) block;

- (FaunaResult *)flattenMap:(FaunaResult * (^)(id value)) block;

/*!
 Returns a new result object that attempts to recover from errors with the provided block. The block should return a new result object or nil (to propagate the error).
 */
- (FaunaResult *)rescue:(FaunaResult * (^)(NSError *)) block;

- (FaunaResult *)ensure:(void (^)(void)) block;

@end
