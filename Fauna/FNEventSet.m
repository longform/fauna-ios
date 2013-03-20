//
//  FNEventSet.m
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNContext.h"
#import "FNFuture.h"
#import "FNEventSet.h"
#import "NSArray+FNFunctionalEnumeration.h"

@implementation FNEventSet

#pragma mark lifecycle

- (id)initWithRef:(NSString *)ref {
  self = [super init];
  if (self) {
    _ref = ref;
  }
  return self;
}

+ (FNEventSet *)eventSetWithRef:(NSString *)ref {
  return [[self alloc] initWithRef:ref];
}

#pragma mark Public methods

- (FNFuture *)pageBefore:(FNTimestamp)before {
  return [self pageAfter:before count:-1];
}

- (FNFuture *)pageBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:-1 count:-1 filter:nil];
}

- (FNFuture *)pageAfter:(FNTimestamp)after {
  return [self pageAfter:after count:-1];
}

- (FNFuture *)pageAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self eventsWithBefore:-1 after:after count:count filter:nil];
}

- (FNFuture *)createsBefore:(FNTimestamp)before {
  return [self createsBefore:before count:-1];
}

- (FNFuture *)createsBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:-1 count:count filter:@"creates"];
}

- (FNFuture *)createsAfter:(FNTimestamp)after {
  return [self createsAfter:after count:-1];
}

- (FNFuture *)createsAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self eventsWithBefore:-1 after:after count:count filter:@"creates"];
}

- (FNFuture *)updatesBefore:(FNTimestamp)before {
  return [self updatesBefore:before count:-1];
}

- (FNFuture *)updatesBefore:(FNTimestamp)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:-1 count:count filter:@"updates"];
}

- (FNFuture *)updatesAfter:(FNTimestamp)after {
  return [self updatesAfter:after count:-1];
}

- (FNFuture *)updatesAfter:(FNTimestamp)after count:(NSInteger)count {
  return [self eventsWithBefore:-1 after:after count:count filter:@"updates"];
}

- (FNFuture *)add:(FNResource *)resource {
  return [self addRef:resource.ref];
}

- (FNFuture *)addRef:(NSString *)ref {
  return [[FNContext post:self.ref parameters:@{@"resource": ref}] map:^(NSDictionary *dict) {
    return [FNResource resourceWithDictionary:dict];
  }];
}

- (FNFuture *)remove:(FNResource *)resource {
  return [self removeRef:resource.ref];
}

- (FNFuture *)removeRef:(NSString *)ref {
  return [[FNContext delete:self.ref parameters:@{@"resource": ref}] map:^(NSDictionary *dict) {
    return [FNResource resourceWithDictionary:dict];
  }];
}

#pragma mark Private methods

- (NSMutableDictionary *)baseParams {
  return [NSMutableDictionary new];
}

- (FNFuture *)eventsWithBefore:(FNTimestamp)before after:(FNTimestamp)after count:(NSInteger)count filter:(NSString *)filter {
  NSString *fullRef = filter ? [self.ref stringByAppendingFormat:@"/%@", filter] : self.ref;
  NSMutableDictionary *params = self.baseParams;

  if (before > -1) params[@"before"] = FNTimestampToNSNumber(before);
  if (after > -1) params[@"after"] = FNTimestampToNSNumber(after);
  if (count > -1) params[@"count"] = @(count);

  return [[FNContext get:fullRef parameters:params] map:^(NSDictionary *dict) {
    return [FNEventSetPage resourceWithDictionary:dict];
  }];
}

@end

@interface FNEventSetPage () {
  NSArray *_events;
}
@end

@implementation FNEventSetPage

- (NSInteger)creates {
  return ((NSNumber *)self.dictionary[@"creates"]).integerValue;
}

- (NSInteger)updates {
  return ((NSNumber *)self.dictionary[@"updates"]).integerValue;
}

- (NSInteger)deletes {
  return ((NSNumber *)self.dictionary[@"deletes"]).integerValue;
}

- (FNTimestamp)before {
  return FNTimestampFromNSNumber(self.dictionary[@"before"]);
}

- (FNTimestamp)after {
  return FNTimestampFromNSNumber(self.dictionary[@"after"]);
}

- (NSArray *)events {
  if (!_events) {
    _events = [((NSArray *)self.dictionary[@"events"]) map:^(NSDictionary *dict){
      return [[FNEvent alloc] initWithDictionary:dict];
    }];
  }

  return _events;
}

- (FNFuture *)resources {
  return FNSequence([self.events map:^(FNEvent *ev){
    return ev.resource;
  }]);
}

@end

@implementation FNEvent

- (id)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _action = dictionary[@"action"];
    _ref = dictionary[@"resource"];
    _eventSetRef = dictionary[@"set"];
    _timestamp = FNTimestampFromNSNumber(dictionary[@"ts"]);
  }
  return self;
}

- (FNEventSet *)eventSet {
  return [FNEventSet eventSetWithRef:self.eventSetRef];
}

- (FNFuture *)resource {
  return [FNResource get:self.ref];
}

@end