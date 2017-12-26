//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSortedDictionary.h>
#import "NSArray+BMCommons.h"
#import <BMCommons/BMSortedArray.h>

@implementation BMSortedDictionary {
    NSMutableDictionary *_dictionary;
    BMSortedArray *_keys;
}

- (id)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [[[self class] allocWithZone:zone] initWithCapacity:self.count];
    copy->_dictionary = [self->_dictionary mutableCopyWithZone:zone];
    copy->_keys = [self->_keys mutableCopyWithZone:zone];
    return copy;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    [super commonInitWithCapacity:capacity];
    if (_dictionary == nil) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _keys = [[BMSortedArray alloc] initWithCapacity:capacity];
    }
}

- (void)setComparator:(NSComparator)comparator {
    _keys.comparator = comparator;
}

- (NSComparator)comparator {
    return _keys.comparator;
}

- (void)setSortSelector:(SEL)sortSelector {
    _keys.sortSelector = sortSelector;
}

- (SEL)sortSelector {
    return _keys.sortSelector;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    _keys.sortDescriptors = sortDescriptors;
}

- (NSArray *)sortDescriptors {
    return _keys.sortDescriptors;
}

#pragma mark - Abstract method implementations

- (NSMutableArray *)keysInternal {
    return _keys;
}

- (NSMutableDictionary *)dictionaryInternal {
    return _dictionary;
}

@end
