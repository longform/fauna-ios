//
//  FNSQLiteConnection.h
//  Fauna
//
//  Created by Matt Freels on 3/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <sqlite3.h>

@class FNFuture;

@interface FNSQLiteConnection : NSObject

@property (readonly) BOOL isClosed;

- (id)initWithSQLitePath:(NSString *)path;

- (NSError *)withTransaction:(BOOL(^)(void))block;

- (NSError *)performQuery:(NSString *)sql prepare:(int(^)(sqlite3_stmt *))prepareBlock result:(int(^)(sqlite3_stmt *))resultBlock;

- (NSError *)performQuery:(NSString *)sql prepare:(int(^)(sqlite3_stmt *))prepareBlock;

- (void)close;

@end
