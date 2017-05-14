//
// Created by Werner Altewischer on 12/05/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A thread safe mutable array that maintains weak references to the objects being stored.
 *
 * It safely removes deallocated objects from the array automatically.
 */
@interface BMNullableArray<__covariant ObjectType> : NSObject<NSCopying, NSCoding, NSFastEnumeration>

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObjects:(const ObjectType _Nullable [_Nullable])objects count:(NSUInteger)cnt NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/**
 * Initializes with the objects from the specified array.
 *
 * @param objects
 * @return
 */
- (instancetype)initWithArray:(NSArray *)objects;

/**
 * Returns a BMNullableArray which does not retain its objects. Elements will become nil if the objects get deallocated.
 *
 * @return
 */
+ (instancetype)weakReferenceArray;

/**
 * Returns all non-nill objects as an ordinary array.
 */
@property (readonly, nonatomic, copy) NSArray<ObjectType> *allObjects;

/**
 * The total count of the array.
 */
@property (readonly, nonatomic) NSUInteger count;

/**
 * Whether the objects in the array are strongly referenced or not.
 *
 * Defaults to YES. Set to NO to weakly reference the containing objects. They may become nil if they get deallocated.
 */
@property (assign, nonatomic) BOOL retainsObjects;

//Standard array functions
- (nullable ObjectType)objectAtIndex:(NSUInteger)index;

- (void)addObject:(nullable ObjectType)object;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObject:(nullable ObjectType)object atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(nullable ObjectType)object;

- (void)addObjectsFromArray:(NSArray *)objects;

- (BOOL)containsObjectIdenticalTo:(nullable ObjectType)object;
- (void)removeObjectIdenticalTo:(nullable ObjectType)object;
- (NSUInteger)indexOfObjectIdenticalTo:(nullable ObjectType)object;

- (BOOL)containsObject:(nullable ObjectType)object;
- (void)removeObject:(nullable ObjectType)object;
- (NSUInteger)indexOfObject:(nullable ObjectType)object;

/**
 * Removes all nil objects from the array.
 */
- (void)compact;

@end

NS_ASSUME_NONNULL_END