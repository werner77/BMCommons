//
//  BMCache.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/23/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Thread safe cache implementation with a LRU eviction policy.
 
 The cache has a configurable timeout interval for the objects it retains and a maximum size.
 */
@interface BMCache : BMCoreObject

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
- (nullable id)objectForKey:(id <NSCopying, NSObject>)key;

/**
 * Returns true iff the cache contains an object for the specified key.
 */
- (BOOL)hasObjectForKey:(id<NSCopying, NSObject>)key;

/**
 * Sets the specified object for the specified key.
 */
- (void)setObject:(id)object forKey:(id<NSCopying, NSObject>)key;

/**
 * Removes the object for the specified key if it exists.
 */
- (void)removeObjectForKey:(id<NSCopying, NSObject>)key;

/**
 * Clears the entire cache.
 */
- (void)clear;

/**
 * Copied array containing all the keys of the cache.
 */
- (NSArray *)allKeys;

/**
 * Copied array containing all the objects in the cache.
 */
- (NSArray *)allObjects;

@end

NS_ASSUME_NONNULL_END
