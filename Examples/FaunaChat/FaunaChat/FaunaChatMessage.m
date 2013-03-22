//
//  FaunaChatMessage.m
//  FaunaChat
//
//  Created by Matt Freels on 3/22/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaChatMessage.h"

@implementation FaunaChatMessage

+ (NSString *)faunaClass {
  return @"classes/messages";
}

- (NSString *)body {
  return self.data[@"body"];
}

- (void)setBody:(NSString *)body {
  self.data[@"body"] = body;
}

@end
