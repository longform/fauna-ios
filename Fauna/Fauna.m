//
//  Fauna.m
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "Fauna.h"

@implementation Fauna

static FaunaClient *_client;

+(FaunaClient*) client {
  return _client;
}

+(void)setClient:(FaunaClient*)client {
  _client = client;
}

@end
