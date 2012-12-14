//
//  FaunaClientKey.m
//  Fauna
//
//  Created by Johan Hernandez on 12/13/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaClientKey.h"

@implementation FaunaClientKey

+ (FaunaClientKey*)keyFromKeyString:(NSString*)keyString {
  FaunaClientKey *key = [[FaunaClientKey alloc] initWithKeyString:keyString];
  return key;
}

@end
