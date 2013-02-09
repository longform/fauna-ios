//
//  FaunaContext.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaunaCache.h"
#import "FaunaConstants.h"

@interface FaunaClient : NSObject

- (id)init;

/*!
 Initializes this context with a FaunaClientKey instance.
 @param keyString Client key string. Required.
 */
- (id)initWithClientKeyString:(NSString *)keyString;

/*!
 User Token currently associated with this context.
 */
@property (nonatomic, strong) NSString *userToken;

/*!
 Returns FaunaCache instance in use by the client.
 */
@property (nonatomic, strong, readonly) FaunaCache *cache;

#pragma mark - Instances

- (void)createInstance:(NSDictionary*)instance callback:(FaunaResponseResultBlock)block;

- (void)destroyInstance:(NSString*)ref callback:(FaunaSimpleResultBlock)block;

- (void)updateInstance:(NSString*)ref changes:(NSDictionary*)changes callback:(FaunaResponseResultBlock)block;

- (void)instanceDetails:(NSString*)ref callback:(FaunaResponseResultBlock)block;

- (NSDictionary*)createInstance:(NSDictionary*)resource error:(NSError*__autoreleasing*)error;


#pragma mark - Timelines


#pragma mark - Maintainance

- (void)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block;

- (void)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference error:(NSError**)error;

- (void)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference before:(NSDate*)before callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference before:(NSDate*)before withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference after:(NSDate*)after callback:(FaunaResponseResultBlock)block;

- (void)pageFromTimeline:(NSString*)timelineReference after:(NSDate*)after withCount:(NSInteger)count callback:(FaunaResponseResultBlock)block;

- (NSDictionary*)pageFromTimeline:(NSString *)timelineReference withCount:(NSInteger)count error:(NSError**)error;

#pragma mark - Users

- (void)createUser:(NSDictionary*)user callback:(FaunaResponseResultBlock)block;

- (void)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation callback:(FaunaSimpleResultBlock)block;

#pragma mark - Tokens

- (void)createToken:(NSDictionary*)credentials block:(FaunaResponseResultBlock)block;

#pragma mark - Commands

- (void)execute:(NSString*)commandName params:(NSDictionary*)params callback:(FaunaResponseResultBlock)block;

#pragma mark - HTTP

- (NSMutableURLRequest *)clientKeyRequestWithMethod:(NSString *)method
path:(NSString *)path parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)userRequestWithMethod:(NSString *)method
                                               path:(NSString *)path parameters:(NSDictionary *)parameters;

#pragma mark - Resources

- (NSDictionary*)getResource:(NSString*)ref error:(NSError*__autoreleasing*)error;

@end