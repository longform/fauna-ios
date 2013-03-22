//
//  FaunaChatMessage.h
//  FaunaChat
//
//  Created by Matt Freels on 3/22/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Fauna/FNInstance.h>

@interface FaunaChatMessage : FNInstance

- (NSString *)body;

- (void)setBody:(NSString *)body;

@end
