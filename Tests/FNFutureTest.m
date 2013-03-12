//
//  FNFutureTest.m
//  Fauna
//
//  Created by Matt Freels on 3/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FNFuture.h>
#import <Fauna/FNMutableFuture.h>
#import <Fauna/FaunaError.h>


@interface FNFutureTest : GHAsyncTestCase { }
@end

@implementation FNFutureTest

- (void)testGet {
  FNFuture *res = [FNFuture inBackground:^{
    return @"foo";
  }];

  GHAssertEquals(@"foo", res.get, @"result did match expected value");
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

- (void)testFlattenMap {
  [self prepare];

  [[[FNFuture value:@"foo"] flattenMap:^FNFuture *(id value) {
    return [FNFuture error:
            [NSError errorWithDomain:@"TestError"
                                code:1
                            userInfo:@{@"reason": [NSString stringWithFormat:@"was %@", value]}]];
  }] onError:^(NSError *error) {
    if ([[error userInfo][@"reason"] isEqual:@"was foo"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testFlattenMap)];
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
      [res updateError:FaunaOperationCancelled()];
    } else {
      [res update:@"no cancel :("];
    }

    return @"done";
  }];

  [res onError:^(NSError *error) {
    if (error.code == FaunaErrorOperationCancelledCode) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCancellation)];
    }
  }];

  [res cancel];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

@end
