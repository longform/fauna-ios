//
//  NSError+FaunaErrors.h
//  Fauna
//
//  Created by Johan Hernandez on 1/27/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FaunaErrors)

- (BOOL)shouldRespondFromCache;

@end
