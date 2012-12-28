//
//  FaunaTimelinePage.m
//  Fauna
//
//  Created by Johan Hernandez on 12/28/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaTimelinePage.h"

#define kCreatesKey @"creates"
#define kUpdatesKey @"updates"
#define kDeletesKey @"deletes"
#define kEventsKey @"events"
#define kBeforeKey @"before"
#define kAfterKey @"after"

@implementation FaunaTimelinePage

- (NSInteger)creates {
  NSNumber *number = [self.resourceDictionary objectForKey:kCreatesKey];
  return [number integerValue];
}

- (NSInteger)updates {
  NSNumber *number = [self.resourceDictionary objectForKey:kUpdatesKey];
  return [number integerValue];
}

- (NSInteger)deletes {
  NSNumber *number = [self.resourceDictionary objectForKey:kDeletesKey];
  return [number integerValue];
}

- (NSArray*)events {
  return [self.resourceDictionary objectForKey:kEventsKey];
}

- (NSDate*)before {
  NSNumber *number = [self.resourceDictionary objectForKey:kBeforeKey];
  NSTimeInterval epoch = [number doubleValue];
  return [NSDate dateWithTimeIntervalSince1970:epoch];
}

- (NSDate*)after {
  NSNumber *number = [self.resourceDictionary objectForKey:kAfterKey];
  NSTimeInterval epoch = [number doubleValue];
  return [NSDate dateWithTimeIntervalSince1970:epoch];
}

@end
