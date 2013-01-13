//
//  FaunaAFHTTPClient+FaunaAFHTTPClient_DeleteBody.m
//  Fauna
//
//  Created by Johan Hernandez on 1/13/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"
#import "FaunaAFHTTPRequestOperation.h"

@implementation FaunaAFHTTPClient (DeleteBody)
// Note: There are already defined in AFHTTPClient.*
 extern NSString * AFJSONStringFromParameters(NSDictionary *parameters);
 extern NSString * AFPropertyListStringFromParameters(NSDictionary *parameters);

- (void)deleteBodyPath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(FaunaAFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(FaunaAFHTTPRequestOperation *operation, NSError *error))failure
{
  NSMutableURLRequest * request = [self requestWithMethod:@"DELETE" path:path parameters:nil];
  NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
  
  switch (self.parameterEncoding) {
    case FaunaAFFormURLParameterEncoding:;
      [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
      break;
    case FaunaAFJSONParameterEncoding:;
      [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:[AFJSONStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
      break;
    case FaunaAFPropertyListParameterEncoding:;
      [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:[AFPropertyListStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
      break;
  }
  FaunaAFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
  [self enqueueHTTPRequestOperation:operation];
}

@end
