//
//  FaunaCache.h
//  Fauna
//
//  Created by Johan Hernandez on 1/18/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResponse.h"

typedef void (^FaunaCacheScopeBlock)();

@interface FaunaCache : NSObject

- (id)initWithName:(NSString*)name;

- (void)saveResource:(NSDictionary*)resource;

- (NSDictionary*)loadResource:(NSString*)ref;

- (void)saveResponse:(FaunaResponse*)response;

- (FaunaResponse*)loadResponse:(NSString*)responsePath;

+ (BOOL)shouldIgnoreCache;

+ (void)ignoreCache:(FaunaCacheScopeBlock)block;

@end
