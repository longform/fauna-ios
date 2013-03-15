//
//  FNClient.h
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"
#import "FNError.h"

FOUNDATION_EXPORT NSString * const FaunaAPIBaseURL;
FOUNDATION_EXPORT NSString * const FaunaAPIVersion;

@interface FNResponse : NSObject

@property (nonatomic, readonly) NSDictionary *resource;
@property (nonatomic, readonly) NSDictionary *references;

- (id)initWithResource:(NSDictionary *)resource references:(NSDictionary *)references;

@end

@interface FNClient : NSObject

@property (nonatomic) NSString *traceID;

@property (nonatomic) BOOL logHTTPTraffic;

/*!
 Initializes the Client with the given key or user token.
 @param keyString key or user token
 */
- (id)initWithKey:(NSString *)keyString;

/*!
 Initializes the Client with the given publisher key, masquerading as a specific user.
 @param keyString a publisher key
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (id)initWithKey:(NSString *)keyString asUser:(NSString *)userRef;

/*!
 Initializes the Client with the publisher's email and password.
 @param email the publisher's email
 @param password the publisher's password
 */
- (id)initWithPublisherEmail:(NSString *)email password:(NSString *)password;

/*!
 Returns a new Client that masquerades as a specific user. Only valid if this Client was initialized with a publisher key.
 @param userRef the ref of the user to masquerade as (e.g. 'users/123')
 */
- (instancetype)asUser:(NSString *)userRef;

/*!
 Perform a GET request of a specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of query parameters to send with the request
 */
- (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters;

/*!
 Perform a GET request of a specified resource.
 @param path the path of the resource
 */
- (FNFuture *)get:(NSString *)path;

/*!
 Perform a POST request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 */
- (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters;

/*!
 Perform a POST request with the specified resource.
 @param path the path of the resource
 */
- (FNFuture *)post:(NSString *)path;

/*!
 Perform a PUT request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 */
- (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters;

/*!
 Perform a PUT request with the specified resource.
 @param path the path of the resource
 */
- (FNFuture *)put:(NSString *)path;

/*!
 Perform a DELETE request with the specified resource.
 @param path the path of the resource
 @param parameters a Dictionary of parameters to send with the request.
 */
- (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters;

/*!
 Perform a DELETE request with the specified resource.
 @param path the path of the resource
 */
- (FNFuture *)delete:(NSString *)path;

@end
