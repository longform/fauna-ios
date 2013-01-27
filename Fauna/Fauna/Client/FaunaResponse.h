//
//  FaunaResponse.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

@interface FaunaResponse : NSObject

+ (NSString*) requestPathFromPath:(NSString*)path andMethod:(NSString*)method;

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary;

+ (FaunaResponse*)responseWithDictionary:(NSDictionary*)responseDictionary cached:(BOOL)cached requestPath:(NSString*)requestPath;

/*!
 Initializes a FaunaResponse instance with a dictionary returned from the Server
 */
- (id)initWithDictionary:(NSDictionary*)responseDictionary cached:(BOOL)cached requestPath:(NSString*)requestPath;

/*!
 Returns the resource dictionary returned by the API.
 */
@property (nonatomic, strong) NSDictionary *resource;

/*!
 Returns the resources array returned by the API.
 */
@property (nonatomic, strong) NSArray *resources;

/*!
 Returns a dictionary of references in the resource.
 */
@property (nonatomic, strong) NSDictionary *references;

/*!
 Returns the request path string of the response.
 */
@property (nonatomic, strong, readonly) NSString* requestPath;

/*!
 Returns a value that indicates whether the response was re-created from local cache or not.
 */
@property (nonatomic, readonly) BOOL cached;

@end
