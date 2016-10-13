//
//  TwoWayDictionary.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMTwoWayDictionary.h"
#import <BMCommons/BMCore.h>

@implementation BMTwoWayDictionary

@synthesize localizeValues, localizeKeys;

+ (void)getObjects:(NSArray **)objects andKeys:(NSArray **)keys fromArgs:(NSArray *)args {
	NSUInteger maxCount = (args.count / 2) * 2;
	NSMutableArray *theObjects = [NSMutableArray new];
	NSMutableArray *theKeys = [NSMutableArray new];
	for (NSUInteger i = 0; i < maxCount; ++i) {
		id arg = args[i];
		if (i % 2 == 0) {
			[theObjects addObject:arg];
		} else {
			[theKeys addObject:arg];
		}
	}
	if (objects) {
		*objects = theObjects;
	}
	if (keys) {
		*keys = theKeys;
	}
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
	NSArray *objects = nil;
	NSArray *keys = nil;
	NSArray *args = BM_PARSE_VARARGS(firstObject);
	[self getObjects:&objects andKeys:&keys fromArgs:args];
	BMTwoWayDictionary *ret = [[BMTwoWayDictionary alloc] initWithObjects:objects forKeys:keys];
	return ret;
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
	NSArray *objects = nil;
	NSArray *keys = nil;
	NSArray *args = BM_PARSE_VARARGS(firstObject);
	[self.class getObjects:&objects andKeys:&keys fromArgs:args];
	return [self initWithObjects:objects forKeys:keys];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
	BMTwoWayDictionary *ret = [[BMTwoWayDictionary alloc] initWithObjects:objects forKeys:keys];
	return ret;
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
	if ((self = [super init])) {	
		forwardDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
		reverseDictionary = [[NSDictionary alloc] initWithObjects:keys forKeys:objects];
	}
	return self;
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSArray *keys = [dictionary allKeys];
    NSMutableArray *values = [NSMutableArray array];
    for (id key in keys) {
        id value = [dictionary objectForKey:key];
        [values addObject:value];
    }
    return [self initWithObjects:values forKeys:keys];
}

- (void)dealloc {
	BM_RELEASE_SAFELY(forwardDictionary);
	BM_RELEASE_SAFELY(reverseDictionary);
}

- (id)objectForKey:(id)aKey {
	id object = [forwardDictionary objectForKey:aKey];
	if (self.localizeValues && [object isKindOfClass:[NSString class]]) {
		object = BMLocalizedString(object, nil);
	}
	return object;
}

- (id)keyForObject:(id)object {
	id key = [reverseDictionary objectForKey:object];
	if (self.localizeKeys && [key isKindOfClass:[NSString class]]) {
		key = BMLocalizedString(key, nil);
	}
	return key;
}

- (NSArray *)allKeys {
	return [forwardDictionary allKeys];
}

- (NSArray *)allValues {
	return [forwardDictionary allValues];
}

@end
