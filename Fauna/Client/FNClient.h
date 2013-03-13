//
//  FNClient.h
//  Fauna
//
//  Created by Matt Freels on 3/8/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNFuture.h"

FOUNDATION_EXPORT NSString * const FaunaAPIBaseURL;
FOUNDATION_EXPORT NSString * const FaunaAPIVersion;

@interface FNClient : NSObject

/*!
 Returns the global shared connection instance.
 */
+ (FNClient *)sharedConnection;

- (FNFuture *)get:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers;

- (FNFuture *)post:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers;

- (FNFuture *)put:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers;

- (FNFuture *)delete:(NSString *)path parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers;

@end
