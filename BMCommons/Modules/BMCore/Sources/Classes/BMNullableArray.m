//
// Created by Werner Altewischer on 12/05/2017.
//

#import <Foundation/Foundation.h>
#import "BMNullableArray.h"
#import "NSArray+BMCommons.h"
#import "BMWeakReferenceRegistry.h"

@interface BMReference : NSObject {
@package
    id __weak _target;
    NSUInteger __volatile _targetAddress;
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
        _targetAddress = (NSUInteger)target;
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

#define SAME(ref, obj) (ref->_targetAddress == (NSUInteger)obj)
#define EQUAL(ref, obj) (ref->_targetAddress == (NSUInteger)obj || [ref->_target isEqual:obj])

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

    BMReference *__weak weakRef = ref;
    [[BMWeakReferenceRegistry sharedInstance] registerReference:ref->_target forOwner:self withCleanupBlock:^{
        BMReference * __strong strongRef = weakRef;
        if (strongRef) {
            strongRef->_targetAddress = 0;
        }
    }];
}

- (void)removeAllObjects {
    if (_impl.count > 0) {
        for (BMReference *ref in _impl) {
            [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref->_target forOwner:self];
        }
        [_impl removeAllObjects];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    BMReference *ref = [_impl objectAtIndex:index];
    [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref->_target forOwner:self];
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
        BOOL ret = ref->_target != nil;
        return ret;
    }];
}

- (BOOL)containsObjectIdenticalTo:(id)object {
    return [_impl bmFirstObjectWithPredicate:^BOOL(BMReference *ref) {
        return SAME(ref, object);
    }] != nil;
}

- (void)removeObjectIdenticalTo:(id)object {
    [_impl bmRemoveObjectsWithPredicate:^BOOL(BMReference *ref) {
        BOOL ret = SAME(ref, object);
        if (ret) {
            [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref->_target forOwner:self];
        }
        return ret;
    }];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)object {
    NSUInteger __block ret = NSNotFound;
    [_impl bmFirstObjectWithIndexPredicate:^BOOL(BMReference *ref, NSUInteger index) {
        if (SAME(ref, object)) {
            ret = index;
            return YES;
        }
        return NO;
    }];
    return ret;
}

- (BOOL)containsObject:(id)object {
    return [_impl bmFirstObjectWithPredicate:^BOOL(BMReference *ref) {
        return EQUAL(ref, object);
    }] != nil;
}

- (void)removeObject:(id)object {
    [_impl bmRemoveObjectsWithPredicate:^BOOL(BMReference *ref) {
        BOOL ret = EQUAL(ref, object);
        if (ret) {
            [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref->_target forOwner:self];
        }
        return ret;
    }];
}

- (NSUInteger)indexOfObject:(id)object {
    NSUInteger __block ret = NSNotFound;
    [_impl bmFirstObjectWithIndexPredicate:^BOOL(BMReference *ref, NSUInteger index) {
        if (EQUAL(ref, object)) {
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
