//
//  BMLabelCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMLabelCell.h"

@implementation BMLabelCell

@synthesize valueLabel, valueFormat, valueFormatterTarget, valueFormatterSelector;


- (id)dataFromView {
	return self.valueLabel.text;
}

- (void)initialize {
	[super initialize];
}

- (void)setViewWithData:(id)value {
	if (self.valueFormat) {
		value = [NSString stringWithFormat:self.valueFormat, value];
	} else if (self.valueFormatterSelector) {
		if (self.valueFormatterTarget) {
			value = [self.valueFormatterTarget performSelector:self.valueFormatterSelector withObject:value];
		} else {
			value = [value performSelector:self.valueFormatterSelector];
		}
	}
	if (!value || [value isKindOfClass:[NSString class]]) {
		self.valueLabel.text = value;
	} else {
		self.valueLabel.text = [value description];
	}
}

@end
