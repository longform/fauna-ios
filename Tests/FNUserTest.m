//
//  FNUserTest.m
//  Fauna
//
//  Created by Matt Freels on 3/15/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

@interface FNUserTest : GHAsyncTestCase { }
@end

@implementation FNUserTest

- (void)testCreate {
  [self prepare];

  [TestPublisherContext() performInContext:^{
    FNUser *user = [FNUser new];
    user.uniqueID = TestUniqueID();

    [[user save] onSuccess:^(FNUser *user) {
      if ([user isKindOfClass:[FNUser class]] && user.ref) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCreate)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testSelf {
  [self prepare];

  [TestClientContext() performInContext:^{
    FNUser *user = [FNUser new];
    user.uniqueID = TestUniqueID();
    user.password = @"sekrit";

    [[[[user save] flatMap:^(FNUser *user) {
      return [FNUser contextForUniqueID:user.uniqueID password:@"sekrit"];
    }] flatMap:^(FNContext *ctx) {
      return [ctx inContext:^{
        return [FNUser getSelf];
      }];
    }] onSuccess:^(FNUser *selfUser) {
      if ([selfUser.uniqueID isEqualToString:user.uniqueID]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSelf)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

- (void)testConfig {
  [self prepare];

  [TestClientContext() performInContext:^{
    FNUser *user = [FNUser new];
    NSString *email = TestUniqueEmail();
    user.email = email;
    user.password = @"sekrit";

    [[[[user save] flatMap:^(FNUser *user) {
      return [FNUser contextForEmail:email password:@"sekrit"];
    }] flatMap:^(FNContext *ctx) {
      return [ctx inContext:^{
        return [FNUser getSelfConfig];
      }];
    }] onSuccess:^(FNResource *config) {
      if ([config.dictionary[@"email"] isEqualToString:email]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testConfig)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end
