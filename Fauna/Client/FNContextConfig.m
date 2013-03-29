//
//  FNContextConfig.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNContextConfig.h"

@implementation FNContextConfig

- (id)initWithMaxAge:(NSTimeInterval)wifiAge WWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback {
  self = [super init];
  if (self) {
    _maxCacheEntryAgeWifi = wifiAge;
    _maxCacheEntryAgeWWAN = wwanAge;
    _httpGETTimeout = timeout;
    _fallbackOnTransientError = fallback;
  }

  return self;
}

+ (instancetype)configWithMaxAge:(NSTimeInterval)wifiAge WWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback {
  return [[self alloc] initWithMaxAge:wifiAge WWANAge:wwanAge timeout:timeout fallbackOnError:fallback];
}

- (instancetype)maxAge:(NSTimeInterval)wifiAge {
  return [FNContextConfig configWithMaxAge:wifiAge
                                   WWANAge:self.maxCacheEntryAgeWWAN
                                   timeout:self.httpGETTimeout
                           fallbackOnError:self.fallbackOnTransientError];
}

- (instancetype)maxWWANAge:(NSTimeInterval)wwanAge {
  return [FNContextConfig configWithMaxAge:self.maxCacheEntryAgeWifi
                                   WWANAge:wwanAge
                                   timeout:self.httpGETTimeout
                           fallbackOnError:self.fallbackOnTransientError];
}

- (instancetype)timeout:(NSTimeInterval)timeout {
  return [FNContextConfig configWithMaxAge:self.maxCacheEntryAgeWifi
                                   WWANAge:self.maxCacheEntryAgeWWAN
                                   timeout:timeout
                           fallbackOnError:self.fallbackOnTransientError];
}

- (instancetype)fallbackOnError:(BOOL)fallback {
  return [FNContextConfig configWithMaxAge:self.maxCacheEntryAgeWifi
                                   WWANAge:self.maxCacheEntryAgeWWAN
                                   timeout:self.httpGETTimeout
                           fallbackOnError:fallback];
}

@end
