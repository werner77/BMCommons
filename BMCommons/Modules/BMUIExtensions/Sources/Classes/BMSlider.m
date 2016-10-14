//
//  BMSlider.m
//  BMCommons
//
//  Created by Werner Altewischer on 17/11/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSlider.h>

@interface BMSlider(Private)

- (NSNumber *)snappedValueForValue:(float)value;
- (void)sliderValueChanged:(id)sender;
- (float)translateValue:(float)value;
- (float)inverseTranslateValue:(float)value;

@end

@implementation BMSlider

@synthesize scale = _scale, discreteValues = _discreteValues, delegate;

- (id)init {
	if (self = [super init]) {
		_scale = BMSliderScaleLinear;
		[self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
		_scale = BMSliderScaleLinear;
		[self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return self;
}


- (float)realValue {
	return [self inverseTranslateValue:self.value];
}

- (void)setRealValue:(float)value animated:(BOOL)animated {
	value = [self translateValue:value];
	NSNumber *snappedValue = [self snappedValueForValue:value];
	if (snappedValue) {
		value = [self translateValue:[snappedValue floatValue]];
	}
	[self setValue:value animated:animated];
}

- (void)setRealValue:(float)value {
	[self setRealValue:value animated:NO];
}

- (void)setRealMaximumValue:(float)value {
	[self setMaximumValue:[self translateValue:value]];
}

- (void)setRealMinimumValue:(float)value {
	[self setMinimumValue:[self translateValue:value]];
}

- (float)realMinimumValue {
	return [self inverseTranslateValue:self.minimumValue];
}

- (float)realMaximumValue {
	return [self inverseTranslateValue:self.maximumValue];
}

- (void)setScale:(BMSliderScale)scale {
	float value = self.realValue;
	float maxValue = self.realMaximumValue;
	float minValue = self.realMinimumValue;
		
	_scale = scale;
		
	//Correct the already present values
	self.realMinimumValue = minValue;
	self.realMaximumValue = maxValue;
	self.realValue = value;
}

- (void)setDiscreteValues:(NSArray *)discreteValues {
	if (discreteValues != _discreteValues) {
		_discreteValues = discreteValues;
	}
	self.scale = _scale;
}

@end


@implementation BMSlider(Private)

- (NSNumber *)snappedValueForValue:(float)value {
	NSNumber *theValue = nil;
	CGFloat minDiff = 0;
	for (NSNumber *discreteValue in self.discreteValues) {
		CGFloat translatedValue = [self translateValue:[discreteValue floatValue]];
		CGFloat diff = ABS(value - translatedValue);
		if (!theValue || diff < minDiff) {
			theValue = discreteValue;
			minDiff = diff;
		}
	}
	return theValue;
}

- (void)sliderValueChanged:(id)sender {
	NSNumber *snappedValue = [self snappedValueForValue:self.value];
	if (snappedValue) {
		float theValue = [self translateValue:[snappedValue floatValue]];
		[self setValue:theValue animated:NO];
	}
	[self.delegate sliderValueChanged:self];
}


- (float)translateValue:(float)value {
	float translatedValue = value;
	if (_scale == BMSliderScaleLogarithmic) {
		translatedValue = log(value);
	} else if (_scale == BMSliderScaleEvenlySpaced) {
		int theIndex = -1;
		CGFloat minDiff = 0;
		for (int i = 0; i < self.discreteValues.count; ++i) {
			NSNumber *discreteValue = (self.discreteValues)[i];
			CGFloat diff = ABS(value - [discreteValue floatValue]);
			if (theIndex < 0 || diff < minDiff) {
				minDiff = diff;
				theIndex = i;
			}
		}
		if (theIndex >= 0) {
			translatedValue = theIndex;
		}
	}
	return translatedValue;
}

- (float)inverseTranslateValue:(float)value {
	float translatedValue = value;
	if (_scale == BMSliderScaleLogarithmic) {
		translatedValue = exp(value);
	} else if (_scale == BMSliderScaleEvenlySpaced) {
		int index = (int)value;
		if (index >= 0 && index < self.discreteValues.count) {
			NSNumber *snappedValue = (self.discreteValues)[index];
			if (snappedValue) {
				translatedValue = [snappedValue floatValue];
			}
		}
	}
	return translatedValue;
}

@end
