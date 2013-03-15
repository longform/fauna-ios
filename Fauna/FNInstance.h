//
//  FNInstance.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"

@interface FNInstance : FNResource

@end

@interface FNInstance (StandardFields)

/*!
 (uniqueID) The resource's unique id if present, or nil.
 */
@property (nonatomic) NSString *uniqueID;

/*!
 (data) The custom data dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *data;

/*!
 (references) The custom references dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *references;

@end
