//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BMAbstractMutableDictionary : NSMutableDictionary

/**
 Returns the key at the specified index.
 */
- (id)keyAtIndex:(NSUInteger)anIndex;

/**
 Returns the object at the specified index.
 */
- (id)objectAtIndex:(NSUInteger)anIndex;

/**
 Returns the key for the specified index or nil if the index is out of bounds.
 */
- (id)safeKeyAtIndex:(NSUInteger)anIndex;

/**
 Returns the object for the specified index or nil if the index is out of bounds.
 */
- (id)safeObjectAtIndex:(NSUInteger)anIndex;

/**
 * Enumerates objects in reverse order.
 */
- (NSEnumerator *)reverseObjectEnumerator;

/**
 * Enumerates keys in reverse order.
 */
- (NSEnumerator *)reverseKeyEnumerator;

@end

@interface BMAbstractMutableDictionary(Protected)

/**
 * To be implemented by sub classes
 */
- (NSMutableArray *)keysInternal;
- (NSMutableDictionary *)dictionaryInternal;
- (void)commonInitWithCapacity:(NSUInteger)capacity;

@end

