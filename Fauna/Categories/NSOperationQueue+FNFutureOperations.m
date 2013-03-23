//
// NSOperationQueue+FNFutureOperations.m
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

#import "NSOperationQueue+FNFutureOperations.h"
#import "FNMutableFuture.h"
#import "FNError.h"

@implementation NSOperationQueue (FNFutureOperations)

- (FNFuture *)futureOperationWithBlock:(id (^)(void))block {
  FNMutableFuture *res = [FNMutableFuture new];
  NSMutableDictionary *scope = [FNFutureScope saveCurrent];

  [self addOperationWithBlock:^{
    [FNFutureScope inScope:scope perform:^{
      id rv = res.isCancelled ? FNOperationCancelled() : block();

      if ([rv isKindOfClass:[NSError class]]) {
        [res updateError:rv];
      } else {
        [res update:rv];
      }
    }];
  }];

  return res;
}

@end
