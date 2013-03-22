//
//  FaunaChatUser.m
//  FaunaChat
//
//  Created by Matt Freels on 3/22/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaChatUser.h"

@implementation FaunaChatUser

- (NSString *)name {
  return self.data[@"name"];
}

- (void)setName:(NSString *)name {
  self.data[@"name"] = name;
}

@end
