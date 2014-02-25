//
// FNResource.m
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

#import "FNFuture.h"
#import "FNError.h"
#import "FNContext.h"
#import "FNResource.h"
#import "FNInstance.h"
#import "FNUser.h"
#import "FNPublisher.h"
#import "FNEventSet.h"

FNTimestamp const FNTimestampMax = INT64_MAX;
FNTimestamp const FNTimestampMin = 0;
FNTimestamp const FNFirst = FNTimestampMin;
FNTimestamp const FNLast = FNTimestampMax;

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

static NSMutableDictionary * FNResourceClassRegistry;

static void FNInitClassRegistry() {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [FNResource resetDefaultClasses];
  });
}

@implementation FNResource

+ (Class)classForFaunaClass:(NSString *)className {
  FNInitClassRegistry();

  Class class = FNResourceClassRegistry[className];

  if (class) {
    return class;
  } else if ([className hasPrefix:@"classes/"]) {
    return [FNInstance class];
  } else {
    return [FNResource class];
  }
}

+ (void)registerClass:(Class)class {
  FNInitClassRegistry();

  if (![class isSubclassOfClass:[FNResource class]]) {
    @throw FNInvalidResourceClass(@"%@ is not a subclass of FNResource", class);
  }

  if (!class.faunaClass) {
    @throw FNInvalidResourceClass(@"+faunaClass is not defined on %@.", class);
  }

  FNResourceClassRegistry[class.faunaClass] = class;
}

+ (void)registerClasses:(NSArray *)classes {
  [self resetDefaultClasses];

  for (Class cls in classes) {
    [self registerClass:cls];
  }
}

+ (void)resetDefaultClasses {
  FNResourceClassRegistry = [NSMutableDictionary new];
  FNResourceClassRegistry[@"classes/config"] = [FNResource class];
  FNResourceClassRegistry[@"sets/config"] = [FNResource class];
  FNResourceClassRegistry[@"commands/config"] = [FNResource class];
  FNResourceClassRegistry[@"publisher/config"] = [FNResource class];
  FNResourceClassRegistry[@"users/config"] = [FNResource class];
  FNResourceClassRegistry[@"keys/client"] = [FNResource class];
  FNResourceClassRegistry[@"keys/publisher"] = [FNResource class];
  FNResourceClassRegistry[@"tokens"] = [FNResource class];

  FNResourceClassRegistry[@"users"] = [FNUser class];
  FNResourceClassRegistry[@"publisher"] = [FNPublisher class];
  FNResourceClassRegistry[@"events"] = [FNEventSetPage class];
  FNResourceClassRegistry[@"resources"] = [FNEventSetPage class];
}

#pragma mark lifecycle

- (id)initWithMutableDictionary:(NSMutableDictionary *)dictionary {
  self = [super init];
  if (self) {
    _dictionary = dictionary;
  }
  return self;
}

- (id)init {
  if (!self.class.faunaClass) {
    @throw FNInvalidResource(@"Cannot create unsaved instances of class %@", self.class);
  }

  return [self initWithClass:self.class.faunaClass];
}

- (id)initWithClass:(NSString *)faunaClass {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:faunaClass
                                                                 forKey:@"class"];
  return [self initWithMutableDictionary:dict];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
  NSMutableDictionary *copy = [[NSMutableDictionary alloc] initWithDictionary:dictionary
                                                                    copyItems:YES];
  return [self initWithMutableDictionary:copy];
}

#pragma mark Class methods

+ (NSString *)faunaClass {
  return nil;
}

+ (FNFuture *)get:(NSString *)ref {
  return [[FNContext get:ref parameters:@{}] map:^(NSDictionary *resource) {
    return [self resourceWithDictionary:resource];
  }];
}

+ (instancetype)resourceWithDictionary:(NSDictionary *)dictionary {
  Class class = [self classForFaunaClass:dictionary[@"class"]];
  return [[class alloc] initWithDictionary:dictionary];
}

#pragma mark Persistence

- (FNFuture *)save {
  if (!self.ref && !self.class.allowNewResources) {
    @throw FNInvalidResource(@"New resources of %@ cannot be saved.", self.class);
  }

  FNFuture *res = self.ref ? [FNContext put:self.ref parameters:self.dictionary] :
    [FNContext post:self.faunaClass parameters:self.dictionary];

  return [res map:^(NSDictionary *resource) {
    return [self.class resourceWithDictionary:resource];
  }];
}

#pragma mark Fields

- (NSString *)ref {
  return self.dictionary[@"ref"];
}

- (NSString *)resources {
  return self.dictionary[@"resources"];
}

- (NSString *)faunaClass {
  return self.dictionary[@"class"];
}

- (FNTimestamp)timestamp {
  NSNumber *ts = self.dictionary[@"ts"];
  return ts ? FNTimestampFromNSNumber(ts) : 0;
}

- (void)setTimestamp:(FNTimestamp)timestamp {
  self.dictionary[@"ts"] = FNTimestampToNSNumber(timestamp);
}

- (BOOL)isDeleted {
  NSNumber *deleted = self.dictionary[@"deleted"];
  return deleted ? deleted.boolValue : NO;
}

#pragma mark implementations of optional fields

- (NSString *)uniqueID {
  return self.dictionary[@"unique_id"];
}

- (void)setUniqueID:(NSString *)uniqueID {
  self.dictionary[@"unique_id"] = uniqueID;
}

- (NSMutableDictionary *)data {
  id value = self.dictionary[@"data"];
  NSMutableDictionary *data = FNMutableDictionaryFromValue(value);

  if (data != value) self.dictionary[@"data"] = data;
  return data;
}

- (void)setData:(NSMutableDictionary *)data {
  self.dictionary[@"data"] = data;
}

- (NSMutableDictionary *)references {
  id value = self.dictionary[@"references"];
  NSMutableDictionary *references = FNMutableDictionaryFromValue(value);

  if (references != value) self.dictionary[@"references"] = references;
  return references;
}

- (void)setReferences:(NSDictionary *)references {
  self.dictionary[@"references"] = references;
}

- (FNCustomEventSet *)eventSet:(NSString *)name {
  return [FNCustomEventSet eventSetWithRef:[self.ref stringByAppendingFormat:@"/sets/%@", name]];
}

- (FNEventSet *)internalEventSet:(NSString *)name {
  return [FNEventSet eventSetWithRef:[self.ref stringByAppendingFormat:@"/%@", name]];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.dictionary forKey:@"dictionary"];
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self) {
    _dictionary = [coder decodeObjectForKey:@"dictionary"];
  }
  return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
  return [[self.class allocWithZone:zone] initWithDictionary:self.dictionary];
}

#pragma mark equality

- (BOOL)isEqualToResource:(FNResource *)resource {
  return self == resource || (resource && [self.dictionary isEqualToDictionary:resource.dictionary]);
}

- (BOOL)isEqual:(id)object {
  return self == object || (object && [object isKindOfClass:[self class]] && [self isEqualToResource:object]);
}

- (NSUInteger)hash {
  NSUInteger result = 1;
  NSUInteger prime = 9431;

  result = prime * result + self.dictionary.hash;
  return result;
}

#pragma mark private Methods/helpers

+ (BOOL)allowNewResources {
  return NO;
}

NSMutableDictionary * FNMutableDictionaryFromValue(id value) {
  if (!value) {
    value = [NSMutableDictionary new];
  } else if (![value isKindOfClass:[NSMutableDictionary class]]) {
    value = [[NSMutableDictionary alloc] initWithDictionary:value copyItems:YES];
  }

  return value;
}

@end
