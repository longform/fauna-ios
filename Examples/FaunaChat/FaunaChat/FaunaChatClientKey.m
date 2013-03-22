//
//  FaunaChatClientKey.m
//  FaunaChat
//
//  Created by Matt Freels on 3/22/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Fauna/FNContext.h>
#import "FaunaCredentials.h"
#import "FaunaChatClientKey.h"

FNContext * FaunaChatClientKeyContext() {
  static FNContext *ctx;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [FNContext contextWithKey:FAUNA_CLIENT_KEY];
  });

  return ctx;
}
