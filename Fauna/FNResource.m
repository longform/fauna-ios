//
//  FNResource.m
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"
#import "FNContext.h"
#import "FNInstance.h"
#import "FNUser.h"
#import "FNPublisher.h"

// Fauna class names
NSString * const FNUserClassName = @"users";

// Resource JSON keys
NSString * const FNClassJSONKey = @"class";
NSString * const FNRefJSONKey = @"ref";
NSString * const FNTimestampJSONKey = @"ts";
NSString * const FNUniqueIDJSONKey = @"unique_id";
NSString * const FNDataJSONKey = @"data";
NSString * const FNReferencesJSONKey = @"references";
NSString * const FNIsDeletedJSONKey = @"deleted";

NSString * const FNEmailJSONKey = @"email";
NSString * const FNPasswordJSONKey = @"password";
NSString * const FNPasswordConfirmationJSONKey = @"password_confirmation";

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

+ (void)resetDefaultClasses {
  FNResourceClassRegistry = [NSMutableDictionary new];
  FNResourceClassRegistry[@"users"] = [FNUser class];
  FNResourceClassRegistry[@"classes/config"] = [FNResource class];
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
                                                                 forKey:FNClassJSONKey];
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
  Class class = [self classForFaunaClass:dictionary[FNClassJSONKey]];
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
  return self.dictionary[FNRefJSONKey];
}

- (NSString *)faunaClass {
  return self.dictionary[FNClassJSONKey];
}

- (FNTimestamp)timestamp {
  NSNumber *ts = self.dictionary[FNTimestampJSONKey];
  return ts ? (FNTimestamp) ts.longLongValue : 0;
}

- (void)setTimestamp:(FNTimestamp)timestamp {
  NSNumber *ts = [NSNumber numberWithLongLong:timestamp];

  if (![self.dictionary[FNTimestampJSONKey] isEqual:ts]) {
    [self willChangeValueForKey:@"dateTimestamp"];
    self.dictionary[FNTimestampJSONKey] = ts;
    [self didChangeValueForKey:@"dateTimestamp"];
  }
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
  NSNumber *deleted = self.dictionary[FNIsDeletedJSONKey];
  return deleted ? deleted.boolValue : NO;
}

#pragma mark implementations of optional fields

- (NSString *)uniqueID {
  return self.dictionary[FNUniqueIDJSONKey];
}

- (void)setUniqueID:(NSString *)uniqueID {
  self.dictionary[FNUniqueIDJSONKey] = uniqueID;
}

- (NSMutableDictionary *)data {
  id value = self.dictionary[FNDataJSONKey];
  NSMutableDictionary *data = FNMutableDictionaryFromValue(value  );

  if (data != value) self.dictionary[FNDataJSONKey] = data;
  return data;
}

- (void)setData:(NSMutableDictionary *)data {
  self.dictionary[FNDataJSONKey] = data;
}

- (NSMutableDictionary *)references {
  id value = self.dictionary[FNReferencesJSONKey];
  NSMutableDictionary *references = FNMutableDictionaryFromValue(value  );

  if (references != value) self.dictionary[FNReferencesJSONKey] = references;
  return references;
}

- (void)setReferences:(NSMutableDictionary *)references {
  self.dictionary[FNReferencesJSONKey] = references;
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
