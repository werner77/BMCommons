//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMAbstractMutableDictionary.h"

@implementation BMAbstractMutableDictionary {

}

static NSString *DescriptionForObject(NSObject *object, id locale, NSUInteger indent)
{
	NSString *objectString;
	if ([object isKindOfClass:[NSString class]])
	{
		objectString = (NSString *)object;
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
	{
		objectString = [(NSDictionary *)object descriptionWithLocale:locale indent:indent];
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
	{
		objectString = [(NSSet *)object descriptionWithLocale:locale];
	}
	else
	{
		objectString = [object description];
	}
	return objectString;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
	NSMutableString *indentString = [NSMutableString string];
	NSUInteger i, count = level;
	for (i = 0; i < count; i++)
	{
		[indentString appendFormat:@"    "];
	}

	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@{\n", indentString];
	for (NSObject *key in self)
	{
		[description appendFormat:@"%@    %@ = %@;\n",
			indentString,
			DescriptionForObject(key, locale, level),
			DescriptionForObject([self objectForKey:key], locale, level)];
	}
	[description appendFormat:@"%@}\n", indentString];
	return description;
}

- (instancetype)initWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt {
	if ((self = [super init])) {
		[self commonInitWithCapacity:cnt];
		for (NSUInteger i = 0 ; i < cnt; ++i) {
			id key = [keys[i] copyWithZone:nil];
			id value = objects[i];
			[self setObject:value forKey:key];
		}
	}
	return self;
}

- (id)init
{
	if ((self = [super init])) {
		[self commonInitWithCapacity:16];
	}
	return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	if ((self = [super init]))
	{
		[self commonInitWithCapacity:capacity];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] allocWithZone:zone] initWithCapacity:self.count];
	[copy addEntriesFromDictionary:self];
	return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	return [self copyWithZone:zone];
}


- (id)keyAtIndex:(NSUInteger)anIndex
{
	return [self.keysInternal objectAtIndex:anIndex];
}

- (NSEnumerator *)keyEnumerator
{
	return [self.keysInternal objectEnumerator];
}

#pragma mark - Primitive methods of NSDictionary

- (NSUInteger)count
{
	return [self.dictionaryInternal count];
}

- (id)objectForKey:(id)aKey
{
	return [self.dictionaryInternal objectForKey:aKey];
}

#pragma mark - Primitive methods of NSMutableDictionary

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (![self.dictionaryInternal objectForKey:aKey])
	{
		[self.keysInternal addObject:aKey];
	}
	[self.dictionaryInternal setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
	[self.dictionaryInternal removeObjectForKey:aKey];
	[self.keysInternal removeObject:aKey];
}

/**
 Returns the key for the specified index or nil if the index is out of bounds.
 */
- (id)safeKeyAtIndex:(NSUInteger)anIndex {
	return anIndex < self.count ? [self keyAtIndex:anIndex] : nil;
}

/**
 Returns the object for the specified index or nil if the index is out of bounds.
 */
- (id)safeObjectAtIndex:(NSUInteger)anIndex {
	return anIndex < self.count ? [self objectAtIndex:anIndex] : nil;
}

/**
 Returns the object at the specified index.
 */
- (id)objectAtIndex:(NSUInteger)anIndex {
	id key = [self keyAtIndex:anIndex];
	return key == nil ? nil : [self objectForKey:key];
}

- (NSMutableArray *)keysInternal {
	return nil;
}

- (NSMutableDictionary *)dictionaryInternal {
	return nil;
}

- (void)commonInitWithCapacity:(NSUInteger)capacity {

}

- (NSEnumerator *)reverseKeyEnumerator
{
	return [self.keysInternal reverseObjectEnumerator];
}

- (NSArray *)allKeys {
	return [NSArray arrayWithArray:self.keysInternal];
}

- (NSArray *)allValues {
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
	for (id key in self.keysInternal) {
		id value = [self objectForKey:key];
		if (value != nil) {
			[ret addObject:value];
		}
	}
	return ret;
}

- (NSEnumerator *)objectEnumerator {
	return [[self allValues] objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator {
	return [[self allValues] reverseObjectEnumerator];
}

@end