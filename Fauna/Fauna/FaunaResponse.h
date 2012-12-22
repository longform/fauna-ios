//
//  FaunaResponse.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"
#import "FaunaContext.h"

@interface FaunaResponse : NSObject

- (id)initWithContext:(FaunaContext*) context response:(NSDictionary*)responseDictionary andRootResourceClass:(Class)rootResourceClass;

/*!
 Returns the context associated with this response.
 */
@property (nonatomic, strong) FaunaContext *context;

/*!
 Returns the resource returned in this response.
 */
@property (nonatomic, strong) FaunaResource *resource;

@end
