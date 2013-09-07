//
// FNEventSet.m
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

#import "FNContext.h"
#import "FNFuture.h"
#import "FNEventSet.h"
#import "FNClient.h"
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

- (FNFuture *)pageBefore:(NSString *)before {
  return [self pageBefore:before count:-1];
}

- (FNFuture *)pageBefore:(NSString *)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:nil count:count filter:nil];
}

- (FNFuture *)pageAfter:(NSString *)after {
  return [self pageAfter:after count:-1];
}

- (FNFuture *)pageAfter:(NSString *)after count:(NSInteger)count {
  return [self eventsWithBefore:nil after:after count:count filter:nil];
}

- (FNFuture *)createsBefore:(NSString *)before {
  return [self createsBefore:before count:-1];
}

- (FNFuture *)createsBefore:(NSString *)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:nil count:count filter:@"creates"];
}

- (FNFuture *)createsAfter:(NSString *)after {
  return [self createsAfter:after count:-1];
}

- (FNFuture *)createsAfter:(NSString *)after count:(NSInteger)count {
  return [self eventsWithBefore:nil after:after count:count filter:@"creates"];
}

- (FNFuture *)updatesBefore:(NSString *)before {
  return [self updatesBefore:before count:-1];
}

- (FNFuture *)updatesBefore:(NSString *)before count:(NSInteger)count {
  return [self eventsWithBefore:before after:nil count:count filter:@"updates"];
}

- (FNFuture *)updatesAfter:(NSString *)after {
  return [self updatesAfter:after count:-1];
}

- (FNFuture *)updatesAfter:(NSString *)after count:(NSInteger)count {
  return [self eventsWithBefore:nil after:after count:count filter:@"updates"];
}

#pragma mark Private methods

- (NSMutableDictionary *)baseParams {
  return [NSMutableDictionary new];
}

- (FNFuture *)eventsWithBefore:(NSString *)before after:(NSString *)after count:(NSInteger)count filter:(NSString *)filter {
    NSString *fullRef = [NSString stringWithFormat:@"%@/events", self.ref];
    if ([self.ref rangeOfString:@"queries?"].location != NSNotFound) {
        fullRef = @"queries";
    }
    else if (filter) {
        fullRef = [self.ref stringByAppendingFormat:@"/%@", filter];
    }
    NSMutableDictionary *params = self.baseParams;

    if (before) params[@"before"] = before;
    if (after) params[@"after"] = after;
    if (count > -1) params[@"size"] = @(count);

    id (^responseBlock)(id value) = ^(FNResponse *res) {
        FNEventSetPage *eventSet = (FNEventSetPage *)[FNEventSetPage resourceWithDictionary:res.resource];
        if ([eventSet respondsToSelector:@selector(setResources:)]) {
            eventSet.resources = [res.references allValues];
        }
        return eventSet;
    };
    if ([self.ref rangeOfString:@"queries?"].location != NSNotFound && [params[@"q"] length] > 2048) {
        return [[FNContext post:fullRef
                    parameters:params
                   rawResponse:YES] map:responseBlock];
    }
    else {
        return [[FNContext get:fullRef
                    parameters:params
                   rawResponse:YES] map:responseBlock];
    }
}

@end

@implementation FNQueryEventSet

- (id)initWithQueryFunction:(NSString *)function parameters:(NSArray *)parameters {
    self = [super init];
    if (self) {
        _function = function;
        _parameters = parameters;
        _minimized = NO;
        _query = self.generateQuery;
    }
    return self;

}

- (id)initWithQueryFunction:(NSString *)function parameters:(NSArray *)parameters minimized:(BOOL)minimized {
  self = [super init];
  if (self) {
    _function = function;
    _parameters = parameters;
    _minimized = minimized;
    _query = self.generateQuery;
  }
  return self;
}

-(NSString *)ref {
    return _minimized ? [NSString stringWithFormat:@"queries/minimized?q=%@", self.query] :
                        [NSString stringWithFormat:@"queries?q=%@", self.query];
}

#pragma mark Private methods

- (NSString *)generateQuery {
  NSMutableArray *ps = [NSMutableArray arrayWithCapacity:self.parameters.count + 1];

  for (id param in self.parameters) {
    if ([param isKindOfClass:[FNQueryEventSet class]]) {
      [ps addObject:((FNQueryEventSet *)param).query];
    } else if ([param isKindOfClass:[FNEventSet class]]) {
      [ps addObject:[NSString stringWithFormat:@"%@", ((FNEventSet *)param).ref]];
    } else {
      [ps addObject:[NSString stringWithFormat:@"%@", param]];
    }
  }

  return [NSString stringWithFormat:@"%@(%@)", self.function, [ps componentsJoinedByString:@","]];
}

- (NSMutableDictionary *)baseParams {
  return [NSMutableDictionary dictionaryWithObject:self.query forKey:@"q"];
}

@end

@implementation FNCustomEventSet

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

- (NSString *)before {
  return self.dictionary[@"before"];
}

- (NSString *)after {
  return self.dictionary[@"after"];
}

- (NSArray *)events {
  if (!_events) {
    _events = [((NSArray *)self.dictionary[@"events"]) map:^(NSDictionary *dict){
      return [[FNEvent alloc] initWithDictionary:dict];
    }];
  }

  return _events;
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
