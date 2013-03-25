//
// FNFutureTest.m
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

#import <Fauna/FNMutableFuture.h>
#import <Fauna/FNError.h>

@interface FNFutureTest : GHAsyncTestCase { }
@end

@implementation FNFutureTest

- (void)testWait {
  id result;
  NSError *err;

  FNFuture *res = [FNFuture inBackground:^{
    return @"foo";
  }];

  GHAssertTrue([res waitForResult:&result error:&err], @"future did not finish successfullly");
  GHAssertEquals(result, @"foo", @"result did match expected value");

  result = nil;
  err = nil;

  FNFuture *fail = [FNFuture inBackground:^{
    return [NSError errorWithDomain:@"fail" code:0 userInfo:@{}];
  }];

  GHAssertFalse([fail waitForResult:&result error:&err], @"future did not fail");
  GHAssertEquals(err.domain, @"fail", @"result did match expected value");
}

- (void)testOnCompletion {
  [self prepare];

  [[FNFuture inBackground:^{
    return @"foo";
  }] onCompletion:^(FNFuture *result) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOnCompletion)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testOnSuccess {
  [self prepare];

  [[FNFuture inBackground:^{
    return @"foo";
  }] onSuccess:^(id value) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOnSuccess)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testOnError {
  [self prepare];

  [[FNFuture inBackground:^{
    return [NSError new];
  }] onError:^(NSError *error) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOnError)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testCanHoldNil {
  [self prepare];

  [[FNFuture inBackground:^id{
    return nil;
  }] onSuccess:^(id value) {
    if (!value) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCanHoldNil)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testMap {
  [self prepare];

  [[[[[FNFuture inBackground:^{
    return @"foo";
  }] map:^NSString *(NSString *value) {
    return [NSString stringWithFormat:@"%@ %@", value, @"bar"];
  }] map:^id(id value) {
    return [NSString stringWithFormat:@"%@ %@", value, @"baz"];
  }] map:^id(id value) {
    return [NSString stringWithFormat:@"%@ %@", value, @"qux"];
  }] onSuccess:^(NSString *value) {
    if ([value isEqual: @"foo bar baz qux"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testMap)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testFlatMap {
  [self prepare];

  [[[FNFuture value:@"foo"] flatMap:^FNFuture *(id value) {
    return [FNFuture error:
            [NSError errorWithDomain:@"TestError"
                                code:1
                            userInfo:@{@"reason": [NSString stringWithFormat:@"was %@", value]}]];
  }] onError:^(NSError *error) {
    if ([[error userInfo][@"reason"] isEqual:@"was foo"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testFlatMap)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testCancellation {
  [self prepare];

  FNMutableFuture *res = [FNMutableFuture new];

  [FNFuture inBackground:^{
    usleep(10000);
    if (res.isCancelled) {
      [res updateError:FNOperationCancelled()];
    } else {
      [res update:@"no cancel :("];
    }

    return @"done";
  }];

  [res onError:^(NSError *error) {
    if (error.code == FNErrorOperationCancelledCode) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCancellation)];
    }
  }];

  [res cancel];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testFutureScope {
  [self prepare];

  FNFuture.currentScope[@"val"] = @"right";

  [[FNFuture inBackground:^{
    usleep(10000);
    return FNFuture.currentScope[@"val"];
  }] onSuccess:^(id value) {
    if ([value isEqual:@"right"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testFutureScope)];
    }
  }];

  FNFuture.currentScope[@"val"] = @"wrong";

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testNeverDeadlocksOnMain {
  [self prepare];

  [[FNFuture onMainThread:^id{
    FNFuture *f = [[FNFuture inBackground:^{
      usleep(10000);
      return @"done";
    }] map:^(NSString *done) {
      usleep(10000);
      return [done stringByAppendingString:@" and done"];
    }];

    [f wait];

    return nil;
  }] onSuccess:^(id __unused value) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testNeverDeadlocksOnMain)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

@end
