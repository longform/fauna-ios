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

static int const Offline = 0;
static int const Wifi = 1;
static int const Cellular = 2;

static int _status = 0;
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

+ (BOOL)isOnline {
  return _status != Offline;
}

+ (BOOL)isCellular {
  return _status == Cellular;
}

+ (void)updateReachability:(SCNetworkReachabilityFlags)flags {
  int prev = _status;
  int status = Offline;

  if (flags & kSCNetworkReachabilityFlagsReachable) {
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
      status = Wifi;
    }

    if (flags & (kSCNetworkReachabilityFlagsConnectionOnDemand | kSCNetworkReachabilityFlagsConnectionOnTraffic)) {
      if (!(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        status = Wifi;
      }
    }

    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
      status = Cellular;
    }
  }

  if (prev != status) {
    if (prev == Offline || status == Offline) [self willChangeValueForKey:@"isOnline"];
    if (prev == Cellular || status == Cellular) [self willChangeValueForKey:@"isCellular"];
    _status = status;
    OSMemoryBarrier();
    if (prev == Offline || status == Offline) [self didChangeValueForKey:@"isOnline"];
    if (prev == Cellular || status == Cellular) [self didChangeValueForKey:@"isCellular"];
  }
}

@end
