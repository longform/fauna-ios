//
//  FaunaResource.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"
#import "Fauna.h"

#define kRefIdKey @"ref"
#define kTimestampKey @"ts"
#define kDeletedKey @"deleted"
#define kDeletedDefaultValue NO

@implementation FaunaResource

- (id)init {
  return [self initWithDictionary:[[NSMutableDictionary alloc] init]];
}

- (id)initWithDictionary:(NSMutableDictionary*)dictionary {
  return [self initWithContext:[Fauna current] andDictionary:dictionary];
}

- (id)initWithContext:(FaunaContext*)context {
  return [self initWithContext:context andDictionary:[[NSMutableDictionary alloc] init]];
}

- (id)initWithContext:(FaunaContext*)context andDictionary:(NSMutableDictionary*)dictionary {
  if(self = [super init]) {
    self.context = context;
    _resourceDictionary = dictionary;
  }
  return self;
}

- (NSString*)reference {
  return [self.resourceDictionary valueForKey:kRefIdKey];
}

- (void)setTimestamp:(NSDate*)date {
  NSTimeInterval time = date ? [date timeIntervalSince1970] : 0.0f;
  NSNumber *ts = [NSNumber numberWithDouble:time];
  [self.resourceDictionary setValue:ts forKey:kTimestampKey];
}

- (NSDate*)timestamp {
  NSNumber *ts = [self.resourceDictionary valueForKey:kTimestampKey];
  if(ts) {
    return [NSDate dateWithTimeIntervalSince1970:[ts doubleValue]];
  }
  return nil;
}

- (void)setIsDeleted:(BOOL)deleted {
  [self.resourceDictionary setValue:[NSNumber numberWithBool:deleted] forKey:kDeletedKey];
}

- (BOOL)isDeleted {
  NSNumber * n = [self.resourceDictionary valueForKey:kDeletedKey];
  return [n boolValue];
}

@end
