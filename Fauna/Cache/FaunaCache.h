//
//  FaunaCache.h
//  Fauna
//
//  Created by Johan Hernandez on 1/18/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaunaCache : NSObject

@property (nonatomic, readonly) NSString * name;

@property (nonatomic, readonly) BOOL isTransient;

@property (nonatomic, strong) FaunaCache * parentContextCache;

- (id)initWithName:(NSString*)name;

- (id)initTransient;

- (void)saveResource:(NSDictionary*)resource;

- (NSDictionary*)loadResource:(NSString*)ref;

+ (FaunaCache*)scopeCache;

- (void)scoped:(void (^)(void))block;

+ (void)transient:(void (^)(void))block;

@end