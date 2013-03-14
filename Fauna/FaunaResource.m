//
//  FaunaResource.m
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaResource.h"
#import "FNContext.h"

#define kRefIdKey @"ref"
#define kTimestampKey @"ts"
#define kDeletedKey @"deleted"
#define kDeletedDefaultValue NO

NSString * const EventSetsClassName = @"sets";

@implementation FaunaResource

- (id)init {
  if(self = [self initWithDictionary:[[NSMutableDictionary alloc] init]]) {
    
  }
  return self;
}

- (id)initWithDictionary:(NSMutableDictionary*)dictionary {
  if(self = [super init]) {
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

+ (Class)resolveResourceType:(NSDictionary*)resource {
  NSString* className = resource[@"class"];
  NSString* ref = resource[@"ref"];
  NSUInteger refLength = ref.length;
  if(ref) {
    NSError* error;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression
             regularExpressionWithPattern:@"^instances/[^/]+$"
             options:NSRegularExpressionCaseInsensitive
             error:&error];
    if([regex matchesInString:ref options:0 range:NSMakeRange(0, refLength)].count > 0) {
      //NSString* className = [NSString stringWithFormat:@"classes/%@", resource[@"class"]];
      return NSClassFromString(@"FaunaInstance");
    }
    
    if([EventSetsClassName isEqualToString:className]) {
      return NSClassFromString(@"FaunaTimelinePage");
    }
    return NSClassFromString(@"FaunaInstance");
  }
  return [FaunaResource class];
}

+ (FaunaResource*)deserialize:(NSDictionary*)faunaResource {
  // ensure it's a mutable dictionary
  NSMutableDictionary *resource = [faunaResource isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary*)faunaResource : [[NSMutableDictionary alloc] initWithDictionary:faunaResource];
  return [[[self resolveResourceType:faunaResource] alloc] initWithDictionary:resource];
}

+ (FaunaResource*)get:(NSString *)ref error:(NSError**)error {
  FNContext * context = FNContext.current;
  FaunaClient * client = context.client;
  
  NSError  *getError;
  NSDictionary * resource = [client getResource:ref error:&getError];
  if(getError || !resource) {
    *error = getError;
    return nil;
  }
  return [self deserialize:resource];
}

@end
