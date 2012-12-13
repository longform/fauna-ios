//
//  FaunaKey.h
//  Fauna
//
//  Created by Johan Hernandez on 12/13/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"

/*!
 Fauna Abstract Key. Use FaunaPublisherKey, FaunaClientKey and others.
 
 See https://fauna.org/API#access_model-tokens
 */
@interface FaunaKey : FaunaResource

/*!
 Initializes with the given Key String
 @param keyString key string to use in this key instance.
 */
- (id)initWithKeyString:(NSString*)keyString;

/*!
 (token/key) The Actual Token Key String.
 */
@property (nonatomic, strong) NSString *keyString;

@end
