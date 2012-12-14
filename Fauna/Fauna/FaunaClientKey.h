//
//  FaunaClientKey.h
//  Fauna
//
//  Created by Johan Hernandez on 12/13/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaKey.h"

/*!
 Fauna Client Key.
 */
@interface FaunaClientKey : FaunaKey

/*!
 Creates an Instance of FaunaClientKey with the given Client Key String
 @param keyString key string to use in this key instance.
 */
+ (FaunaClientKey*)keyFromKeyString:(NSString*)keyString;

@end
