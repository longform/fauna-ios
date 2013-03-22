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
@property (nonatomic) NSError *error;
@property (nonatomic) FNFuture *future;

@property (nonatomic) NSOutputStream *responseStream;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSSet *runLoopModes;

@end

static NSThread * FNRequestThread() {
  static NSThread *thread;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    thread = [[NSThread alloc] initWithTarget:[FNRequestOperation class] selector:@selector(threadStart) object:nil];
    [thread start];
  });

  return thread;
}

@implementation FNRequestOperation

- (BOOL)isConcurrent {
  return YES;
}

- (id)initWithRequest:(NSURLRequest *)request {
  self = [super init];
  if (self) {
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
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
  @synchronized (self) {
    [self performSelector:@selector(startOnThread) onThread:FNRequestThread() withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];

    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
  }
}

- (void)cancel {
  @synchronized (self) {
    if (!self.isFinished && !self.isCancelled) {
      [self performSelector:@selector(cancelOnThread) onThread:FNRequestThread() withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];

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

- (void)startOnThread {
  @synchronized (self) {
    if (self.isCancelled) {
      [self finish];
    } else {
      self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];

      for (NSString *mode in self.runLoopModes) {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
      }

      [self.connection start];
    }
  }
}

- (void)cancelOnThread {
  if (self.connection) [self.connection cancel];
}

+ (void)threadStart {
  while (YES) {
    @autoreleasepool {
      [[NSRunLoop currentRunLoop] run];
    }
  }
}

#pragma mark NSURLConnectionDelegate

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
  return NO;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
  return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"response is not an HTTP response.");

  self.response = (NSHTTPURLResponse *)response;
  self.responseStream = [NSOutputStream outputStreamToMemory];
  [self.responseStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if ([self.responseStream hasSpaceAvailable]) [self.responseStream write:[data bytes] maxLength:[data length]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSInteger code = self.response.statusCode;
  NSData *data = [self.responseStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

  NSError *err;
  id json = data.length == 0 ? @{} : [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
  [self.responseStream close];

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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (self.responseStream) [self.responseStream close];

  self.error = error;

  [self finish];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return self.isCancelled ? nil : cachedResponse;
}

@end
