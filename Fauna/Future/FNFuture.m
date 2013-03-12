//
//  FNFuture.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"
#import "FNValueFuture.h"
#import "NSOperationQueue+FNFutureOperations.h"

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

# pragma mark Abstract Methods

- (id)value {
  return nil;
}

- (NSError *)error {
  return nil;
}

- (BOOL)isCompleted {
  return NO;
}

- (id)get {
  return nil;
}

- (void)onCompletion:(void (^)(FNFuture *))block {

}

- (void)cancel {
  self.isCancelled = YES;
}

# pragma mark Non-Blocking and Functional API

-(void)onSuccess:(void (^)(id))succBlock onError:(void (^)(NSError *))errBlock {
  [self onCompletion:^(FNFuture *self){
    if (self.value) {
      succBlock(self.value);
    } else {
      errBlock(self.error);
    }
  }];
}

- (void)onSuccess:(void (^)(id))block {
  [self onSuccess:block onError:^(id _){}];
}

- (void)onError:(void (^)(NSError *))block {
  [self onSuccess:^(id _){} onError:block];
}

- (FNFuture *)map:(id (^)(id))block {
  return [self flatMap:^(id value){ return [FNFuture value:block(value)]; }];
}

- (FNFuture *)flatMap:(FNFuture *(^)(id))block {
  return [self transform:^FNFuture *(FNFuture *self) {
    return self.value ? block(self.value) : self;
  }];
}

- (FNFuture *)rescue:(FNFuture *(^)(NSError *))block {
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

# pragma mark Private Methods/Helpers

- (FNFuture *)transform:(FNFuture *(^)(FNFuture *))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [self onCompletion:^(FNFuture *self) {
    FNFuture *next = block(self);

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
