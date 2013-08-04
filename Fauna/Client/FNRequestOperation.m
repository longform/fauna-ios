//
// FNRequestOperation.m
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

#import "FNRequestOperation.h"
#import "FNError.h"
#import "FNFuture.h"
#import "FNMutableFuture.h"

@interface FNRequestOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;
@property BOOL isCancelled;

@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSHTTPURLResponse *response;
@property (nonatomic) id responseData;
@property (nonatomic) NSData *data;
@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic) NSURLSessionTask *task;
@property (nonatomic) NSError *error;
@property (nonatomic) FNFuture *future;

@property (nonatomic) NSOutputStream *responseStream;
@property (nonatomic) NSSet *runLoopModes;

@end

@implementation FNRequestOperation

- (BOOL)isConcurrent {
  return YES;
}

- (id)initWithRequest:(NSURLRequest *)request {
  self = [super init];
  if (self) {
    self.request = request;

    FNMutableFuture *future = [[FNMutableFuture alloc] init];
    self.future = future;

    FNRequestOperation __weak *wkSelf = self;
    self.completionBlock = ^{
      if (wkSelf.isCancelled) wkSelf.error = FNOperationCancelled();

      if (wkSelf.responseData) {
        [future update:wkSelf.responseData];
      } else {
        [future updateError:wkSelf.error];
      }
    };
  }
  return self;
}

- (void)start {
  if (self.isCancelled) {
    [self finish];
  } else {
      NSLog(@"Starting request for %@", self.request.URL);
    if (_isBackgroundEnabled) {
        self.URLSession = [self backgroundSession];;
        self.task = [self.URLSession downloadTaskWithRequest:self.request];
    }
    else {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = YES;
        configuration.requestCachePolicy = NSURLRequestReloadRevalidatingCacheData;
        self.URLSession = [NSURLSession sessionWithConfiguration:configuration];
        self.task = [self.URLSession dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self parseData:data response:response error:error];
        }];
    }
    [self.task resume];
  }

  [self willChangeValueForKey:@"isExecuting"];
  self.isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
}

- (NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *bundleIDString = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
        NSString *sessionName = [NSString stringWithFormat:@"%@.Fauna.BackgroundSession", bundleIDString];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:sessionName];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (self.isCancelled) {
        [self finish];
    } else {
        self.data = [NSData dataWithContentsOfFile:[location path]];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.isCancelled) {
        [self finish];
    }
    else {
        [self parseData:self.data response:task.response error:error];
    }
}

- (void)parseData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
    
    NSError *err;
    id json = data.length == 0 ? @{} : [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    if (code >= 200 && code <= 299) {
        if (json) {
            self.responseData = json;
        } else {
            self.error = err;
        }
    } else if (code == 404) {
        self.error = FNNotFound();
    } else if (code == 400) {
        if (json) {
            NSString *desc = ((NSDictionary *)json)[@"error"];
            NSDictionary *paramErrors = ((NSDictionary *)json)[@"param_errors"];
            self.error = FNBadRequest(desc, paramErrors);
        } else {
            self.error = FNBadRequest(@"Bad Request", @{});
        }
    } else if (code == 401) {
        self.error = FNUnauthorized();
    } else {
        self.error = FNInternalServerError();
    }
    
    [self finish];
}

- (void)cancel {
  @synchronized (self) {
    if (!self.isFinished && !self.isCancelled) {
      [self.task cancel];
        
      [self willChangeValueForKey:@"isExecuting"];
      [self willChangeValueForKey:@"isCancelled"];
      self.isExecuting = NO;
      self.isCancelled = YES;
      [self didChangeValueForKey:@"isExecuting"];
      [self didChangeValueForKey:@"isCancelled"];

      [super cancel];
    }
  }
}

#pragma mark Private methods

- (void)finish {
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  self.isExecuting = NO;
  self.isFinished = YES;
  [self didChangeValueForKey:@"isFinished"];
  [self didChangeValueForKey:@"isExecuting"];
}

@end
