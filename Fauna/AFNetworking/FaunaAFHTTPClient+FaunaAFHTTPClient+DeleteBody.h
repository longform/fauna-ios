//
//  FaunaAFHTTPClient+FaunaAFHTTPClient_DeleteBody.h
//  Fauna
//
//  Created by Johan Hernandez on 1/13/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaAFHTTPClient.h"

@interface FaunaAFHTTPClient (DeleteBody)

- (void)deleteBodyPath:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(FaunaAFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(FaunaAFHTTPRequestOperation *operation, NSError *error))failure;

@end
