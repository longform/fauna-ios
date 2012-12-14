//
//  FaunaPublisherKey.m
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaPublisherKey.h"

@implementation FaunaPublisherKey

+ (FaunaPublisherKey*)keyFromKeyString:(NSString*)keyString {
  FaunaPublisherKey *key = [[FaunaPublisherKey alloc] initWithKeyString:keyString];
  return key;
}

@end
