//
//  FaunaCache.h
//  Fauna
//
//  Created by Johan Hernandez on 1/18/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaConstants.h"

@interface FaunaCache : NSObject

- (id)initWithName:(NSString*)name;

- (id)initTransient;

- (void)saveResource:(NSDictionary*)resource;

- (void)saveResource:(NSDictionary*)resource withPath:(NSString*)path;

- (NSDictionary*)loadResource:(NSString*)ref;

- (NSDictionary*)loadResourceWithPath:(NSString*)path;

+ (FaunaCache*)scopeCache;

- (void)scoped:(FaunaBlock)block;

@end
