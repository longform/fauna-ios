//
//  FNUserTest.m
//  Fauna
//
//  Created by Matt Freels on 3/15/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/Fauna.h>
#import "FaunaCredentials.h"

@interface FNUserTest : GHAsyncTestCase { }
@end

@implementation FNUserTest

- (void)testCreate {
  [self prepare];

  [[FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY] performInContext:^{
    FNUser *user = [FNUser new];

    [[user save] onSuccess:^(FNUser *user) {
      NSLog(@"user: %@", user);
      if (user.ref) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCreate)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

@end
