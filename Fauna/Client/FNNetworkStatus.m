//
// FNNetworkStatus.m
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

#import <libkern/OSAtomic.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "FNNetworkStatus.h"

static FNStatus _status = 0;
static SCNetworkReachabilityRef reachabilityRef = NULL;

@interface FNNetworkStatus ()

+ (void)updateReachability:(SCNetworkReachabilityFlags)flags;

@end

static void FNNetworkStatusCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
  [FNNetworkStatus updateReachability:flags];
}

@implementation FNNetworkStatus

+ (void)start {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "rest.fauna.org");

    SCNetworkReachabilityContext ctx = {0, NULL, NULL, NULL, NULL};
    if (!SCNetworkReachabilitySetCallback(reachabilityRef, FNNetworkStatusCallback, &ctx)) {
      @throw @"Failed to start Network Status listener.";
    }

    if (!SCNetworkReachabilitySetDispatchQueue(reachabilityRef, dispatch_get_main_queue())) {
      @throw @"Failed to start Network Status listener.";
    }
  });
}

+ (FNStatus)status {
  return _status;
}

+ (BOOL)isOnline {
  return _status != FNStatusOffline;
}

+ (BOOL)isWWAN {
  return _status == FNStatusWWAN;
}

+ (void)updateReachability:(SCNetworkReachabilityFlags)flags {
  int prev = _status;
  int status = FNStatusOffline;

  if (flags & kSCNetworkReachabilityFlagsReachable) {
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
      status = FNStatusWifi;
    }

    if (flags & (kSCNetworkReachabilityFlagsConnectionOnDemand | kSCNetworkReachabilityFlagsConnectionOnTraffic)) {
      if (!(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        status = FNStatusWifi;
      }
    }

    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
      status = FNStatusWWAN;
    }
  }

  if (prev != status) {
    [self willChangeValueForKey:@"status"];
    if (prev == FNStatusOffline || status == FNStatusOffline) [self willChangeValueForKey:@"isOnline"];
    if (prev == FNStatusWWAN || status == FNStatusWWAN) [self willChangeValueForKey:@"isWWAN"];
    _status = status;
    OSMemoryBarrier();
    [self didChangeValueForKey:@"status"];
    if (prev == FNStatusOffline || status == FNStatusOffline) [self didChangeValueForKey:@"isOnline"];
    if (prev == FNStatusWWAN || status == FNStatusWWAN) [self didChangeValueForKey:@"isWWAN"];
  }
}

@end
