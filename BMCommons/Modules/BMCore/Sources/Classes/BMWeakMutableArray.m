//
// Created by Werner Altewischer on 12/05/2017.
//

#import <Foundation/Foundation.h>
#import "BMWeakMutableArray.h"
#import "BMWeakReference.h"
#import "BMWeakReferenceRegistry.h"

@interface BMWeakMutableArray()

@property (nonatomic, strong) NSMutableArray *impl;

@end

@implementation BMWeakMutableArray {
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
    BMWeakMutableArray *copy = [(BMWeakMutableArray *)[self.class alloc] initWithCapacity:self.count];
    [copy.impl setArray:self.impl];
    return copy;
}

- (void)dealloc {
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer
                                    count:(NSUInteger)len {
    NSUInteger count = 0;

    if (_impl.count > 0) {

        if(state->state == 0) {
            //Start
            NSRange range = NSMakeRange(0, _impl.count);

            __unsafe_unretained id *references = (__unsafe_unretained id *)malloc(sizeof(id) * range.length);
            [_impl getObjects:references range:range];

            for (NSUInteger i = 0; i < range.length; ++i) {
                BMWeakReference *ref = references[i];
                references[i] = ref.target;
            }

            state->mutationsPtr = (__bridge void *)self;
            state->itemsPtr = references;
            state->state = 1;
            state->extra[0] = (unsigned long)references;
        } else {
            void * references = (void *)state->extra[0];
            free(references);
        }
    }
    return count;
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