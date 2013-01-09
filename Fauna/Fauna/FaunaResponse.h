//
//  FaunaResponse.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

@interface FaunaResponse : NSObject

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary;

/*!
 Initializes a FaunaResponse instance with a dictionary returned from the Server
 */
- (id)initWithDictionary:(NSDictionary*)responseDictionary;

/*!
 Returns the resource dictionary returned by the API.
 */
@property (nonatomic, strong) NSDictionary *resource;

/*!
 Returns a dictionary of references in the resource.
 */
@property (nonatomic, strong) NSDictionary *references;

@end
