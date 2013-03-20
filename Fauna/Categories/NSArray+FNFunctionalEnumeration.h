//
//  NSArray+FNFunctionalEnumeration.h
//  Fauna
//
//  Created by Matt Freels on 3/20/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FNFunctionalEnumeration)

- (NSArray *)map:(id (^)(id value))block;

@end
