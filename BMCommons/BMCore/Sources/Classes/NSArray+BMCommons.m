//
//  NSArray+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import "NSArray+BMCommons.h"
#import "NSObject+BMCommons.h"
#import "BMBlockValueTransformer.h"
#import <BMCommons/BMCore.h>

@implementation NSArray (BMCommons)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bmPerformSelectorOnAllObjects:(SEL)selector {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1 {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:p1];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1 withObject:(id)p2 {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:p1 withObject:p2];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bmPerformSelectorOnAllObjects:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
    NSArray *copy = [[NSArray alloc] initWithArray:self];
    NSEnumerator* e = [copy objectEnumerator];
    for (id delegate; (delegate = [e nextObject]); ) {
        if ([delegate respondsToSelector:selector]) {
            [delegate bmPerformSelector:selector withObject:p1 withObject:p2 withObject:p3];
        }
    }
}

- (id)bmFirstObject {
    return self.count > 0 ? [self objectAtIndex:0] : nil;
}

- (BOOL)bmContainsAllObjects:(NSArray *)other {
    BOOL ret = YES;
    for (id object in other) {
        if (![self containsObject:object]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (id)bmSafeObjectAtIndex:(NSUInteger)index {
    return [self bmSafeObjectAtIndex:index ofClass:nil];
}

- (id)bmSafeObjectAtIndex:(NSUInteger)index ofClass:(Class)c {
    if (index < self.count) {
        id o = [self objectAtIndex:index];
        if (c == nil || [o isKindOfClass:c]) {
            return o;
        }
    } 
    return nil;
}

- (BOOL)bmContainsObjectIdenticalTo:(id)otherObject {
    return [self indexOfObjectIdenticalTo:otherObject] != NSNotFound;
}

- (instancetype)bmDeepCopy {
    NSArray *a = (NSArray *)[[self class] alloc];
    return [a initWithArray:self copyItems:YES];
}

- (NSArray *)bmArrayByReversingOrder {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (NSUInteger i = self.count - 1; i < self.count; --i) {
        [ret addObject:self[i]];
    }
    return ret;
}

- (NSArray *)bmArrayByTransformingObjectsWithTransformer:(NSValueTransformer *)valueTransformer {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id objIn in self) {
        id objOut = [valueTransformer transformedValue:objIn];
        if (objOut != nil) {
            [ret addObject:objOut];
        }
    }
    return ret;
}

- (NSArray *)bmArrayByTransformingObjectsWithBlock:(id (^)(id))block {
    return [self bmArrayByTransformingObjectsWithTransformer:[BMBlockValueTransformer valueTransformerWithTransformationBlock:block]];
}

- (id)bmFirstObjectWithPredicate:(BOOL(^)(id object))predicate {
    return [self bmFirstObjectWithIndexPredicate:^(id object, NSUInteger index) {
        BOOL ret = NO;
        if (predicate) {
            ret = predicate(object);
        }
        return ret;
    }];
}

- (id)bmArrayFilteredWithPredicate:(BOOL(^)(id object))predicate {
    return [self bmArrayFilteredWithIndexPredicate:^(id object, NSUInteger index) {
        BOOL ret = NO;
        if (predicate) {
            ret = predicate(object);
        }
        return ret;
    }];
}

- (id)bmFirstObjectWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate {
    id ret = nil;
    NSUInteger i = 0;
    for (id obj in self) {
        if (predicate != nil && predicate(obj, i)) {
            ret = obj;
            break;
        }
        i++;
    }
    return ret;
}

- (id)bmArrayFilteredWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    NSUInteger i = 0;
    for (id obj in self) {
        if (predicate != nil && predicate(obj, i)) {
            [ret addObject:obj];
        }
        i++;
    }
    return ret;
}

- (NSArray <NSArray *> *)bmArraysBySplittingWithCount:(NSUInteger)count {
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:count];
	for (NSUInteger i = 0; i < self.count ; ++i) {
		NSUInteger remainder = i % count;
		NSMutableArray *a = nil;
		if (remainder < ret.count) {
			a = ret[remainder];
		} else {
			a = [NSMutableArray new];
			[ret addObject:a];
		}
		[a addObject:self[i]];
	}
	return ret;
}

+ (NSArray *)bmArrayWithConstantValue:(id)value count:(NSUInteger)count {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; ++i) {
        if (value) {
            [ret addObject:value];
        }
    }
    return ret;
}


@end

@implementation NSMutableArray(BMCommons)

- (void)bmSafeAddObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

- (void)bmRemoveObjectsIdenticalToObjectsInArray:(NSArray *)otherArray {
    for (id obj in otherArray) {
        [self removeObjectIdenticalTo:obj];
    }
}

- (void)bmMoveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    id object = [self bmSafeObjectAtIndex:fromIndex];
    if (object && toIndex <= self.count) {
        [self removeObjectAtIndex:fromIndex];
        [self insertObject:object atIndex:toIndex];
    }
}

- (void)bmMoveObject:(id)object toIndex:(NSUInteger)index {
    NSUInteger oriIndex = [self indexOfObjectIdenticalTo:object];
    if (oriIndex != NSNotFound) {
        [self bmMoveObjectFromIndex:oriIndex toIndex:index];
    }
}

- (id)bmPopObjectAtIndex:(NSUInteger)index {
    id ret = [self bmSafeObjectAtIndex:index];
    if (ret) {
        [self removeObjectAtIndex:index];
    }
    return ret;
}

- (id)bmPopFirstObject {
    return [self bmPopObjectAtIndex:0];
}

- (id)bmPopLastObject {
    return [self bmPopObjectAtIndex:(self.count - 1)];
}

- (void)bmRetainObjectsWithPredicate:(BOOL(^)(id object))predicate {
    NSArray *retainArray = [self bmArrayFilteredWithPredicate:predicate];
    [self setArray:retainArray];
}

- (void)bmRetainObjectsWithIndexPredicate:(BOOL(^)(id object, NSUInteger index))predicate {
    NSArray *retainArray = [self bmArrayFilteredWithIndexPredicate:predicate];
    [self setArray:retainArray];
}

@end
