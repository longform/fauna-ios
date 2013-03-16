//
//  FNPublisher.h
//  Fauna
//
//  Created by Matt Freels on 3/15/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"

@interface FNPublisher : FNResource

/*!
 Retrieve the publisher resource.
 */
+ (FNFuture *)get;

/*!
 Retrieve the publisher config.
 */
+ (FNFuture *)getConfig;

@end

@interface FNPublisher (StandardFields)

/*!
 (data) The custom data dictionary for the resource.
 */
@property (nonatomic) NSMutableDictionary *data;

@end
