//
//  FNUser.h
//  Fauna
//
//  Created by Johan Hernandez on 2/28/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FNResource.h"

@interface FNUser : FNResource

+ (FNFuture *)selfUser;

@property (nonatomic) NSString *email;

@property (nonatomic) NSString *password;

- (FNFuture *)config;

@end

@interface FNUser (StandardFields)

@property (nonatomic) NSString *uniqueID;

@property (nonatomic) NSMutableDictionary *data;

@property (nonatomic) NSMutableDictionary *references;

@end
