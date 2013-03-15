//
//  FNContextTest.m
//  Fauna
//
//  Created by Matt Freels on 3/14/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FNContext.h>
#import "FaunaCredentials.h"

@interface FNContextTest : GHAsyncTestCase { }
@end

@implementation FNContextTest

- (void)testUsesDefaultContext {
  [self prepare];

  FNContext *ctx = [FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY];
  FNContext.defaultContext = ctx;

  [[FNContext get:@"users"] onSuccess:^(id value) {
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesDefaultContext)];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testUsesScopedContext {
  [self prepare];

  [[FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY] performInContext:^{
    [[FNContext get:@"users"] onSuccess:^(id value) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testUsesScopedContext)];
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testStacksScopedContexts {
  [self prepare];

  FNContext *clientCtx = [FNContext contextWithKey:FAUNA_TEST_CLIENT_KEY];
  FNContext *publisherCtx = [FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY];
  FNContext *pwContext = [FNContext contextWithPublisherEmail:FAUNA_TEST_EMAIL password:FAUNA_TEST_PASSWORD];

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

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
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
