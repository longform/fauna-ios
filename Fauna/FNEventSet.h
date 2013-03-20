//
//  FNEventSet.h
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNResource.h"

@class FNFuture;

@interface FNEventSet : NSObject

@property (nonatomic, readonly) NSString *ref;

#pragma mark lifecycle

- (id)initWithRef:(NSString *)ref;

+ (FNEventSet *)eventSetWithRef:(NSString *)ref;

#pragma mark Public methods

- (FNFuture *)pageBefore:(FNTimestamp)before;

- (FNFuture *)pageBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)pageAfter:(FNTimestamp)after;

- (FNFuture *)pageAfter:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)createsBefore:(FNTimestamp)before;

- (FNFuture *)createsBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)createsAfter:(FNTimestamp)after;

- (FNFuture *)createsAfter:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)updatesBefore:(FNTimestamp)before;

- (FNFuture *)updatesBefore:(FNTimestamp)before count:(NSInteger)count;

- (FNFuture *)updatesAfter:(FNTimestamp)after;

- (FNFuture *)updatesAfter:(FNTimestamp)after count:(NSInteger)count;

- (FNFuture *)add:(FNResource *)resource;

- (FNFuture *)addRef:(NSString *)ref;

- (FNFuture *)remove:(FNResource *)resource;

- (FNFuture *)removeRef:(NSString *)ref;

@end

@interface FNEventSetPage : FNResource

- (NSInteger)creates;

- (NSInteger)updates;

- (NSInteger)deletes;

- (FNTimestamp)after;

- (FNTimestamp)before;

- (NSArray *)events;

- (FNFuture *)resources;

@end


@interface FNEvent : NSObject

- initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSString *ref;
@property (nonatomic, readonly) FNTimestamp timestamp;
@property (nonatomic, readonly) NSString *eventSetRef;
@property (nonatomic, readonly) NSString *action;

- (FNEventSet *)eventSet;

- (FNFuture *)resource;

@end