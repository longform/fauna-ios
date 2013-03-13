//
//  FaunaCommand.m
//  Fauna
//
//  Created by Johan Hernandez on 2/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaCommand.h"
#import "FaunaContext.h"

@implementation FaunaCommand

+ (FaunaResource*)execute:(NSString*)commandName error:(NSError**)error {
  return [self execute:commandName params:nil error:error];
}

+ (FaunaResource*)execute:(NSString*)commandName params:(NSDictionary*)params error:(NSError**)error {
  NSParameterAssert(commandName);
  FaunaContext * context = FaunaContext.current;
  FaunaClient * client = context.client;
  NSDictionary * resourceDictionary = [client execute:commandName params:params error:error];
  if(*error || !resourceDictionary) {
    return NO;
  }
  return [FaunaResource deserialize:resourceDictionary];
}

@end