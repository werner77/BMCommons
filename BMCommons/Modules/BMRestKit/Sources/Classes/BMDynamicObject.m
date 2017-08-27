//
//  BMKeyValuePair.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMDynamicObject.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMPropertyMethod.h>

@implementation BMDynamicObject {
	//Dictionary for storing all the fields
	NSMutableDictionary *_fieldDictionary;
}

@synthesize fieldDictionary = _fieldDictionary;

- (id)init {
	if ((self = [super init])) {
		_fieldDictionary = [NSMutableDictionary new];
	}
	return self;
}

- (id)valueForKey:(NSString *)key {
	BMPropertyDescriptor *pd = [[BMPropertyDescriptor alloc] initWithKeyPath:key target:self];
	id ret = [pd callGetter];
	return ret;
}

- (void)setValue:(id)object forKey:(NSString *)key {
	BMPropertyDescriptor *pd = [[BMPropertyDescriptor alloc] initWithKeyPath:key target:self];
	[pd callSetter:object];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	
	BMPropertyMethod *pm = [BMPropertyMethod propertyMethodFromSelector:anInvocation.selector];
	
	if (pm) {
		if (pm.isSetter) {
			id object = nil;
			[anInvocation getArgument:&object atIndex:2];
            [self willChangeValueForKey:pm.propertyName];
			
			if (object != nil) {
                [_fieldDictionary setObject:object forKey:pm.propertyName];
            } else {
                [_fieldDictionary removeObjectForKey:pm.propertyName];
            }
            [self didChangeValueForKey:pm.propertyName];
		} else {
			id object = [_fieldDictionary objectForKey:pm.propertyName];
			[anInvocation setReturnValue:&object];
		}
	} else {
		[super forwardInvocation:anInvocation];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	
	NSMethodSignature *ms = [super methodSignatureForSelector:aSelector];
	
	if (!ms) {
		BMPropertyMethod *pm = [BMPropertyMethod propertyMethodFromSelector:aSelector];
		if (pm) {
			if (pm.isSetter) {
				ms = [NSMethodSignature signatureWithObjCTypes:"v^v^c@"];
			} else {
				ms = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
			}
		}
	}
	return ms;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL responds = [super respondsToSelector:aSelector];
	if (!responds) {
		responds = ([BMPropertyMethod propertyMethodFromSelector:aSelector] != nil);
	}
	return responds;
}

@end



