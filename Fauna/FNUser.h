//
//  FNUser.h
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"

@interface FNUser : FNResource

@property (nonatomic) NSString *uniqueID;

@property (nonatomic) NSDictionary *data;

@property (nonatomic) NSDictionary *references;

@property (nonatomic) NSString *email;

@property (nonatomic) NSString *password;

- (FNFuture *)config;

@end
