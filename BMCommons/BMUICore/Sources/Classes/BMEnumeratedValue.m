//
//  BMEnumeratedValue.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMEnumeratedValue.h"
#import "BMStringToIntegerValueTransformer.h"
#import "BMStringToBooleanValueTransformer.h"
#import "BMStringToFloatValueTransformer.h"
#import "BMInputValueType.h"
#import "BMTwoWayDictionary.h"
#import "BMStringHelper.h"
#import <BMCommons/BMUICore.h>

@interface BMEnumeratedValue(Private)

- (NSValueTransformer *)valueTransformer;

@end	

@implementation BMEnumeratedValue {
    id _value;
	NSString *_valueString;
	NSString *_label;
	BMInputValueType *_valueType;
	NSMutableArray *_subValues;
}

@synthesize valueString = _valueString, label = _label, valueType = _valueType;

+ (BMEnumeratedValue *)enumeratedValueWithValue:(id)theValue {
	return [self enumeratedValueWithValue:theValue label:nil];
}

+ (BMEnumeratedValue *)enumeratedValueWithValue:(id)theValue label:(NSString *)theLabel {
	BMEnumeratedValue *v = [[self alloc] init];
	v.value = theValue;
	v.label = theLabel;
	return v;
}

+ (NSArray *)fieldMappingFormatArray {
	return @[@"valueString;value",
						   @"valueTypeString;value@type",
						   @"label"];
}

- (id)init {
	if ((self = [super init])) {
		_subValues = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc {
	self.valueString = nil;
}


- (void)setValueTypeString:(NSString *)typeString {
	self.valueType = [BMInputValueType registeredValueTypeForKey:typeString];
}

- (NSString *)valueTypeString {
	return self.valueType.typeKey;
}

- (void)setValue:(id)theValue {
    if (_value != theValue) {
        _value = theValue;
        BM_RELEASE_SAFELY(_valueString);
    }
}

- (void)setValueString:(NSString *)s {
	if ([s isEqual:@""]) s = nil;
	
	if (s != _valueString) {
        BM_RELEASE_SAFELY(_value);
		_valueString = s;
	}
}

- (id)value {
    id theValue = nil;
    if (_value) {
        theValue = _value;
    } else if (self.valueString) {
        theValue = self.valueString;
        NSValueTransformer *valueTransformer = self.valueType.valueTransformer;
        if (valueTransformer) {
            theValue = [valueTransformer transformedValue:_value];
        }
    }
    return theValue;
}

- (void)setSubValues:(NSArray *)theValues {
	[_subValues removeAllObjects];
	for (BMEnumeratedValue *theValue in theValues) {
		[self addSubValue:theValue];
	}
}

- (NSArray *)subValues {
	return [NSArray arrayWithArray:_subValues];
}

- (void)addSubValue:(BMEnumeratedValue *)subValue {
	[_subValues addObject:subValue];
}

- (NSUInteger)hash {
    return [self.value hash];
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[BMEnumeratedValue class]]) {
        BMEnumeratedValue *other = object;
        
        id theValue = self.value;
        id otherValue = other.value;
        
        ret = (theValue == otherValue || [theValue isEqual:otherValue]);
    }
    return ret;
}


@end

