//
//  NSArray+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Handy additions to the NSArray class.
 */
@interface NSArray (BMCommons)

/**
 Performs the supplied selector on all objects in this array.
 */
- (void)bmPerformSelectorOnAllObjects:(SEL)selector;
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1;
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1 withObject:(id)p2;
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;

/**
 First object in the array or nil if count == 0
 
 @return The object or nil if the array contains no objects.
 */
- (id)bmFirstObject;

/**
 Returns true iff this object contains all objects in the supplied array using the equals method for each object.
 */
- (BOOL)bmContainsAllObjects:(NSArray *)other;

/**
 Type safe version of [NSArray objectAtIndex:]. 
 
 Returns nil if the object is no instance of the supplied class or if the index is out of bounds.
 */
- (id)bmSafeObjectAtIndex:(NSUInteger)index ofClass:(Class)c;

/**
 Safe version of [NSArray objectAtIndex:].
 
 Returns nil if the index is out of bounds.
 */
- (id)bmSafeObjectAtIndex:(NSUInteger)index;

/**
 Returns true iff for any object o1 in this array o1 == otherObject.
 */
- (BOOL)bmContainsObjectIdenticalTo:(id)otherObject;

/**
 Returns a deep copy of the array.
 */
- (instancetype)bmDeepCopy;

/**
 * Returns a copy of the array with the order reversed
 */
- (NSArray *)bmArrayByReversingOrder;

/**
 * Returns a new array with the objects transformed using the specified value transformer.
 *
 * If the value transformer returns nil for an object, the object is removed from the array.
 */
- (NSArray *)bmArrayByTransformingObjectsWithTransformer:(NSValueTransformer *)valueTransformer;

/**
 * Returns a new array with the objects transformed using the specified block.
 *
 * If the block code returns nil for an object, the object is removed from the array.
 */
- (NSArray *)bmArrayByTransformingObjectsWithBlock:(id (^)(id object))block;

/**
 * Returns the first object in the array for which the predicate block returns YES.
 */
- (id)bmFirstObjectWithPredicate:(BOOL(^)(id object))predicate;

/**
 * Returns the first object in the array for which the predicate block returns YES.
 */
- (id)bmFirstObjectWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate;

/**
 * Returns a new array retaining only the objects for which the predicate block returns YES.
 */
- (id)bmArrayFilteredWithPredicate:(BOOL(^)(id object))predicate;

/**
 * Returns a new array retaining only the objects for which the predicate block returns YES.
 */
- (id)bmArrayFilteredWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate;

/**
 * Splits the receiver up into multiple arrays be equally dividing the values.
 *
 * Count specifies the number of arrays to return.
 */
- (NSArray <NSArray *> *)bmArraysBySplittingWithCount:(NSUInteger)count;

/**
 * Returns an array filled with the specific constant value and specified count.
 */
+ (NSArray *)bmArrayWithConstantValue:(id)value count:(NSUInteger)count;

@end

@interface NSMutableArray(BMCommons)

/**
 First checks if the object is not nil. If so it calls [NSMutableArray addObject].
 */
- (void)bmSafeAddObject:(id)object;

/**
 Removes all objects that are identical to the objects in the specified array.
 */
- (void)bmRemoveObjectsIdenticalToObjectsInArray:(NSArray *)otherArray;

/**
 Moves the object at the specified fromIndex to the specified toIndex.
 */
- (void)bmMoveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 Moves the specified object (if existent in this array) to the specified index.
 */
- (void)bmMoveObject:(id)object toIndex:(NSUInteger)index;

/**
 * Removes and returns the object at the specified index if existent.
 *
 * Returns nil otherwise.
 */
- (id)bmPopObjectAtIndex:(NSUInteger)index;

/**
 * Removes and returns the first object if existent.
 *
 * Returns nil otherwise.
 */
- (id)bmPopFirstObject;

/**
 * Removes and returns the last object if existent.
 *
 * Returns nil otherwise.
 */
- (id)bmPopLastObject;

/**
 * Retains all objects passing the test with the specified predicate block. Removes all other objects.
 */
- (void)bmRetainObjectsWithPredicate:(BOOL(^)(id object))predicate;

/**
 * Retains all objects passing the test with the specified predicate block. Removes all other objects.
 */
- (void)bmRetainObjectsWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate;

/**
 * Removes all objects passing the test with the specified predicate block. Retains all other objects.
 */
- (void)bmRemoveObjectsWithPredicate:(BOOL(^)(id object))predicate;

/**
 * Removes all objects passing the test with the specified predicate block. Retains all other objects.
 */
- (void)bmRemoveObjectsWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate;

@end