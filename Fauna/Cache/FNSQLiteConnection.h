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

- (BOOL)withTransaction:(BOOL(^)(void))block;

- (int)performQuery:(NSString *)sql prepare:(int(^)(sqlite3_stmt *stmt))prepareBlock result:(int(^)(sqlite3_stmt *stmt))resultBlock;

- (int)performQuery:(NSString *)sql prepare:(int(^)(sqlite3_stmt *stmt))prepareBlock;

- (void)close;

@end
