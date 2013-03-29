//
//  FNTimestamp.m
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNTimestamp.h"

FNTimestamp const FNTimestampMax = INT64_MAX;
FNTimestamp const FNTimestampMin = 0;
FNTimestamp const FNFirst = FNTimestampMin;
FNTimestamp const FNLast = FNTimestampMax;

FNTimestamp FNNow() {
  return FNTimestampFromNSDate([NSDate date]);
}

NSDate * FNTimestampToNSDate(FNTimestamp ts) {
  double micros = 1000000.0;
  return [NSDate dateWithTimeIntervalSince1970:ts / micros];
}

FNTimestamp FNTimestampFromNSDate(NSDate *date) {
  double micros = 1000000.0;
  return date.timeIntervalSince1970 * micros;
}

NSNumber * FNTimestampToNSNumber(FNTimestamp ts) {
  return @(ts);
}

FNTimestamp FNTimestampFromNSNumber(NSNumber *number) {
  return number.longLongValue;
}
