//
//  FNFutureLocal.m
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <pthread.h>
#import "FNFutureLocal.h"

NSString * const FNFutureLocalTLSKey = @"org.fauna.FutureLocal";

@interface FNFutureLocal ()

@property (nonatomic, readonly) NSMutableDictionary *dict;
@property (nonatomic, readonly) pthread_mutex_t mutex;

@end

@implementation FNFutureLocal

# pragma mark lifecycle

- (id)init {
  self = [super init];
  if (self) {
    _dict = [NSMutableDictionary new];
    if (pthread_mutex_init(&_mutex, NULL)) {
      return nil;
    }
  }
  return self;
}

- (void)dealloc {
  pthread_mutex_destroy(&_mutex);
}

# pragma mark Class methods

+ (FNFutureLocal *)current {
  if (!self.tls[FNFutureLocalTLSKey]) {
    self.tls[FNFutureLocalTLSKey] = [FNFutureLocal new];
  }

  return self.tls[FNFutureLocalTLSKey];
}

+ (void)setCurrent:(FNFutureLocal *)local {
  NSAssert(!self.tls[FNFutureLocalTLSKey], @"Setting Future locals over previous scope.");

  if (local) {
    self.tls[FNFutureLocalTLSKey] = local;
  }
}

+ (void)removeCurrent {
  [self.tls removeObjectForKey:FNFutureLocalTLSKey];
}

# pragma mark Instance methods

- (id)objectForKey:(id<NSCopying>)key {
  pthread_mutex_lock(&_mutex);
  id rv = self.dict[key];
  pthread_mutex_unlock(&_mutex);
  return rv;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
  pthread_mutex_lock(&_mutex);
  if (object) {
    self.dict[key] = object;
  } else {
    [self.dict removeObjectForKey:key];
  }
  pthread_mutex_unlock(&_mutex);
}

- (void)removeObjectForKey:(id<NSCopying>)key {
  pthread_mutex_lock(&_mutex);
  [self.dict removeObjectForKey:key];
  pthread_mutex_unlock(&_mutex);
}

# pragma mark Private methods

+ (NSMutableDictionary *)tls {
  return [[NSThread currentThread] threadDictionary];
}

@end
