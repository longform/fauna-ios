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

- (NSDictionary*)createInstance:(NSDictionary*)resource error:(NSError**)error;

- (BOOL)destroyInstance:(NSString*)ref error:(NSError**)error;

- (NSDictionary*)updateInstance:(NSString*)ref changes:(NSDictionary*)changes error:(NSError**)error;

#pragma mark - Timelines

- (NSDictionary*)addInstance:(NSString*)instanceReference toTimeline:(NSString*)timelineReference error:(NSError**)error;

- (BOOL)removeInstance:(NSString*)instanceReference fromTimeline:(NSString*)timelineReference error:(NSError**)error;

- (NSDictionary*)pageFromTimeline:(NSString *)timelineReference before:(NSDate*)before after:(NSDate*)after count:(NSInteger)count error:(NSError**)error;

#pragma mark - Users

- (NSDictionary*)createUser:(NSDictionary*)userInfo error:(NSError**)error;

- (BOOL)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation error:(NSError**)error;

#pragma mark - Tokens

- (NSString*)createToken:(NSDictionary*)credentials error:(NSError**)error;

#pragma mark - Commands

- (NSDictionary*)execute:(NSString*)commandName params:(NSDictionary*)params error:(NSError**)error;

#pragma mark - Resources

- (NSDictionary*)getResource:(NSString*)ref error:(NSError**)error;

@end