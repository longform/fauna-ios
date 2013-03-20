//
//  FNContextTest.m
//  Fauna
//
//  Created by Matt Freels on 3/14/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

@interface FNContextTest : GHAsyncTestCase { }
@end

@implementation FNContextTest

- (void)testUsesDefaultContext {
  [self prepare];

  FNContext.defaultContext = TestPublisherContext();

  [[FNContext get:@"users"] onSuccess:^(id value) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesDefaultContext)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];

  FNContext.defaultContext = nil;
}

- (void)testUsesScopedContext {
  [self prepare];

  [TestPublisherContext() performInContext:^{
    [[FNContext get:@"users"] onSuccess:^(id value) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesScopedContext)];
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testStacksScopedContexts {
  [self prepare];

  FNContext *clientCtx = TestClientContext();
  FNContext *publisherCtx = TestPublisherContext();
  FNContext *pwContext = TestPublisherPasswordContext();

  FNContext.defaultContext = clientCtx;

  FNFuture *result = [[FNContext get:@"users"] rescue:^(NSError *error) {
    return [publisherCtx inContext:^{
      FNFuture *res1 = [FNContext get:@"users/sets"];

      FNFuture *resFail = [FNContext get:@"keys/publisher"];
      [resFail onSuccess:^(id value) {
        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testStacksScopedContexts)];
      }];

      FNFuture *res2 = [resFail rescue:^(NSError *error) {
        return [pwContext inContext:^{
          return [FNContext get:@"keys/publisher"];
        }];
      }];

      if (![FNContext.currentContext isEqual:publisherCtx]) {
        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testStacksScopedContexts)];
      }

      FNFuture *res3 = [FNContext get:@"classes"];

      return [res1 flatMap:^(id sets) {
        return [res2 flatMap:^(id keys) {
          return [res3 map:^(id classes) {
            return @"yay!";
          }];
        }];
      }];
    }];
  }];

  [result onSuccess:^(id value) {
    if ([value isEqual:@"yay!"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testStacksScopedContexts)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];

  FNContext.defaultContext = nil;
}

- (void)testRaisesOnNoContext {
  [self prepare];

  FNContext.defaultContext = nil;

  @try {
    [FNContext get:@"users"];
    GHFail(@"Did not throw any exception");
  } @catch (NSException *e) {
    GHAssertEqualStrings(e.name, FNContextNotDefined().name, @"Did not throw FNContextNotDefined");
  }
}

@end
