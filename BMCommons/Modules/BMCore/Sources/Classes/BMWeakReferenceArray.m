//
// Created by Werner Altewischer on 12/05/2017.
//

#import "BMWeakReferenceArray.h"
#import "BMWeakReference.h"
#import "BMWeakReferenceRegistry.h"

@interface BMWeakReferenceArray()

@property (nonatomic, strong) NSMutableArray *impl;

@end

@implementation BMWeakReferenceArray {
    NSMutableArray *_impl;
}

- (id)init {
    if ((self = [super init])) {
        [self commonInitWithCapacity:0];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)numItems {
    if ((self = [super init])) {
        [self commonInitWithCapacity:numItems];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _impl = [coder decodeObjectForKey:@"impl"];
        if (_impl == nil) {
            _impl = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_impl forKey:@"impl"];
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    @synchronized (self) {
        if (capacity > 0) {
            _impl = [[NSMutableArray alloc] initWithCapacity:capacity];
        } else {
            _impl = [[NSMutableArray alloc] init];
        }
    }
}

- (id)copyWithZone:(nullable NSZone *)zone {
    BMWeakReferenceArray *copy = [(BMWeakReferenceArray *)[self.class alloc] initWithCapacity:self.count];
    [copy.impl setArray:self.impl];
    return copy;
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
    if (anObject) {
        BMWeakReference *ref = [BMWeakReference weakReferenceWithTarget:anObject];
        [_impl insertObject:ref atIndex:index];
    }
}

- (void)removeAllObjects {
    [_impl removeAllObjects];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_impl removeObjectAtIndex:index];
}

- (NSUInteger)count {
    return [_impl count];
}

- (id)objectAtIndex:(NSUInteger)index {
    BMWeakReference *ref = _impl[index];
    return ref.target;
}

- (NSArray *)allObjects {
    return [_impl bmArrayByTransformingObjectsWithBlock:^id(BMWeakReference *ref) {
        return ref.target;
    }];
}

- (void)compact {
    [_impl bmRetainObjectsWithPredicate:^BOOL(BMWeakReference *ref) {
        return ref.target != nil;
    }];
}

- (BOOL)containsObjectIdenticalTo:(id)object {
    return [_impl bmFirstObjectWithPredicate:^BOOL(BMWeakReference *ref) {
        return ref.target == object;
    }] != nil;
}

- (void)removeObjectIdenticalTo:(id)object {
    [_impl bmRemoveObjectsWithPredicate:^BOOL(BMWeakReference *ref) {
        return ref.target == object;
    }];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)object {
    NSUInteger __block ret = NSNotFound;
    [_impl bmFirstObjectWithIndexPredicate:^BOOL(BMWeakReference *ref, NSUInteger index) {
        if (ref.target == object) {
            ret = index;
            return YES;
        }
        return NO;
    }];
    return ret;
}


@end