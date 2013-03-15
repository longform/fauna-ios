//
//  FNClientTest.m
//  Fauna
//
//  Created by Matt Freels on 3/13/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FNClient.h>
#import "FaunaCredentials.h"

@interface FNClientTest : GHAsyncTestCase { }
@end

@implementation FNClientTest

- (void)testGet {
  [self prepare];

  FNClient *client = [[FNClient alloc] initWithKey:FAUNA_TEST_PUBLISHER_KEY];
  //client.logHTTPTraffic = YES;

  [[client get:@"users"] onSuccess:^(id value) {
    if ([value isKindOfClass:[FNResponse class]]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testGet)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end
