//
//  FNInstanceTest.m
//  Fauna
//
//  Created by Matt Freels on 3/15/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNMessage.h"

@interface FNInstanceTest : GHAsyncTestCase { }
@end

@implementation FNInstanceTest

- (void)testCreate {
  [self prepare];

  [FNResource registerClass:[FNMessage class]];

  FNInstance *inst = [FNMessage new];

  [TestPublisherContext() performInContext:^{
    [[inst save] onSuccess:^(FNInstance *value) {
      if ([value isKindOfClass:[FNMessage class]] &&
          value.ref &&
          [value.faunaClass isEqual:@"classes/messages"]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCreate)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end
