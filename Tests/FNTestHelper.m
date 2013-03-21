//
// FNTestHelper.m
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

#import <libkern/OSAtomic.h>
#import "FNTestHelper.h"

FNContext * TestClientContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithKey:FAUNA_TEST_CLIENT_KEY];
  });

  return ctx;
}

FNContext * TestPublisherContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY];
  });

  return ctx;
}

FNContext * TestPublisherPasswordContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithPublisherEmail:FAUNA_TEST_EMAIL password:FAUNA_TEST_PASSWORD];
  });

  return ctx;
}

NSInteger TestUniqueStamp() {
  static int64_t stamp;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    stamp = [[NSDate date] timeIntervalSince1970];
  });

  return OSAtomicIncrement64(&stamp);
}

NSString * TestUniqueID() {
  return [NSString stringWithFormat:@"uid%d", TestUniqueStamp()];
}

NSString * TestUniqueEmail() {
  return [NSString stringWithFormat:@"email%d@example.com", TestUniqueStamp()];
}
