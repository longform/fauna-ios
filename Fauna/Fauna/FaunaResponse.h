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
 Returns the context associated with the response.
 */
@property (nonatomic, strong) FaunaContext *context;

/*!
 Returns the resource retrieved from the server.
 */
@property (nonatomic, strong) FaunaResource *resource;

/*!
 Returns the references related to the resource that were retrieved from the server.
 */
@property (nonatomic, strong) NSMutableDictionary *references;

@end
