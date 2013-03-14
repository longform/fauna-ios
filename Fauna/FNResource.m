//
//  FNResource.m
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"
#import "FNContext.h"


#define kRefIdKey @"ref"
#define kTimestampKey @"ts"
#define kDeletedKey @"deleted"
#define kDeletedDefaultValue NO

NSString * const FNClassJSONKey = @"class";
NSString * const FNRefJSONKey = @"ref";
NSString * const FNTimestampJSONKey = @"ts";
NSString * const FNUniqueIDJSONKey = @"unique_id";
NSString * const FNDataJSONKey = @"data";
NSString * const FNReferencesJSONKey = @"references";
NSString * const FNIsDeletedJSONKey = @"deleted";

@implementation FNResource

#pragma mark lifecycle

- (id)initWithMutableDictionary:(NSMutableDictionary *)dictionary {
  self = [super init];
  if (self) {
    _dictionary = dictionary;
  }
  return self;
}

- (id)init {
  return [self initWithMutableDictionary:[NSMutableDictionary new]];
}

- (id)initWithDictionary:(NSMutableDictionary*)dictionary {
  NSMutableDictionary *copy = [[NSMutableDictionary alloc] initWithDictionary:dictionary
                                                                    copyItems:YES];
  return [self initWithMutableDictionary:copy];
}

# pragma mark Public methods

- (NSString *)ref {
  return self.dictionary[FNRefJSONKey];
}

- (FNTimestamp)timestamp {
  NSNumber *ts = self.dictionary[FNTimestampJSONKey];
  return ts ? (FNTimestamp) ts.longLongValue : 0;
}

- (void)setTimestamp:(FNTimestamp)timestamp {
  [self willChangeValueForKey:@"timestamp"];
  [self willChangeValueForKey:@"dateTimestamp"];
  self.dictionary[FNTimestampJSONKey] = [NSNumber numberWithLongLong:timestamp];
  [self didChangeValueForKey:@"timestamp"];
  [self didChangeValueForKey:@"dateTimestamp"];
}

- (NSDate *)dateTimestamp {
  NSNumber *ts = self.dictionary[FNTimestampJSONKey];

  if (ts) {
    NSTimeInterval seconds = ts.doubleValue / 1000000.0;
    return [NSDate dateWithTimeIntervalSince1970:seconds];
  } else {
    return nil;
  }
}

- (void)setDateTimestamp:(NSDate *)date {
  FNTimestamp ts = date.timeIntervalSince1970 * 1000000.0;
  self.timestamp = ts;
}

- (BOOL)isDeleted {
  return ((NSNumber *)self.dictionary[FNIsDeletedJSONKey]).boolValue;
}

+ (FNResource *)resourceWithDictionary:(NSDictionary *)dictionary {
  // FIXME: should be smarter, obviously
  Class class = [self classForFaunaClassName:dictionary[FNClassJSONKey]];
  return [[class alloc] initWithDictionary:dictionary];
}

+ (FNFuture *)get:(NSString *)ref {
  return [[FNContext get:ref parameters:@{}] map:^(NSDictionary *resource) {
    return [self resourceWithDictionary:resource];
  }];
}

+ (Class)classForFaunaClassName:(NSString *)className {
  // FIXME: should be smarter, obviously
  return [FNResource class];
}

#pragma mark implementations of optional fields

- (NSString *)uniqueID {
  return self.dictionary[FNUniqueIDJSONKey];
}

- (void)setUniqueID:(NSString *)uniqueID {
  [self willChangeValueForKey:@"uniqueID"];
  self.dictionary[FNUniqueIDJSONKey] = uniqueID;
  [self didChangeValueForKey:@"uniqueID"];
}

- (NSMutableDictionary *)data {
  id value = self.dictionary[FNDataJSONKey];
  NSMutableDictionary *data = FNMutableDictionaryFromValue(value  );

  if (data != value) self.dictionary[FNDataJSONKey] = data;
  return data;
}

- (void)setData:(NSMutableDictionary *)data {
  [self willChangeValueForKey:@"data"];
  self.dictionary[FNDataJSONKey] = data;
  [self didChangeValueForKey:@"data"];
}

- (NSMutableDictionary *)references {
  id value = self.dictionary[FNReferencesJSONKey];
  NSMutableDictionary *references = FNMutableDictionaryFromValue(value  );

  if (references != value) self.dictionary[FNReferencesJSONKey] = references;
  return references;
}

- (void)setReferences:(NSMutableDictionary *)references {
  [self willChangeValueForKey:@"references"];
  self.dictionary[FNReferencesJSONKey] = references;
  [self didChangeValueForKey:@"references"];
}

#pragma mark private Methods/helpers

NSMutableDictionary * FNMutableDictionaryFromValue(id value) {
  if (!value) {
    value = [NSMutableDictionary new];
  } else if (![value isKindOfClass:[NSMutableDictionary class]]) {
    value = [[NSMutableDictionary alloc] initWithDictionary:value copyItems:YES];
  }

  return value;
}

@end
