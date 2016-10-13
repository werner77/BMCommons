//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSortedArray.h>

@interface BMSortedArray()

@end

@implementation BMSortedArray {
    NSMutableArray *_array;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    _array = [[NSMutableArray alloc] initWithCapacity:capacity];
}

- (id)init {
    if ((self = [super init])) {
        [self commonInitWithCapacity:16];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    if ((self = [super init])) {
        [self commonInitWithCapacity:capacity];
    }
    return self;
}

#pragma mark - Overridden primitive methods

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self addObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_array removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    [_array addObject:anObject];
    [self sort];
}

- (void)removeLastObject {
    [_array removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_array replaceObjectAtIndex:index withObject:anObject];
    [self sort];
}

- (NSUInteger)count {
    return [_array count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_array objectAtIndex:index];
}

- (void)sort {
    if (self.comparator) {
        [_array sortUsingComparator:self.comparator];
    } else if (self.sortDescriptors) {
        [_array sortUsingDescriptors:self.sortDescriptors];
    } else if (self.sortSelector) {
        [_array sortUsingSelector:self.sortSelector];
    }
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    if (_sortDescriptors != sortDescriptors) {
        _sortDescriptors = sortDescriptors;
        [self sort];
    }
}

- (void)setComparator:(NSComparator)comparator {
    _comparator = [comparator copy];
    [self sort];
}

- (void)setSortSelector:(SEL)sortSelector {
    if (_sortSelector != sortSelector) {
        _sortSelector = sortSelector;
        [self sort];
    }
}

@end