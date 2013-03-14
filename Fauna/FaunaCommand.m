//
//  FaunaCommand.m
//  Fauna
//
//  Created by Johan Hernandez on 2/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaCommand.h"
#import "FNContext.h"

@implementation FaunaCommand

+ (FNResource*)execute:(NSString*)commandName error:(NSError**)error {
  return [self execute:commandName params:nil error:error];
}

+ (FNResource*)execute:(NSString*)commandName params:(NSDictionary*)params error:(NSError**)error {
  NSParameterAssert(commandName);
  FNContext * context = FNContext.current;
  FaunaClient * client = context.client;
  NSDictionary * resourceDictionary = [client execute:commandName params:params error:error];
  if(*error || !resourceDictionary) {
    return NO;
  }
  return [FNResource deserialize:resourceDictionary];
}

@end
