//
//  BMEnumeratedValueCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMUIExtensions/BMEnumeratedValueCell.h>
#import <BMUICore/BMEnumeratedValueToStringTransformer.h>
#import <BMUICore/BMEnumeratedValueTransformer.h>
#import <BMUICore/BMUICore.h>

@implementation BMEnumeratedValueCell

@synthesize possibleValues;

- (void)dealloc {
	BM_RELEASE_SAFELY(possibleValues);
}

- (void)initialize {
	[super initialize];
	self.displayValueTransformer = [BMEnumeratedValueToStringTransformer new];
}

- (void)prepareForReuse {
	[super prepareForReuse];
}

#pragma mark -
#pragma mark Public methods

- (void)setSelectedValueWithData:(id)value {
	self.selectedValue = nil;
	for (BMEnumeratedValue *possibleValue in possibleValues) {
		if (value == possibleValue.value || [value isEqual:possibleValue.value]) {
			self.selectedValue = possibleValue;
		}
	}
}

#pragma mark -
#pragma mark Implementation

- (id)dataFromView {
	return ((BMEnumeratedValue *)self.selectedValue).value;
}

@end
