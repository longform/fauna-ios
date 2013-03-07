//
//  FaunaUserTest.m
//  Fauna
//
//  Created by Matt Freels on 3/6/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "FaunaCredentials.h"

@interface FaunaUserTest : GHTestCase { }
@end

@implementation FaunaUserTest

- (void)testAuthentication {
  GHFail(@"pending, but with creds: %@, %@, %@", FAUNA_TEST_EMAIL, FAUNA_TEST_PASSWORD, FAUNA_PUBLISHER_KEY);
}

@end
