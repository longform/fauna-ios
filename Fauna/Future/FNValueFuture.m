//
// FNValueFuture.m
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
    @throw FNInvalidFutureValue(@"Futures cannot contain a nil value.");
  }
  return [self initWithValue:value andError:nil];
}

- (id)initWithError:(NSError *)error {
  if (error == nil) {
    @throw FNInvalidFutureValue(@"Futures cannot contain a nil error.");
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
