//
//  BMLabelCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMLabelCell.h>
#import <BMCommons/BMCore.h>

@implementation BMLabelCell {
	IBOutlet UILabel *valueLabel;
	NSString *valueFormat;

	id valueFormatterTarget;
	SEL valueFormatterSelector;
}

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
			BM_IGNORE_SELECTOR_LEAK_WARNING(
			value = [self.valueFormatterTarget performSelector:self.valueFormatterSelector withObject:value];
			)
		} else {
			BM_IGNORE_SELECTOR_LEAK_WARNING(
			value = [value performSelector:self.valueFormatterSelector];
			)
		}
	}
	if (!value || [value isKindOfClass:[NSString class]]) {
		self.valueLabel.text = value;
	} else {
		self.valueLabel.text = [value description];
	}
}

@end
