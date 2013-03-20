//
//  FNMessage.h
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Fauna/FNInstance.h>

@interface FNMessage : FNInstance

- (NSString *)text;

- (void)setText:(NSString *)text;

- (FNEventSet *)comments;

@end
