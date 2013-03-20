//
//  FNCache.h
//  Fauna
//
//  Created by Edward Ceaser on 3/20/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNFuture;

@protocol FNCache <NSObject>
- (FNFuture*)putWithKey:(const NSString*)key dictionary:(const NSDictionary*)dict;
- (FNFuture*)getWithKey:(const NSString*)key;
@end
