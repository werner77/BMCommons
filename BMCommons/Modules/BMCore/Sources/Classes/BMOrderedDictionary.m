//
//  BMOrderedDictionary.m
//  BMOrderedDictionary
//

#import <BMCommons/BMAbstractMutableDictionary.h>
#import <BMCommons/BMOrderedDictionary.h>
#import "NSArray+BMCommons.h"

@implementation BMOrderedDictionary {
	NSMutableDictionary *_dictionary;
	NSMutableArray *_keys;
}


#pragma mark - Public methods

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	[_keys bmMoveObjectFromIndex:fromIndex toIndex:toIndex];
}

- (BOOL)moveObjectForKey:(id)aKey toIndex:(NSUInteger)toIndex {
    NSUInteger index = [_keys indexOfObject:aKey];
    BOOL found = (index != NSNotFound);
    if (found) {
        [_keys removeObjectAtIndex:index];
        [_keys insertObject:aKey atIndex:toIndex];
    }
    return found;
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex
{
	if ([self objectForKey:aKey]) {
		[self removeObjectForKey:aKey];
	}
	[_keys insertObject:aKey atIndex:anIndex];
	[_dictionary setObject:anObject forKey:aKey];
}

#pragma mark - Abstract method implementations

- (NSMutableArray *)keysInternal {
	return _keys;
}

- (NSMutableDictionary *)dictionaryInternal {
	return _dictionary;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {
	[super commonInitWithCapacity:capacity];
	_dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
	_keys = [[NSMutableArray alloc] initWithCapacity:capacity];
}

@end
