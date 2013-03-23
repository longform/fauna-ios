//
// FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import "FaunaAFHTTPClient+FaunaAFHTTPClient+DeleteBody.h"
#import "FaunaAFHTTPRequestOperation.h"

@implementation FaunaAFHTTPClient (DeleteBody)
// Note: These are already defined in AFHTTPClient.*
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
