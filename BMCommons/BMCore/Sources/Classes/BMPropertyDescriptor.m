//
//  BMPropertyDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 09/11/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMPropertyDescriptor.h"
#import <BMCore/NSObject+BMCommons.h>
#import <BMCore/BMStringHelper.h>

@interface BMPropertyDescriptor()

- (void)setPropertyName:(NSString *)theName;

@end


@implementation BMPropertyDescriptor

@synthesize keyPath = _keyPath, target = _target;
@synthesize getters = _getters;
@synthesize setter = _setter;
@synthesize propertyName = _propertyName;
@synthesize valueTransformer = _valueTransformer;

//Private
- (void)setGetters:(NSArray *)theGetters {
	if (_getters != theGetters) {
		_getters = theGetters;
	}
}

- (void)setSetter:(NSString *)theSetter {
	if (_setter != theSetter) {
		_setter = theSetter;
	}
}

- (id)init {
    if ((self = [super init])) {
        self.valueType = BMValueTypeObject;
    }
    return self;
}

- (id)initWithKeyPath:(NSString *)theKeyPath target:(id)theTarget {
    return [self initWithKeyPath:theKeyPath target:theTarget valueType:BMValueTypeObject];
}

- (id)initWithKeyPath:(NSString *)theKeyPath target:(id)theTarget valueType:(BMValueType)valueType {
    if ((self = [self init])) {
        self.keyPath = theKeyPath;
        self.target = theTarget;
        self.valueType = valueType;
    }
    return self;
}

- (void)dealloc {
	self.keyPath = nil;
}

- (id)callGetter {
	return [self callGetterOnTarget:_target];
}

- (void)callSetter:(id)value {
	[self callSetterOnTarget:_target withValue:value];
}

- (id)callGetterOnTarget:(id)t {
	return [self callGetterOnTarget:t ignoreFailure:NO];
}

- (void)callSetterOnTarget:(id)t withValue:(id)value {
	[self callSetterOnTarget:t withValue:value ignoreFailure:NO];
}

- (id)callGetterWithIgnoreFailure:(BOOL)ignoreFailure {
	return [self callGetterOnTarget:self.target ignoreFailure:ignoreFailure];
}
- (void)callSetter:(id)value ignoreFailure:(BOOL)ignoreFailure {
	[self callSetterOnTarget:self.target withValue:value ignoreFailure:ignoreFailure];
}

- (void *)invokeGetterWithValueLength:(NSUInteger *)valueLength {
    return [self invokeGetterOnTarget:_target valueLength:valueLength];
}

- (void)invokeSetter:(void *)value valueLength:(NSUInteger)valueLength {
    [self invokeSetterOnTarget:_target withValue:value valueLength:valueLength];
}

- (void *)invokeGetterOnTarget:(id)t valueLength:(NSUInteger *)valueLength {
    return [self invokeGetterOnTarget:t ignoreFailure:NO valueLength:valueLength];
}

- (void)invokeSetterOnTarget:(id)t withValue:(void *)value valueLength:(NSUInteger)valueLength {
    [self invokeSetterOnTarget:t withValue:value valueLength:valueLength ignoreFailure:NO];
}

- (void *)invokeGetterWithIgnoreFailure:(BOOL)ignoreFailure valueLength:(NSUInteger *)valueLength {
    return [self invokeGetterOnTarget:self.target ignoreFailure:ignoreFailure valueLength:valueLength];
}

- (void)invokeSetter:(void *)value valueLength:(NSUInteger)valueLength ignoreFailure:(BOOL)ignoreFailure {
    [self invokeSetterOnTarget:self.target withValue:value valueLength:valueLength ignoreFailure:ignoreFailure];
}

/**
 Calls the setter on a specified target, optionally ignoring a failure if the property could not be written
 */
- (void)invokeSetterOnTarget:(id)t withValue:(void *)value valueLength:(NSUInteger)valueLength ignoreFailure:(BOOL)ignoreFailure {
    if (self.getters.count > 0) {
        for (int i = 0; i < (self.getters.count - 1); ++i) {
            if (t == nil) {
                break;
            }
            NSString *ivar = [self.getters objectAtIndex:i];
            SEL getterSelector = NSSelectorFromString(ivar);
            
            if (!ignoreFailure || [t respondsToSelector:getterSelector]) {
                t = [t performSelector:getterSelector];
            } else {
                t = nil;
                break;
            }
        }
    }
    if (t != nil) {
        SEL setterSelector = NSSelectorFromString(_setter);
        if (!ignoreFailure || [t respondsToSelector:setterSelector]) {
            if (ignoreFailure) {
                [t bmSafeInvokeSelector:setterSelector withArg:value argSize:valueLength returnLength:NULL];
            } else {
                [t bmInvokeSelector:setterSelector withArg:value argSize:valueLength returnLength:NULL];
            }
        }
    }
}

/**
 Calls the getter on a specified target, optionally ignoring a failure if the property could not be read
 */
