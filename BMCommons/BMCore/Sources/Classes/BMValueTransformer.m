//
//  BMValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//
#import "BMValueTransformer.h"


@implementation BMValueTransformer 

@synthesize converterTarget = _converterTarget, converterSelector = _converterSelector, inverseConverterTarget = _inverseConverterTarget, inverseConverterSelector = _inverseConverterSelector;

+ (Class)transformedValueClass {
	return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)initWithConverterTarget:(id)theConverterTarget converterSelector:(SEL)theConverterSelector 
				inverseTarget:(id)theInverseTarget inverseSelector:(SEL)theInverseSelector {
	
	if ((self = [super init])) {
		_converterTarget = theConverterTarget;
		_converterSelector = theConverterSelector;
		_inverseConverterTarget = theInverseTarget;
		_inverseConverterSelector = theInverseSelector;
	}
	return self;
}


- (id)transformedValue:(id)value {
	id transformedValue = value;
	if (self.converterSelector != nil) {
		id ct = self.converterTarget;
		if (!ct) ct = value;
		transformedValue = [ct performSelector:self.converterSelector withObject:value];
	}
	return transformedValue;
}

- (id)reverseTransformedValue:(id)value {
	id transformedValue = value;
	if (self.inverseConverterSelector != nil) {
		id ct = self.inverseConverterTarget;
		if (!ct) ct = value;
		transformedValue = [ct performSelector:self.inverseConverterSelector withObject:value];
	}
	return transformedValue;
}


@end