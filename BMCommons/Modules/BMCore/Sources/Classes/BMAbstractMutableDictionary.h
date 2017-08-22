//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAbstractMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

/**
 Returns the key at the specified index.
 */
- (KeyType)keyAtIndex:(NSUInteger)anIndex;

/**
 Returns the object at the specified index.
 */
- (ObjectType)objectAtIndex:(NSUInteger)anIndex;

/**
 Returns the key for the specified index or nil if the index is out of bounds.
 */
- (nullable KeyType)safeKeyAtIndex:(NSUInteger)anIndex;

/**
 Returns the object for the specified index or nil if the index is out of bounds.
 */
- (nullable ObjectType)safeObjectAtIndex:(NSUInteger)anIndex;

/**
 * Enumerates objects in reverse order.
 */
- (NSEnumerator<ObjectType> *)reverseObjectEnumerator;

/**
 * Enumerates keys in reverse order.
 */
- (NSEnumerator<KeyType> *)reverseKeyEnumerator;

@end

@interface BMAbstractMutableDictionary<KeyType, ObjectType>(Protected)

/**
 * To be implemented by sub classes
 */
- (NSMutableArray<KeyType> *)keysInternal;
- (NSMutableDictionary<KeyType, ObjectType> *)dictionaryInternal;
- (void)commonInitWithCapacity:(NSUInteger)capacity;

@end

NS_ASSUME_NONNULL_END