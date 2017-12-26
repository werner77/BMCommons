//
//  BMSortedSet.m
//  BMCommons
//
//  Created by Werner Altewischer on 25/12/2017.
//

#import "BMSortedSet.h"
#import <BMCommons/BMSortedArray.h>

@implementation BMSortedSet {
    NSMutableSet *_set;
    BMSortedArray *_array;
}

- (id)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [[[self class] allocWithZone:zone] initWithCapacity:self.count];
    copy->_set = [self->_set mutableCopyWithZone:zone];
    copy->_array = [self->_array mutableCopyWithZone:zone];
    return copy;
}

- (instancetype)init {
    if ((self = [super init])) {
        [self commonInitWithCapacity:16];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if ((self = [super init])) {
        [self commonInitWithCapacity:numItems];
    }
    return self;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    if (_set == nil) {
        _set = [[NSMutableSet alloc] initWithCapacity:capacity];
        _array = [[BMSortedArray alloc] initWithCapacity:capacity];
    }
}

- (void)setComparator:(NSComparator)comparator {
    _array.comparator = comparator;
}

- (NSComparator)comparator {
    return _array.comparator;
}

- (void)setSortSelector:(SEL)sortSelector {
    _array.sortSelector = sortSelector;
}

- (SEL)sortSelector {
    return _array.sortSelector;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    _array.sortDescriptors = sortDescriptors;
}

- (NSArray *)sortDescriptors {
    return _array.sortDescriptors;
}

- (NSUInteger)count {
    return _set.count;
}

- (id)member:(id)object {
    return [_set member:object];
}

- (NSEnumerator *)objectEnumerator {
    return [_array objectEnumerator];
}

- (void)addObject:(id)object {
    if (![_set containsObject:object]) {
        [_set addObject:object];
        [_array addObject:object];
    }
}

- (void)removeObject:(id)object {
    if ([_set containsObject:object]) {
        [_set removeObject:object];
        [_array removeObject:object];
    }
}

- (NSArray *)allObjects {
    return [_array copy];
}

@end
