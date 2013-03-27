//
// FNCache.m
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

#import "FNCache.h"
#import "FNFuture.h"

@interface FNCache ()
@property (nonatomic, readonly) FNCache* parent;
@end

@implementation FNCache
- (id)initWithParent:(FNCache*)parent {
  if (self = [super init]) {
    _parent = parent;
  }
  return self;
}

- (FNFuture *)setObject:(NSDictionary *)value forKey:(NSString *)key timestamp:(FNTimestamp)timestamp {
  return [self propogateToParent:^(FNCache* cache) {
    return [cache addObjectToCache:value forKey:key timestamp:timestamp];
  }];
}

- (FNFuture *)addObjectToCache:(NSDictionary *)value forKey:(NSString *)key timestamp:(FNTimestamp)timestamp {
  @throw @"not implemented";
}

- (FNFuture *)valueForKey:(NSString *)key {
  @throw @"not implemented";
}

- (FNFuture *)propogateToParent:(FNFuture *(^)(FNCache *))operation {
  FNFuture *selfCompletion = operation(self);

  if (self.parent) {
    FNFuture *parentCompletion = [self.parent propogateToParent:operation];
    return [parentCompletion flatMap_: ^ { return selfCompletion; }];
  } else {
    return selfCompletion;
  }
}
@end

