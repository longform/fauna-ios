//
// FaunaCache.h
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

#import <Foundation/Foundation.h>

@interface FaunaCache : NSObject

@property (nonatomic, readonly) NSString * name;

@property (nonatomic, readonly) BOOL isTransient;

@property (nonatomic, strong) FaunaCache * parentContextCache;

- (id)initWithName:(NSString*)name;

- (id)initTransient;

- (void)saveResource:(NSDictionary*)resource;

- (NSDictionary*)loadResource:(NSString*)ref;

+ (FaunaCache*)scopeCache;

- (void)scoped:(void (^)(void))block;

+ (void)transient:(void (^)(void))block;

@end
