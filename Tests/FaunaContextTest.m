//
//  FaunaContextTest.m
//  Fauna
//
//  Created by Matt Freels on 3/6/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FaunaUser.h>
#import <Fauna/FaunaContext.h>
#import "FaunaCredentials.h"

@interface FaunaContextTest : GHTestCase { }
@end

@implementation FaunaContextTest

- (void)testAuthentication {
  FaunaContext *ctx = [[FaunaContext alloc] initWithClientKeyString:FAUNA_CLIENT_KEY];

  [ctx scoped:^() {
    FaunaUser *user = [FaunaUser new];
    user.name = @"Taran";
    user.email = @"taran@example.net";
    user.uniqueId = @"taran77";
    user.password = @"supersecrit";

    NSError *err = nil;
    //GHAssertTrue([FaunaUser create:user error: &err], @"user create failed: %@", err);

  }];
}

@end
