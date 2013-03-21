//
// FNMutableFuture.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
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
  if (self.isCompleted) {
    block(self);
  } else {
    NSMutableDictionary *scope = [FNFutureScope saveCurrent];
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
      [FNFutureScope inScope:scope perform:^{ block(self); }];
    }];

    NSOperationQueue *q = [NSOperationQueue currentQueue];
    q = q ?: [NSOperationQueue mainQueue];

    @synchronized (self) {
      if (!self.isCompleted) [op addDependency:self.completionOp];
      [q addOperation:op];
    }
  }
}


#pragma mark Mutable API

- (void)update:(id)value {
  if (![self updateIfEmpty:value]) {
    @throw FNFutureAlreadyCompleted(@"update", value);
  }
}

- (void)updateError:(NSError *)error {
  if (![self updateErrorIfEmpty:error]) {
    @throw FNFutureAlreadyCompleted(@"updateError", error);
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
    @synchronized (self) {
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
