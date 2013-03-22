//
//  FaunaChatUser.h
//  FaunaChat
//
//  Created by Matt Freels on 3/22/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Fauna/FNUser.h>

@interface FaunaChatUser : FNUser

- (NSString *)name;

- (void)setName:(NSString *)name;

@end
