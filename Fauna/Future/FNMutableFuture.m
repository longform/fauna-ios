//
//  FNMutableFuture.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <pthread.h>
#import "FNMutableFuture.h"
#import "FNFuture_Internal.h"

@interface FNMutableFuture ()

// Used as a signal for future completion
@property (nonatomic, readonly) NSOperation *completionOp;
@property (nonatomic, readonly) FNFuture *cancellationTarget;
@property (nonatomic, readonly) pthread_mutex_t mutex;

// make read/write
@property id value;
@property NSError *error;
@property BOOL isCompleted;

@end

@implementation FNMutableFuture

- (id)init {
  if (self = [super init]) {
    _completionOp = [NSOperation new];
    if (pthread_mutex_init(&_mutex, NULL)) {
      return nil;
    }
  }

  return self;
}

- (void)dealloc {
  pthread_mutex_destroy(&_mutex);
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
  if (self.isCompleted) {
    block(self);
  } else {
    FNFutureLocal *scope = [FNFuture currentScope];
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
      [FNFutureLocal setCurrent:scope];
      block(self);
      [FNFutureLocal removeCurrent];
    }];

    NSOperationQueue *q = [NSOperationQueue currentQueue];
    q = q ?: [NSOperationQueue mainQueue];

    pthread_mutex_lock(&_mutex);
    if (!self.isCompleted) [op addDependency:self.completionOp];
    [q addOperation:op];
    pthread_mutex_unlock(&_mutex);
  }
}


#pragma mark Mutable API

- (void)update:(id)value {
  if (![self updateIfEmpty:value]) {
    [NSException raise:@"Future already completed." format:@"Future was already completed, but update was called with %@.", value];
  }
}

- (void)updateError:(NSError *)error {
  if (![self updateErrorIfEmpty:error]) {
    [NSException raise:@"Future already completed." format:@"Future was already completed, but updateError was called with %@.", error];
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
    pthread_mutex_lock(&_mutex);
    if (!self.isCompleted) {
      self.value = value;
      self.error = error;
      self.isCompleted = YES;
      updated = YES;
    }
    pthread_mutex_unlock(&_mutex);
  }

  if (updated) [self operationWasCompleted];

  return updated;
}

@end
