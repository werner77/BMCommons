//
//  BMCache.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/23/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

@class BMOrderedDictionary;

/**
 Thread safe cache implementation with a LRU eviction policy.
 
 The cache has a configurable timeout interval for the objects it retains and a maximum size.
 */
@interface BMCache : BMCoreObject {
@private
    NSMutableDictionary *_dictionary;
    NSMutableDictionary *_keys;
    NSTimeInterval _timeout;
    NSUInteger _maxCount;
    NSUInteger _memoryUsed;
}

/**
 Maximum time to live for any object in the cache. 0 (which is default) means indefinitely.
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 Max number of objects allowed in the cache. Default is 0, which means unlimited.
 */
@property (nonatomic, assign) NSUInteger maxCount;

/**
 Max number of bytes in memory allowed. Default is 0, which means unlimited.
 */
@property (nonatomic, assign) NSUInteger maxMemoryUsage;

/**
 Returns the number of bytes of memory used.
 */
@property (nonatomic, readonly) NSUInteger memoryUsed;

/**
 The number of objects currently in the cache.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 Returns the object for the specified key or nil if it is non-existent or has timed out or has been evicted.
 */
- (id)objectForKey:(id <NSCopying, NSObject>)key;

- (BOOL)hasObjectForKey:(id<NSCopying, NSObject>)key;

- (void)setObject:(id)object forKey:(id<NSCopying, NSObject>)key;

- (void)removeObjectForKey:(id<NSCopying, NSObject>)key;

- (void)clear;

- (NSArray *)allKeys;

- (NSArray *)allObjects;

@end
