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
 External ID of the Instance.
 */
@property (nonatomic, strong) NSString *externalId;

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
