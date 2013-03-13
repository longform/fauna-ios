//
//  NSError+FNHTTPErrors.m
//  Fauna
//
//  Created by Matt Freels on 3/13/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSError+FNHTTPErrors.h"
#import "FaunaAFURLConnectionOperation.h"

@implementation NSError (FNHTTPErrors)

- (NSHTTPURLResponse *)HTTPResponse {
  return self.userInfo[FaunaAFNetworkingOperationFailingURLResponseErrorKey];
}

@end
