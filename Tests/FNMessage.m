//
//  FNMessage.m
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNMessage.h"

@implementation FNMessage

+ (NSString *)faunaClass {
  return @"classes/messages";
}

- (NSString *)text {
  return self.data[@"text"];
}

- (void)setText:(NSString *)text {
  self.data[@"text"] = text;
}

- (FNCustomEventSet *)comments {
  return [self eventSet:@"comments"];
}

@end
