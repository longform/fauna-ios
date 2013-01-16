//
//  FaunaUser.h
//  Fauna
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaConstants.h"

@interface FaunaUsers : NSObject

- (void)create:(NSDictionary*)user callback:(FaunaResponseResultBlock)block;

- (void)changePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmation:(NSString*)confirmation callback:(FaunaSimpleResultBlock)block;

@end
