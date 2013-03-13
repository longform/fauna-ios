//
//  NSError+FNHTTPErrors.h
//  Fauna
//
//  Created by Matt Freels on 3/13/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

@interface NSError (FNHTTPErrors)

- (NSHTTPURLResponse *)HTTPResponse;

@end
