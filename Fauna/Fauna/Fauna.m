//
//  Fauna.m
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "Fauna.h"

@implementation Fauna

static FaunaContext *_current;

+(FaunaContext*) current {
  return _current;
}

+(void)setCurrent:(FaunaContext*)context {
  _current = context;
}

@end
