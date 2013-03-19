//
//  FNTestHelper.m
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import "FNTestHelper.h"

FNContext * TestClientContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithKey:FAUNA_TEST_CLIENT_KEY];
  });

  return ctx;
}

FNContext * TestPublisherContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithKey:FAUNA_TEST_PUBLISHER_KEY];
  });

  return ctx;
}

FNContext * TestPublisherPasswordContext() {
  static FNContext * ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithPublisherEmail:FAUNA_TEST_EMAIL password:FAUNA_TEST_PASSWORD];
  });

  return ctx;
}

NSInteger TestUniqueStamp() {
  static int64_t stamp;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    stamp = [[NSDate date] timeIntervalSince1970];
  });

  return OSAtomicIncrement64(&stamp);
}

NSString * TestUniqueID() {
  return [NSString stringWithFormat:@"uid%d", TestUniqueStamp()];
}

NSString * TestUniqueEmail() {
  return [NSString stringWithFormat:@"email%d@example.com", TestUniqueStamp()];
}