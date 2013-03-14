//
//  FNResource.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

typedef int64_t FNTimestamp;

// Fauna class names
FOUNDATION_EXPORT NSString * const FNUserClassName;

// Resource JSON keys
FOUNDATION_EXPORT NSString * const FNClassJSONKey;
FOUNDATION_EXPORT NSString * const FNRefJSONKey;
FOUNDATION_EXPORT NSString * const FNTimestampJSONKey;
FOUNDATION_EXPORT NSString * const FNUniqueIDJSONKey;
FOUNDATION_EXPORT NSString * const FNDataJSONKey;
FOUNDATION_EXPORT NSString * const FNReferencesJSONKey;
FOUNDATION_EXPORT NSString * const FNIsDeletedJSONKey;

FOUNDATION_EXPORT NSString * const FNEmailJSONKey;
FOUNDATION_EXPORT NSString * const FNPasswordJSONKey;
FOUNDATION_EXPORT NSString * const FNPasswordConfirmationJSONKey;

@interface FNResource : NSObject

# pragma mark lifecycle

/*!
 Initializes a newly allocated resource with the given Fauna class.
 */
- (id)initWithFaunaClass:(NSString *)faunaClass;

/*!
 Initializes a newly allocatd resource with the given JSON dictionary.
 @param dictionary Dictionary representation of the JSON for the Resource
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

#pragma mark Class methods

/*!
 Returns the Fauna class name for this type of resource.
 */
+ (NSString *)faunaClass;

/*!
 Retrieves a Resource for the given ref.
 @param ref Resource ref.
 */
+ (FNFuture *)get:(NSString *)ref;

/*!
 Returns a deserialized resource for the given JSON dictionary.
 @param dictionary Dictionary representation of the JSON structure for the Resoure
 */
+ (FNResource *)resourceWithDictionary:(NSDictionary *)dictionary;

/*!
 Resolves a FNResource subclass for the given Fauna class string.
 @param className the name of the class
 */
+ (Class)classForFaunaClass:(NSString *)className;

#pragma mark Persistence

/*!
 Save the resource, creating it if necessary. This does *not* update the existing resource.
 Returns a FNFuture of the saved resource.
 */
- (FNFuture *)save;

#pragma mark Fields

/*!
 (ref) Ref string for the resource.
 */
@property (nonatomic, readonly) NSString *ref;

/*!
 (faunaClass) Fauna class name for the resource
 */
@property (nonatomic, readonly) NSString *faunaClass;

/*!
 (timestamp) FNTimestamp of the last time the resource was updated.
 */
@property (nonatomic) FNTimestamp timestamp;

/*!
 (dateTimestamp) The resource's timestamp as an NSDate.
 */
@property (nonatomic) NSDate *dateTimestamp;

/*!
 (uniqueID) The resource's unique id if present, or nil.
 */
//@property (nonatomic) NSString *uniqueID;

/*!
 (data) The custom data dictionary for the resource.
 */
//@property (nonatomic) NSMutableDictionary *data;

/*!
 (references) The custom references dictionary for the resource.
 */
//@property (nonatomic) NSMutableDictionary *references;

/*!
 (isDeleted) A BOOL indicating whether the resource is deleted or not.
 */
@property (nonatomic, readonly) BOOL isDeleted;

/*!
 Returns the internal JSON dictionary for the Resource
 */
@property (nonatomic, readonly) NSMutableDictionary *dictionary;

@end
