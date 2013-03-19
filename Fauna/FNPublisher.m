//
//  FNPublisher.m
//  Fauna
//
//  Created by Matt Freels on 3/15/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"
#import "FNPublisher.h"

@implementation FNPublisher

+ (FNFuture *)get {
  return [self get:@"publisher"];
}

+ (FNFuture *)getConfig {
  return [self get:@"publisher/config"];
}

@end
