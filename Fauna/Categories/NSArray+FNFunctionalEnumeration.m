//
//  NSArray+FNFunctionalEnumeration.m
//  Fauna
//
//  Created by Matt Freels on 3/20/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSArray+FNFunctionalEnumeration.h"

@implementation NSArray (FNFunctionalEnumeration)

- (NSArray *)map:(id (^)(id value))block {
  NSMutableArray *rv = [NSMutableArray arrayWithCapacity:self.count];
  for (id value in self) [rv addObject:block(value)];
  return rv;
}

@end
