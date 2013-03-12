//
//  FNValueFuture.m
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNValueFuture.h"

@implementation FNValueFuture

- (id)initWithValue:(id)value andError:(NSError *)error {
  self = [super init];
  if (self) {
    _value = value;
    _error = error;
  }
  return self;
}

- (id)initWithValue:(id)value {
  if (value == nil) {
    [NSException raise:@"Invalid future value." format:@"Futures cannot contain a nil value."];
  }
  return [self initWithValue:value andError:nil];
}

- (id)initWithError:(NSError *)error {
  if (error == nil) {
    [NSException raise:@"Invalid future value." format:@"Futures cannot contain a nil error."];
  }
  return [self initWithValue:nil andError:error];
}

- (BOOL)isCompleted {
  return YES;
}

- (id)get {
  return self.value;
}

- (void)onCompletion:(void (^)(FNFuture *))block {
  block(self);
}

@end
