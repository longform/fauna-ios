//
//  FNFutureLocal.h
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNFutureLocal : NSObject

- (id)objectForKey:(id<NSCopying>)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (void)removeObjectForKey:(id<NSCopying>)key;

@end
