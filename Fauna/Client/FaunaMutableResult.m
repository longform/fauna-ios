//
//  FaunaMutableResult.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaMutableResult.h"

@interface FaunaMutableResult ()

// Used as a signal for future completion
@property (nonatomic, readonly) NSOperation *completionOp;
@property (nonatomic, readonly) NSLock *lock;

// make read-write
@property id value;
@property NSError *error;
@property BOOL isCompleted;

@end

@implementation FaunaMutableResult

- (id)init {
  if (self = [super init]) {
    _completionOp = [NSOperation new];
    _lock = [NSLock new];
    self.isCompleted = NO;
  }

  return self;
}

#pragma mark Blocking API

- (id)get {
  [self.completionOp waitUntilFinished];
  return self.value;
}

# pragma mark Non-Blocking and Functional API

- (void)onCompletion:(void (^)(FaunaResult *))block {
  FaunaResult * __weak _self = self; // FIXME: use EXTScope's @weakify here
  NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    block(_self);
  }];

  if (!self.isCompleted) {
    [self.lock lock];
    if (!self.isCompleted) [op addDependency:self.completionOp];
    [[NSOperationQueue mainQueue] addOperation:op];
    [self.lock unlock];
  } else {
    [[NSOperationQueue mainQueue] addOperation:op];
  }
}


#pragma mark Mutable API

- (void)update:(id)value {
  if (![self updateIfEmpty:value]) {
    NSAssert(NO, @"Result was already completed.");
  }
}

- (void)updateError:(NSError *)error {
  if ([self updateErrorIfEmpty:error]) {
    NSAssert(NO, @"Result was already completed.");
  }
}

- (BOOL)updateIfEmpty:(id)value {
  return [self completeIfEmpty:value error:nil];
}

- (BOOL)updateErrorIfEmpty:(NSError *)error {
  return [self completeIfEmpty:nil error:error];
}

# pragma mark Private Methods

- (void)operationWasCompleted {
  [[NSOperationQueue mainQueue] addOperation:self.completionOp];
}

- (BOOL)completeIfEmpty:(id)value error:(NSError *)error {
  BOOL updated = NO;

  if (!self.isCompleted) {
    [self.lock lock];
    if (!self.isCompleted) {
      self.value = value;
      self.error = error;
      self.isCompleted = YES;
      updated = YES;
    }
    [self.lock unlock];
  }

  if (updated) [self operationWasCompleted];

  return updated;
}

@end
