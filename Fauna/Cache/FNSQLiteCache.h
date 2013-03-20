//
//  FNSQLite.h
//  Fauna
//
//  Created by Edward Ceaser on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNCache.h"

@class FNFuture;

@interface FNSQLiteCache : NSObject <FNCache>
+ (id)persistentCacheWithName:(const NSString*)name;
+ (id)volatileCache;
- (id)initPersistentWithName:(const NSString*)name;
- (id)initInMemory;
@end