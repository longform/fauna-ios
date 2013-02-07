//
//  FaunaResource.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaunaResource : NSObject

/*!
 Initialize the Resource in the Default Fauna Context (FaunaContext.current) and the given dictionary.
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
@property (nonatomic, strong, readonly) NSMutableDictionary *resourceDictionary;

+ (FaunaResource*)get:(NSString *)ref error:(NSError**)error;

+ (Class)resolveResourceType:(NSString*)ref resource:(NSDictionary*)resource;

+ (FaunaResource*)deserialize:(NSDictionary*)faunaResource;

@end
