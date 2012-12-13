//
//  FaunaPublisherKey.h
//  Fauna
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaKey.h"

/*!
 Fauna Publisher Key.
 */
@interface FaunaPublisherKey : FaunaKey

/*!
 Creates an Instance of FaunaPublisherKey with the given Client Key String
 @param keyString key string to use in this key instance.
 */
+ (FaunaPublisherKey*)keyFromKeyString:(NSString*)keyString;

@end
