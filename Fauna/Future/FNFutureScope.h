//
//  FNFutureScope.h
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNFutureScope : NSObject

+ (NSMutableDictionary *)currentScope;
+ (NSMutableDictionary *)saveCurrent;
+ (void)inScope:(NSMutableDictionary *)scope perform:(void (^)(void))block;

@end