- (void *)invokeGetterOnTarget:(id)t ignoreFailure:(BOOL)ignoreFailure valueLength:(NSUInteger *)valueLength {
    NSUInteger i = 1;
    void *ret = NULL;
    for (NSString *ivar in self.getters) {
        BOOL last = (i == self.getters.count);
        if (t == nil) {
            break;
        }
        SEL getter = NSSelectorFromString(ivar);
        if (last && self.valueType == BMValueTypeBoolean && ![t respondsToSelector:getter]) {
            getter = NSSelectorFromString([NSString stringWithFormat:@"is%@", [BMStringHelper stringByConvertingFirstCharToUppercase:ivar]]);
        }
        if (!ignoreFailure || [t respondsToSelector:getter]) {
            
            if (last) {
                ret = [t bmInvokeSelector:getter returnLength:valueLength];
            } else {
                t = [t performSelector:getter];
            }
        } else {
            t = nil;
            break;
        }
        i++;
    }
    return ret;
}

/**
 Calls the getter on a specified target, optionally ignoring a failure if the property could not be read
 */
- (id)callGetterOnTarget:(id)t ignoreFailure:(BOOL)ignoreFailure {
	for (NSString *ivar in self.getters) {
		if (t == nil) {
			break;
		}
		SEL getter = NSSelectorFromString(ivar);
		if (!ignoreFailure || [t respondsToSelector:getter]) {
			t = [t performSelector:getter];
		} else {
			t = nil;
			break;
		}
	}
	if (self.valueTransformer && t) {
		//Convert the value first if a value transformer was set
		t = [self.valueTransformer reverseTransformedValue:t];
	}
	return t;
}

/**
 Calls the setter on a specified target, optionally ignoring a failure if the property could not be written
 */
- (void)callSetterOnTarget:(id)t withValue:(id)value ignoreFailure:(BOOL)ignoreFailure {
	if (self.getters.count > 0) {
		for (int i = 0; i < (self.getters.count - 1); ++i) {
			if (t == nil) {
				break;
			}
			NSString *ivar = [self.getters objectAtIndex:i];
			SEL getterSelector = NSSelectorFromString(ivar);
			
			if (!ignoreFailure || [t respondsToSelector:getterSelector]) {
				t = [t performSelector:getterSelector];
			} else {
				t = nil;
				break;
			}
		}
	}
	if (t != nil) {
		SEL setterSelector = NSSelectorFromString(_setter);
		if (!ignoreFailure || [t respondsToSelector:setterSelector]) {
			if (self.valueTransformer && value) {
				//Convert the value first if a value transformer was set
				value = [self.valueTransformer transformedValue:value];
			}
			[t performSelector:setterSelector withObject:value];
		}
	}
}

- (void)setKeyPath:(NSString *)theKeyPath {
	if (_keyPath != theKeyPath) {
		_keyPath = theKeyPath;
		
		if (_keyPath) {
            NSArray *components = [_keyPath componentsSeparatedByString:@"."];
            NSMutableArray *theGetters = [NSMutableArray arrayWithCapacity:components.count];
            for (NSString *ivar in components) {
                [theGetters addObject:ivar];
            }
            
            NSString *setterSelector = nil;
            if (components.count > 0) {
                NSString *ivar = [components objectAtIndex:(components.count - 1)];
                
                if (ivar.length > 0) {
                    NSString *firstCharUpperCase = [[ivar substringToIndex:1] capitalizedString];
                    NSString *remainingPart = [ivar substringFromIndex:1];
                    
                    setterSelector = [NSString stringWithFormat:@"set%@%@:", firstCharUpperCase, remainingPart];
                }
                
                self.propertyName = ivar;
            }
            
            self.getters = theGetters.count == 0 ? nil : theGetters;
            self.setter = setterSelector;
        } else {
            self.getters = nil;
            self.setter = nil;
        }
    }
}

- (BOOL)validateValue:(id *)value withError:(NSError **)error {
	return [self validateValue:value onTarget:self.target withError:error];
}

- (BOOL)validateValue:(id *)value onTarget:(id)t withError:(NSError **)error {
	if (self.getters.count > 0) {
		for (int i = 0; i < (self.getters.count - 1); ++i) {
			NSString *ivar = [self.getters objectAtIndex:i];
			SEL getterSelector = NSSelectorFromString(ivar);
			t = [t performSelector:getterSelector];
		}
	}
	return t == nil || [t validateValue:value forKey:self.propertyName error:error];
}

- (BMPropertyDescriptor *)parentDescriptor {
	BMPropertyDescriptor *pd = nil;
	if (self.getters.count > 1) {
		NSMutableString *theKeyPath = [NSMutableString string];
		for (int i = 0; i < self.getters.count - 1; ++i) {
			NSString *getter = [self.getters objectAtIndex:i];
			if (i > 0) {
				[theKeyPath appendString:@"."];
			}
			[theKeyPath appendString:getter];
		}
		pd = [[self class] propertyDescriptorFromKeyPath:theKeyPath withTarget:self.target];
	} 
	return pd;
}

+ (BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath {
    return [self propertyDescriptorFromKeyPath:theKeyPath withTarget:nil];
}

+ (BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType {
    return [self propertyDescriptorFromKeyPath:theKeyPath withTarget:nil valueType:valueType];
}

+ (BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath withTarget:(NSObject *)theTarget {
    return [self propertyDescriptorFromKeyPath:theKeyPath withTarget:theTarget valueType:BMValueTypeObject];
}

+ (BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath withTarget:(NSObject *)theTarget valueType:(BMValueType)valueType {
    BMPropertyDescriptor *pd = [[self alloc] initWithKeyPath:theKeyPath target:theTarget valueType:valueType];
    return pd;
}


- (void)setPropertyName:(NSString *)theName {
	if (_propertyName != theName) {
		_propertyName = theName;
	}
}

@end
