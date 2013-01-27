//
//  NSError+FaunaErrors.m
//  Fauna
//
//  Created by Johan Hernandez on 1/27/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSError+FaunaErrors.h"

@implementation NSError (FaunaErrors)

- (BOOL)shouldRespondFromCache {
  if( [@[NSURLErrorDomain] containsObject:self.domain]) {
    return YES;
  }
  return NO;
}

@end
