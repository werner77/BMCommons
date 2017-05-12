//
// Created by Werner Altewischer on 12/05/2017.
//

#import "BMWeakMutableArray.h"
#import "BMWeakReference.h"
#import "BMWeakReferenceRegistry.h"

@interface BMWeakMutableArray()

@property (nonatomic, strong) NSMutableArray *impl;

@end

@implementation BMWeakMutableArray {
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
    if ((self = [super initWithCoder:coder])) {
        [self commonInitWithCapacity:0];
    }
    return self;
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
    @synchronized (self) {
        BMWeakMutableArray *copy = (BMWeakMutableArray *)[self.class alloc];
        [copy initWithCapacity:self.count];
        [copy addObjectsFromArray:self];
        return copy;
    }
}

- (void)dealloc {
    [self removeAllObjects];
}

- (void)addObject:(id)anObject {
    @synchronized(self) {
        [self insertObject:anObject atIndex:self.count];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    @synchronized(self) {
        [self removeObjectAtIndex:index];
        [self insertObject:anObject atIndex:index];
    }
}

- (void)removeLastObject {
    @synchronized(self) {
        [self removeObjectAtIndex:self.count - 1];
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    @synchronized(self) {
        if (anObject) {
            BMWeakReference *ref = [BMWeakReference weakReferenceWithTarget:anObject];
            [_impl insertObject:ref atIndex:index];

            __typeof(self) __weak weakSelf = self;
            [[BMWeakReferenceRegistry sharedInstance] registerReference:anObject forOwner:self withCleanupBlock:^{
                @synchronized (weakSelf) {
                    [weakSelf.impl removeObjectIdenticalTo:ref];
                }
            }];
        }
    }
}

- (void)removeAllObjects {
    @synchronized (self) {
        for (BMWeakReference *ref in _impl) {
            [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref.target forOwner:self];
        }
        [_impl removeAllObjects];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    @synchronized (self) {
        BMWeakReference *ref = _impl[index];
        if (ref != nil) {
            [[BMWeakReferenceRegistry sharedInstance] deregisterReference:ref.target forOwner:self];
            [_impl removeObjectAtIndex:index];
        }
    }
}

- (NSUInteger)count {
    @synchronized (self) {
        return [_impl count];
    }
}

- (id)objectAtIndex:(NSUInteger)index {
    @synchronized (self) {
        BMWeakReference *ref = _impl[index];
        return ref.target;
    }
}

@end