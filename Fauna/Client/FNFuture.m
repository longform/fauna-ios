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

@implementation FNFuture

# pragma mark Class Methods

+ (FNFuture *)value:(id)value {
  return [[FNValueFuture alloc] initWithValue:value];
}

+ (FNFuture *)error:(NSError *)error {
  return [[FNValueFuture alloc] initWithError:error];
}

+ (FNFuture *)background:(id (^)(void))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [[FNFuture sharedOperationQueue] addOperationWithBlock:^{
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
  return [self flattenMap:^(id value){ return [FNFuture value:block(value)]; }];
}

- (FNFuture *)flattenMap:(FNFuture *(^)(id))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [self onSuccess:^(id value){
    [block(value) onCompletion:^(FNFuture *next){ [next propagateTo:res]; }];
  } onError:^(NSError *error) {
    [res updateError:error];
  }];

  return res;
}

- (FNFuture *)rescue:(FNFuture * (^)(NSError *))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [self onCompletion:^(FNFuture *self){
    if (self.value) {
      [res update:self.value];
    } else {
      FNFuture *next = block(self.error);

      if (next) {
        [next onCompletion:^(FNFuture *next) { [next propagateTo:res]; }];
      } else {
        [res updateError:self.error];
      }
    }
  }];

  return res;
}

- (FNFuture *)ensure:(void (^)(void))block {
  FNMutableFuture *res = [FNMutableFuture new];

  [self onCompletion:^(FNFuture *self) {
    block();
    [self propagateTo: res];
  }];

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
