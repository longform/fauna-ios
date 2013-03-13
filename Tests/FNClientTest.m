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
#import "FaunaAFURLConnectionOperation.h"

@interface FNClientTest : GHAsyncTestCase { }
@end

@implementation FNClientTest

- (void)testGet {
  [self prepare];
  FNClient *conn = [FNClient sharedConnection];

  [[conn get:@"users" parameters:@{} headers:@{}] onError:^(NSError *error) {
    NSHTTPURLResponse *res = error.userInfo[FaunaAFNetworkingOperationFailingURLResponseErrorKey];

    if (res.statusCode == 401) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testGet)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
}

@end
