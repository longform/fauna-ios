//
//  FNResource.h
//  Fauna
//
//  Created by Johan Hernandez on 2/7/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

typedef int64_t FNTimestamp;

FOUNDATION_EXPORT NSString * const FNClassJSONKey;
FOUNDATION_EXPORT NSString * const FNRefJSONKey;
FOUNDATION_EXPORT NSString * const FNTimestampJSONKey;
FOUNDATION_EXPORT NSString * const FNUniqueIDJSONKey;
FOUNDATION_EXPORT NSString * const FNDataJSONKey;
FOUNDATION_EXPORT NSString * const FNReferencesJSONKey;
FOUNDATION_EXPORT NSString * const FNIsDeletedJSONKey;

@interface FNResource : NSObject

# pragma mark lifecycle

/*!
 Initializes the Resource as a new unsaved resource.
 */
- (id)init;

/*!
 Initialize the Resource with the given dictionary.
 @param dictionary Dictionary representation of the JSON for the Resource
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

#pragma mark Public methods

/*!
 Returns the internal JSON dictionary for the Resource
 */
@property (nonatomic) NSMutableDictionary *dictionary;

/*!
 (ref) Reference Id of this Resource.
 */
@property (nonatomic, readonly) NSString *ref;

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
 Returns a deserialized resource for the given JSON dictionary.
 @param dictionary Dictionary representation of the JSON structure for the Resoure
 */
+ (FNResource *)resourceWithDictionary:(NSDictionary *)dictionary;

/*!
 Retrieves a Resource from the Server.
 @param ref Resource Reference.
 */
+ (FNFuture *)get:(NSString *)ref;

/*!
 Resolves a FNResource subclass for the given fauna class string.
 @param className the name of the class
 */
+ (Class)classForFaunaClassName:(NSString *)className;

@end
