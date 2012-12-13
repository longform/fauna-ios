//
//  FaunaResource.h
//  FaunaClient
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Fauna Abstract Resource. All Fauna Resources inherits from this class.
 
 See https://fauna.org/API#resources
 */
@interface FaunaResource : NSObject

/*! 
 (ref) Reference Id of this Resource.
 */
@property (nonatomic, strong) NSString *referenceId;

/*!
 (ts) Last time this resource was updated.
 */
@property (nonatomic, strong) NSDate *timestamp;

/*!
 (deleted) Whether this resource is deleted or not.
 */
@property (nonatomic) BOOL *isDeleted;

@end
