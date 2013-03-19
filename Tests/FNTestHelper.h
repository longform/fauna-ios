//
//  FNTestHelper.h
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Foundation/Foundation.h>

FNContext * TestClientContext();
FNContext * TestPublisherContext();
FNContext * TestPublisherPasswordContext();

NSString * TestUniqueID();
NSString * TestUniqueEmail();