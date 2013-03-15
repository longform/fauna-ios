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
