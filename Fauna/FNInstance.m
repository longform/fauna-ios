//
// FNInstance.m
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

#import "FNError.h"
#import "FNFuture.h"
#import "FNEventSet.h"
#import "FNContext.h"
#import "FNInstance.h"

@implementation FNInstance

+ (FNEventSet *)all {
  if (!self.faunaClass) {
    @throw FNInvalidResourceClass(@"+faunaClass is not defined on %@.", self);
  }

  return [FNEventSet eventSetWithRef:self.faunaClass];
}

+ (BOOL)allowNewResources {
  return YES;
}

- (FNFuture *)destroy {
  return [FNContext deleteResource:self.ref].done;
}

@end
