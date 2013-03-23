//
// FNSQLiteCacheTest.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
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

  [[[cache setObject:dict forKey:testKey] flatMap:^(id wtf) {
    return [cache valueForKey:testKey];
  }] onSuccess:^(NSDictionary* rv) {
    if ([rv[@"test"] isEqualToString:@"sup"]) {
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testVolatilePutAndGet)];
    }
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)testPersistentPutAndGet {
  [self prepare];

  NSString *testKey = @"testKey";
  NSString *testFilename = TestUniqueID();

  FNSQLiteCache *cache = [FNSQLiteCache persistentCacheWithName:testFilename];
  NSDictionary *dict = @{@"test": @"sup"};

  [[cache setObject:dict forKey:testKey] onSuccess:^(id blah) {
    FNSQLiteCache *otherCache = [FNSQLiteCache persistentCacheWithName:testFilename];
    FNFuture *rv = [otherCache valueForKey:testKey];
    [rv onSuccess:^(NSDictionary* rv) {
      if ([rv[@"test"] isEqualToString:@"sup"]) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPersistentPutAndGet)];
      }
    }];
  }];

  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}
@end
