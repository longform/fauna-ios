//
//  FaunaKey.m
//  Fauna
//
//  Created by Johan Hernandez on 12/13/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaKey.h"

@implementation FaunaKey

- (id)initWithKeyString:(NSString*)keyString {
  NSAssert(keyString, @"Key String is required");
  self = [super init];
  if(self) {
    self.keyString = keyString;
  }
  return self;
}

@end
