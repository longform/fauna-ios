//
//  FNSQLiteCacheTest.m
//  Fauna
//
//  Created by Edward Ceaser on 3/20/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Fauna/FNSQLiteCache.h>
#import <Fauna/FNFuture.h>

@interface FNSQLiteCacheTest : GHAsyncTestCase { }
@end

@implementation FNSQLiteCacheTest
- (void)testVolatilePutAndGet {
  [self prepare];

  FNSQLiteCache *cache = [FNSQLiteCache volatileCache];
  NSString *testKey = @"testKey";

  NSDictionary *dict = @{@"test": @"sup"};

  [[[cache putWithKey:testKey dictionary:dict] flatMap:^(id wtf) {
    return [cache getWithKey:testKey];
  }] onSuccess:^(NSDictionary* rv) {
    if ([rv[@"test"] isEqualToString:@"sup"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testVolatilePutAndGet)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testPersistentPutAndGet {
  [self prepare];

  NSString const *testKey = @"testKey";
  NSString const *testFilename = @"test-cache";

  FNSQLiteCache *cache = [FNSQLiteCache persistentCacheWithName:testFilename];
  NSDictionary *dict = @{@"test": @"sup"};

  [[cache putWithKey:testKey dictionary:dict] onSuccess:^(id blah) {
    FNSQLiteCache *otherCache = [FNSQLiteCache persistentCacheWithName:testFilename];
    FNFuture *rv = [otherCache getWithKey:testKey];
    [rv onSuccess:^(NSDictionary* rv) {
      if ([rv[@"test"] isEqualToString:@"sup"]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPersistentPutAndGet)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}
@end