//
//  FaunaInstance.h
//  Fauna
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaResource.h"
#import "FaunaConstants.h"

@interface FaunaInstance : FaunaResource

@property (nonatomic, strong) NSString *externalId;

@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSDictionary *references;

@property (nonatomic, strong) NSDictionary *data;

- (void)save:(FaunaResponseResultBlock)block;

@end
