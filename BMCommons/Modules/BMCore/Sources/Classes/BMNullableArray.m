//
// Created by Werner Altewischer on 12/05/2017.
//

#import <Foundation/Foundation.h>
#import "BMNullableArray.h"
#import "NSArray+BMCommons.h"

@interface BMReference : NSObject {
@package
    id __weak _target;
}

+ (instancetype)referenceWithTarget:(id)target;

- (instancetype)initWithTarget:(id)target;

@property (nonatomic, assign) BOOL retainsTarget;

- (id)target;

@end


@implementation BMReference {
    id __strong _strongTarget;
}

+ (instancetype)referenceWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    if ((self = [super init])) {
        _target = target;
    }
    return self;
}

- (void)setRetainsTarget:(BOOL)retainsTarget {
    if (retainsTarget != _retainsTarget) {
        _retainsTarget = retainsTarget;
        if (retainsTarget) {
            _strongTarget = _target;
        } else {
            _strongTarget = nil;
        }
    }
}

- (id)target {
    return _target;
}

@end


@interface BMNullableArray()

@property (nonatomic, strong) NSMutableArray *impl;

@end

@implementation BMNullableArray {
    NSMutableArray *_impl;
}

- (instancetype)init {
    if ((self = [super init])) {
        [self commonInitWithCapacity:0];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if ((self = [super init])) {
        [self commonInitWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _impl = [coder decodeObjectForKey:@"impl"];
        if (_impl == nil) {
            _impl = [[NSMutableArray alloc] init];
        }
        self.retainsObjects = [coder decodeBoolForKey:@"retainsObjects"];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    if ((self = [super init])) {
        [self commonInitWithCapacity:cnt];
        if (objects != nil) {
            for (NSUInteger i = 0; i < cnt; ++i) {
                id obj = objects[i];
                [self addObject:obj];
            }
        }
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)objects {
    if ((self = [self initWithCapacity:objects.count])) {
        [self addObjectsFromArray:objects];
    }
    return self;
}

+ (instancetype)weakReferenceArray {
    BMNullableArray *ret = [[self alloc] init];
    ret.retainsObjects = NO;
    return ret;
}

- (void)setRetainsObjects:(BOOL)retainsObjects {
    if (_retainsObjects != retainsObjects) {
        for (BMReference *ref in _impl) {
            ref.retainsTarget = retainsObjects;
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_impl forKey:@"impl"];
    [coder encodeBool:self.retainsObjects forKey:@"retainsObjects"];
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    if (capacity > 0) {
        _impl = [[NSMutableArray alloc] initWithCapacity:capacity];
    } else {
        _impl = [[NSMutableArray alloc] init];
    }
    self.retainsObjects = YES;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    BMNullableArray *copy = [(BMNullableArray *)[self.class alloc] initWithCapacity:self.count];
    [copy.impl setArray:self.impl];
    return copy;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {

    NSUInteger implCount;
    if (state->state == 0) {
        implCount = _impl.count;
        NSUInteger implBufferLength = [_impl countByEnumeratingWithState:state objects:buffer count:len];
        if (state->itemsPtr != buffer && implBufferLength == implCount) {
            //Optimization: the _impl returned an internal array
            //We can just copy the objects from the array into the buffer
            //Store the pointer to the internal array in extra[0]

            state->extra[0] = (unsigned long)state->itemsPtr;
        } else {
            state->extra[0] = 0;
        }
        state->state = 0;
        state->extra[1] = implCount;
    } else {
        implCount = state->extra[1];
    }

    NSUInteger start = state->state;
    NSUInteger count = MIN(len, implCount - start);

    if (state->extra[0] == 0) {
        for (NSUInteger i = 0, index = start; i < count; ++i, ++index) {
            BMReference *ref = _impl[index];
            buffer[i] = ref->_target;
        }
    } else {
        void *ptr = (void *)state->extra[0];
        id __unsafe_unretained * implBuffer = (id __unsafe_unretained *)ptr;
        for (NSUInteger i = 0, index = start; i < count; ++i, ++index) {
            BMReference *ref = implBuffer[index];
            buffer[i] = ref->_target;
        }
    }
    state->state += count;
    state->itemsPtr = buffer;
    return count;
}

- (void)dealloc {
}

- (void)addObject:(id)anObject {
    [self insertObject:anObject atIndex:self.count];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self removeObjectAtIndex:index];
    [self insertObject:anObject atIndex:index];
}

- (void)removeLastObject {
    [self removeObjectAtIndex:self.count - 1];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    BMReference *ref = [BMReference referenceWithTarget:anObject];
    ref.retainsTarget = self.retainsObjects;
    [_impl insertObject:ref atIndex:index];
}

- (void)removeAllObjects {
    if (_impl.count > 0) {
        [_impl removeAllObjects];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_impl removeObjectAtIndex:index];
}

- (NSUInteger)count {
    return [_impl count];
}

- (id)objectAtIndex:(NSUInteger)index {
    BMReference *ref = _impl[index];
    return ref->_target;
}

- (NSArray *)allObjects {
    return [_impl bmArrayByTransformingObjectsWithBlock:^id(BMReference *ref) {
        return ref->_target;
    }];
}

- (void)compact {
    [_impl bmRetainObjectsWithPredicate:^BOOL(BMReference *ref) {
        return ref->_target != nil;
    }];
}

- (BOOL)containsObjectIdenticalTo:(id)object {
    return [_impl bmFirstObjectWithPredicate:^BOOL(BMReference *ref) {
        return ref->_target == object;
    }] != nil;
}

- (void)removeObjectIdenticalTo:(id)object {
    [_impl bmRemoveObjectsWithPredicate:^BOOL(BMReference *ref) {
        return (ref->_target == object);
    }];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)object {
    NSUInteger __block ret = NSNotFound;
    [_impl bmFirstObjectWithIndexPredicate:^BOOL(BMReference *ref, NSUInteger index) {
        if (ref->_target == object) {
            ret = index;
            return YES;
        }
        return NO;
    }];
    return ret;
}

- (BOOL)containsObject:(id)object {
    return [_impl bmFirstObjectWithPredicate:^BOOL(BMReference *ref) {
        return (ref->_target == object || [ref->_target isEqual:object]);
    }] != nil;
}

- (void)removeObject:(id)object {
    [_impl bmRemoveObjectsWithPredicate:^BOOL(BMReference *ref) {
        return (ref->_target == object || [ref->_target isEqual:object]);
    }];
}

- (NSUInteger)indexOfObject:(id)object {
    NSUInteger __block ret = NSNotFound;
    [_impl bmFirstObjectWithIndexPredicate:^BOOL(BMReference *ref, NSUInteger index) {
        if (ref->_target == object || [ref->_target isEqual:object]) {
            ret = index;
            return YES;
        }
        return NO;
    }];
    return ret;
}

- (void)addObjectsFromArray:(NSArray *)objects {
    for (id obj in objects) {
        [self addObject:obj];
    }
}

@end
