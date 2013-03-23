//
// FNFuture.m
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

#import "FNFuture.h"
#import "FNMutableFuture.h"
#import "FNValueFuture.h"
#import "NSOperationQueue+FNFutureOperations.h"

NSException * FNInvalidFutureValue(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *reason = [NSString stringWithFormat:format, args];
  va_end(args);
  return [NSException exceptionWithName:@"FNInvalidFutureValue" reason:reason userInfo:@{}];
}

NSException * FNFutureAlreadyCompleted(NSString *method, id value) {
  NSString *reason = [NSString stringWithFormat:@"Future was already completed, but %@ was called with %@.", method, value];
  return [NSException exceptionWithName:@"FNFutureAlreadyCompleted" reason:reason userInfo:@{}];
}

static FNFuture * FNAccumulateHelper(NSArray *futures, int idx, id seed, id (^accumulator)(id accum, id value)) {
  if (idx >= futures.count) {
    return [FNFuture value:seed];
  } else {
    return [futures[idx] flatMap:^FNFuture *(id value) {
      return FNAccumulateHelper(futures, idx + 1, accumulator(seed, value), accumulator);
    }];
  }
}

FNFuture * FNFutureAccumulate(NSArray *futures, id seed, id (^accumulator)(id accum, id value)) {
  return FNAccumulateHelper(futures, 0, seed, accumulator);
}

FNFuture * FNFutureSequence(NSArray *futures) {
  return FNFutureAccumulate(futures, [NSMutableArray arrayWithCapacity:futures.count], ^id(NSMutableArray *arr, id value) {
    [arr addObject:value];
    return arr;
  });
}

FNFuture * FNFutureJoin(NSArray *futures) {
  return FNFutureAccumulate(futures, nil, ^(id accum, id __unused value) {
    return accum;
  });
}

@interface FNFuture ()

@property BOOL isCancelled;

@end

@interface FNMutableFuture ()

- (void)forwardCancellationsTo:(FNFuture *)other;

@end

@implementation FNFuture

# pragma mark Class Methods

+ (FNFuture *)value:(id)value {
  return [[FNValueFuture alloc] initWithValue:value];
}

+ (FNFuture *)error:(NSError *)error {
  return [[FNValueFuture alloc] initWithError:error];
}

+ (FNFuture *)inBackground:(id (^)(void))block {
  return [[FNFuture sharedOperationQueue] futureOperationWithBlock:block];
}

+ (FNFuture *)onMainThread:(id (^)(void))block {
  return [[NSOperationQueue mainQueue] futureOperationWithBlock:block];
}

+ (NSMutableDictionary *)currentScope {
  return [FNFutureScope currentScope];
}

# pragma mark Abstract methods

- (id)value {
  @throw @"not implemented";
}

- (NSError *)error {
  @throw @"not implemented";
}

- (BOOL)isCompleted {
  @throw @"not implemented";
}

- (BOOL)isError {
  @throw @"not implemented";
}

- (id)get {
  @throw @"not implemented";
}

- (void)onCompletion:(void (^)(FNFuture *))block {
  @throw @"not implemented";
}

# pragma mark API methods

- (void)cancel {
  self.isCancelled = YES;
}

# pragma mark Non-Blocking and Functional API

-(void)onSuccess:(void (^)(id value))succBlock onError:(void (^)(NSError *))errBlock {
  [self onCompletion:^(FNFuture *self){
    NSMutableDictionary *scope = [FNFutureScope saveCurrent];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [FNFutureScope inScope:scope perform:^{
        self.isError ? errBlock(self.error) : succBlock(self.value);
      }];
    }];
  }];
}

- (void)onSuccess:(void (^)(id value))block {
  [self onSuccess:block onError:^(id _){}];
}

- (void)onError:(void (^)(NSError *error))block {
  [self onSuccess:^(id _){} onError:block];
}

- (FNFuture *)map:(id (^)(id value))block {
  return [self flatMap:^(id value){
    return [FNFuture value:block(value)];
  }];
}

- (FNFuture *)map_:(id (^)(void))block {
  return [self map:^(id __unused value) { return block(); }];
}

- (FNFuture *)flatMap:(FNFuture *(^)(id value))block {
  return [self transform:^FNFuture *(FNFuture *self) {
    return self.value ? block(self.value) : self;
  }];
}

- (FNFuture *)flatMap_:(FNFuture *(^)(void))block {
  return [self flatMap:^(id __unused value) { return block(); }];
}

- (FNFuture *)done {
  return [self map_:^id{ return nil; }];
}

- (FNFuture *)rescue:(FNFuture *(^)(NSError *error))block {
  return [self transform:^FNFuture *(FNFuture *self) {
    if (self.value) {
      return self;
    } else {
      FNFuture *next = block(self.error);
      return next ? next : self;
    }
  }];
}

- (FNFuture *)ensure:(void (^)(void))block {
  return [self transform:^FNFuture *(FNFuture *self) {
    block();
    return self;
  }];
}

- (FNFuture *)transform:(FNFuture *(^)(FNFuture *result))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [self onCompletion:^(FNFuture *self) {
    FNFuture *next = block(self);

    if (next == nil) {
      @throw FNInvalidFutureValue(@"Result of future transformation cannot be nil.");
    }

    if (next.isCompleted) {
      [next propagateTo:res];
    } else {
      [next onCompletion:^(FNFuture *next) {
        [next propagateTo:res];
      }];
    }
  }];

  [res forwardCancellationsTo:self];

  return res;
}

# pragma mark Private Methods/Helpers

- (void)propagateTo:(FNMutableFuture *)other {
  if (self.value) {
    [other update:self.value];
  } else {
    [other updateError:self.error];
  }
}

+ (NSOperationQueue *)sharedOperationQueue {
  static NSOperationQueue *queue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = [NSOperationQueue new];
  });

  return queue;
}

@end
