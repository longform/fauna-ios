//
//  FNMutableFuture.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNMutableFuture.h"

@interface FNMutableFuture ()

// Used as a signal for future completion
@property (nonatomic, readonly) NSOperation *completionOp;
@property (nonatomic, readonly) FNFuture *cancellationTarget;

// make read/write
@property id value;
@property NSError *error;
@property BOOL isCompleted;

@end

@implementation FNMutableFuture

- (id)init {
  if (self = [super init]) {
    _completionOp = [NSOperation new];
  }

  return self;
}

# pragma mark Accessors

- (id)get {
  [self.completionOp waitUntilFinished];
  return self.value;
}

- (void)cancel {
  [super cancel];
  [self.cancellationTarget cancel];
}

# pragma mark Non-Blocking and Functional API

- (void)onCompletion:(void (^)(FNFuture *))block {
  NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    block(self);
  }];

  NSOperationQueue *q = [NSOperationQueue currentQueue];
  q = q ?: [NSOperationQueue mainQueue];

  if (!self.isCompleted) {
    @synchronized(self) {
      if (!self.isCompleted) [op addDependency:self.completionOp];
      [q addOperation:op];
    }
  } else {
    [q addOperation:op];
  }
}


#pragma mark Mutable API

- (void)update:(id)value {
  if (![self updateIfEmpty:value]) {
    NSAssert(NO, @"Future was already completed.");
  }
}

- (void)updateError:(NSError *)error {
  if (![self updateErrorIfEmpty:error]) {
    NSAssert(NO, @"Future was already completed.");
  }
}

- (BOOL)updateIfEmpty:(id)value {
  return [self completeIfEmpty:value error:nil];
}

- (BOOL)updateErrorIfEmpty:(NSError *)error {
  return [self completeIfEmpty:nil error:error];
}

# pragma mark Private Methods

- (void)forwardCancellationsTo:(FNFuture *)other {
  _cancellationTarget = other;
}

- (void)operationWasCompleted {
  [self.completionOp start];
}

- (BOOL)completeIfEmpty:(id)value error:(NSError *)error {
  BOOL updated = NO;

  if (!self.isCompleted) {
    @synchronized(self) {
      if (!self.isCompleted) {
        self.value = value;
        self.error = error;
        self.isCompleted = YES;
        updated = YES;
      }
    }
  }

  if (updated) [self operationWasCompleted];

  return updated;
}

@end
