//
//  FaunaResult.m
//  Fauna
//
//  Created by Matt Freels on 3/9/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaError.h"
#import "FaunaResult.h"
#import "FaunaMutableResult.h"

@implementation FaunaResult

# pragma mark Class Methods

+ (FaunaResult *)value:(id)value {
  FaunaMutableResult *res = [FaunaMutableResult new];
  [res update:value];
  return res;
}

+ (FaunaResult *)error:(NSError *)error {
  FaunaMutableResult *res = [FaunaMutableResult new];
  [res updateError:error];
  return res;
}

+ (FaunaResult *)background:(id (^)(void))block {
  FaunaMutableResult *res = [FaunaMutableResult new];

  [[FaunaResult sharedOperationQueue] addOperationWithBlock:^{
    id rv = block();

    rv = rv ?: FaunaOperationFailed();

    if ([rv isKindOfClass:[NSError class]]) {
      [res updateError:rv];
    } else {
      [res update:rv];
    }
  }];

  return res;
}

# pragma mark Blocking API

// Implemented in FaunaMutableResult
- (id)get {
  return nil;
}

# pragma mark Non-Blocking and Functional API

// Implemented in FaunaMutableResult
- (void)onCompletion:(void (^)(FaunaResult *))block {

}

-(void)onSuccess:(void (^)(id))succBlock onError:(void (^)(NSError *))errBlock {
  [self onCompletion:^(FaunaResult *self){
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

- (FaunaResult *)map:(id (^)(id))block {
  return [self flattenMap:^(id value){ return [FaunaResult value:value]; }];
}

- (FaunaResult *)flattenMap:(FaunaResult *(^)(id))block {
  FaunaMutableResult *res = [FaunaMutableResult new];

  [self onSuccess:^(id value){
    [block(value) onCompletion:^(FaunaResult *next){ [next propagateTo:res]; }];
  }];

  return res;
}

- (FaunaResult *)rescue:(FaunaResult * (^)(NSError *))block {
  FaunaMutableResult *res = [FaunaMutableResult new];

  [self onCompletion:^(FaunaResult *self){
    if (self.value) {
      [res update:self.value];
    } else {
      FaunaResult *next = block(self.error);

      if (next) {
        [next onCompletion:^(FaunaResult *next) { [next propagateTo:res]; }];
      } else {
        [res updateError:self.error];
      }
    }
  }];

  return res;
}

- (FaunaResult *)ensure:(void (^)(void))block {
  FaunaMutableResult *res = [FaunaMutableResult new];

  [self onCompletion:^(FaunaResult *self) {
    block();
    [self propagateTo: res];
  }];

  return res;
}

# pragma mark Private Methods/Helpers

- (void)propagateTo:(FaunaMutableResult *)other {
  if (self.value) {
    [other update:self.value];
  } else {
    [other updateError:self.error];
  }
}

+ (NSOperationQueue *)sharedOperationQueue {
  static NSOperationQueue *queue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ queue = [NSOperationQueue new]; });

  return queue;
}

@end
