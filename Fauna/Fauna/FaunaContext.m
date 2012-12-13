//
//  FaunaContext.m
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaContext.h"
#import "FaunaClientKey.h"
#import "FaunaPublisherKey.h"

@implementation FaunaContext

- (id)init {
  self = [super init];
  if(self) {
    // nop
  }
  return self;
}

- (id)initWithKey:(FaunaKey *)key {
  NSAssert(key, @"Key instance must be provided");
  self = [self init];
  if(self) {
    self.key = key;
  }
  return self;
}

- (id)initWithPublisherKey:(NSString*)keyString {
  return [self initWithKey:[FaunaPublisherKey keyFromKeyString:keyString]];
}

- (id)initWithClientKey:(NSString*)keyString {
  return [self initWithKey:[FaunaClientKey keyFromKeyString:keyString]];
}

@end
