//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSortedArray.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSInvocation+BMCommons.h>

@interface BMSortedArray()

@property(nonatomic, copy) NSComparator internalComparator;

@end

@implementation BMSortedArray {
    NSMutableArray *_array;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
    if (_array == nil) {
        _array = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        __typeof(self) __weak weakSelf = self;
        self.internalComparator = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            typeof(self) __strong strongSelf = weakSelf;
            NSComparator comparator;
            NSArray *sortDescriptors;
            SEL sortSelector;
            if ((comparator = strongSelf.comparator) != nil) {
                return comparator(obj1, obj2);
            } else if ((sortDescriptors = strongSelf.sortDescriptors) != nil) {
                for (NSSortDescriptor *sortDescriptor in sortDescriptors) {
                    NSComparisonResult result = [sortDescriptor compareObject:obj1 toObject:obj2];
                    if (result != NSOrderedSame) {
                        return result;
                    }
                }
                return NSOrderedSame;
            } else if ((sortSelector = strongSelf.sortSelector) != NULL) {
                NSComparisonResult result;
                void *args[] = {&obj2};
                NSUInteger argSizes[] = {sizeof(id)};
                [obj1 bmInvokeSelector:sortSelector withArgs:args argSizes:argSizes argCount:1 returnBuffer:&result returnLength:sizeof(result)];
                return result;
            }

            NSInteger address1 = (NSInteger)obj1;
            NSInteger address2 = (NSInteger)obj2;
            return address1 < address2 ? NSOrderedAscending : address1 > address2 ? NSOrderedDescending : NSOrderedSame;
        };
    }
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

- (id)initForCopy {
    return [super init];
}

- (id)copyWithZone:(NSZone *)zone {
    BMSortedArray *copy = [[self.class allocWithZone:zone] initForCopy];
    copy.comparator = self.comparator;
    copy.sortDescriptors = self.sortDescriptors;
    copy.sortSelector = self.sortSelector;
    copy.internalComparator = self.internalComparator;
    copy->_array = [self->_array mutableCopyWithZone:zone];
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - Overridden primitive methods

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self addObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_array removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    NSUInteger insertionIndex = [self insertionIndexForObject:anObject];
    [_array insertObject:anObject atIndex:insertionIndex];
}

- (void)removeLastObject {
    [_array removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_array removeObjectAtIndex:index];
    [self addObject:anObject];
}

- (NSUInteger)indexOfObject:(id)object {
    return [_array indexOfObject:object
                   inSortedRange:NSMakeRange(0, _array.count)
                         options:NSBinarySearchingFirstEqual
                 usingComparator:self.internalComparator];
}

- (void)removeObject:(id)anObject {
    NSUInteger index = [self indexOfObject:anObject];
    if (index != NSNotFound) {
        [self removeObjectAtIndex:index];
    }
}

- (NSUInteger)count {
    return [_array count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_array objectAtIndex:index];
}

- (void)sort {
    [_array sortUsingComparator:self.internalComparator];
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

- (NSUInteger)insertionIndexForObject:(id)object {
    return [_array indexOfObject:object
                   inSortedRange:NSMakeRange(0, _array.count)
                         options:NSBinarySearchingInsertionIndex
                 usingComparator:self.internalComparator];
}

@end
