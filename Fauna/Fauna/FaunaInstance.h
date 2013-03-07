//
//  FaunaInstance.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaResource.h"

@interface FaunaInstance : FaunaResource

/*!
 Retrieves a FaunaInstance
 @param ref Instance Reference. E.g: instances/123456789
 */
+ (FaunaInstance*)get:(NSString *)ref error:(NSError**)error;

/*!
 Creates a FaunaInstance
 @param instance Instance to Create
 */
+ (BOOL)create:(FaunaInstance*)instance error:(NSError**)error;

/*!
 Destroys a FaunaInstance
 @param ref Instance Reference to Destroy
 */
+ (BOOL)destroy:(NSString*)ref error:(NSError**)error;

/*!
 Destroys a FaunaInstance
 @param ref Instance Reference to Update
 @param changes A dictionary with changes to apply. Keys can be unique_id, references and data.
 */
+ (FaunaInstance*)update:(NSString*)ref changes:(NSDictionary*)changes error:(NSError**)error;


/*!
 Unique ID of the Instance.
 */
@property (nonatomic, strong) NSString *uniqueId;

/*!
 Class Name.
 */
@property (nonatomic, strong) NSString *className;

/*!
 References of the instance.
 */
@property (nonatomic, strong) NSDictionary *references;

/*!
 User Defined Data.
 */
@property (nonatomic, strong) NSDictionary *data;


@end
