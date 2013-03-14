//
//  FaunaResource.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaunaResource : NSObject

- (id)init;

/*!
 Initialize the Resource in the Default Fauna Context (FNContext.current) and the given dictionary.
 @param dictionary Dictionary with values to initialize this resource.
 */
- (id)initWithDictionary:(NSMutableDictionary*)dictionary;

/*!
 (ref) Reference Id of this Resource.
 */
@property (nonatomic, strong, readonly) NSString *reference;

/*!
 (ts) Last time the resource was updated.
 */
@property (nonatomic, strong) NSDate *timestamp;

/*!
 (deleted) Whether the resource is deleted or not.
 */
@property (nonatomic) BOOL isDeleted;

/*!
 Returns the internal dictionary for the Fauna Resource
 */
@property (nonatomic, strong) NSMutableDictionary *resourceDictionary;

/*!
 Retrieves a Resource from the Server.
 @param ref Resource Reference.
 */
+ (FaunaResource*)get:(NSString *)ref error:(NSError**)error;

/*!
 Resolves a Resource Type for the Given Resource Dictionary.
 @param resource Fauna resource represented by a dictionary. ref and class keys will be queried.
 */
+ (Class)resolveResourceType:(NSDictionary*)resource;

/*!
 Deserialize the typed derived class from FaunaResource for the given resource dictionary.
 @param faunaResource Fauna Resource.
 */
+ (FaunaResource*)deserialize:(NSDictionary*)faunaResource;

@end
