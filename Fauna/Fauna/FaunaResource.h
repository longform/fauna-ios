//
//  FaunaResource.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaContext.h"

/*!
 Fauna Abstract Resource. All Fauna Resources inherits from this class.
 
 See https://fauna.org/API#resources
 */
@interface FaunaResource : NSObject

/*!
 Initialize the Resource in the Default Fauna Context. (FaunaContext.current).
 */
- (id)init;

/*!
 Initialize the Resource in the Default Fauna Context (FaunaContext.current) and the given dictionary.
 @param dictionary Dictionary with values to initialize this resource.
 */
- (id)initWithDictionary:(NSMutableDictionary*)dictionary;

/*!
 Initialize the Resource in the given Context.
 @param context The Fauna Context to use.
 */
- (id)initInContext:(FaunaContext*)context;

/*!
 Initialize the Resource in the given Context and using the given dictionary.
 @param context The Fauna Context to use.
 @param dictionary Dictionary with values to initialize this resource.
 */
- (id)initInContext:(FaunaContext*)context andDictionary:(NSMutableDictionary*)dictionary;

/*! 
 (ref) Reference Id of this Resource.
 */
@property (nonatomic, strong) NSString *reference;

/*!
 (ts) Last time this resource was updated.
 */
@property (nonatomic, strong) NSDate *timestamp;

/*!
 (deleted) Whether this resource is deleted or not.
 */
@property (nonatomic) BOOL isDeleted;

/*!
 Returns the context associated with this resource.
 */
@property (nonatomic, strong) FaunaContext *context;

/*!
 Returns the internal dictionary for this Fauna Resource
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *resourceDictionary;

@end
