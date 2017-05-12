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
@interface BMWeakReferenceArray<__covariant ObjectType> : NSObject<NSCopying, NSCoding>

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic, copy) NSArray<ObjectType> *allObjects;
@property (readonly, nonatomic) NSUInteger count;

- (nullable ObjectType)objectAtIndex:(NSUInteger)index;

- (void)addObject:(nullable ObjectType)object;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObject:(nullable ObjectType)object atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(nullable ObjectType)object;
- (void)compact;
- (BOOL)containsObjectIdenticalTo:(nullable ObjectType)object;
- (void)removeObjectIdenticalTo:(nullable ObjectType)object;
- (NSUInteger)indexOfObjectIdenticalTo:(nullable ObjectType)object;

@end

NS_ASSUME_NONNULL_END