//
//  FNContextConfig.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNTimestamp.h"

@interface FNContextConfig : NSObject

@property (nonatomic, readonly) NSTimeInterval maxCacheEntryAgeWifi;
@property (nonatomic, readonly) NSTimeInterval maxCacheEntryAgeWWAN;
@property (nonatomic, readonly) NSTimeInterval httpGETTimeout;
@property (nonatomic, readonly) BOOL fallbackOnTransientError;

- (id)initWithMaxAge:(NSTimeInterval)wifiAge WWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback;

+ (instancetype)configWithMaxAge:(NSTimeInterval)wifiAge WWANAge:(NSTimeInterval)wwanAge timeout:(NSTimeInterval)timeout fallbackOnError:(BOOL)fallback;

- (instancetype)maxAge:(NSTimeInterval)wifiAge;

- (instancetype)maxWWANAge:(NSTimeInterval)wwanAge;

- (instancetype)timeout:(NSTimeInterval)timeout;

- (instancetype)fallbackOnError:(BOOL)fallback;

@end
