//
//  BMSwitchCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMSwitchCell.h"


@implementation BMSwitchCell

@synthesize valueSwitch;

+ (Class)supportedValueClass {
	return [NSNumber class];
}

- (void)initialize {
	[valueSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
	[valueSwitch removeTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (id)dataFromView {
	return @(self.valueSwitch.on);
}

- (void)setViewWithData:(id)value {
	self.valueSwitch.on = [value boolValue];
}

- (void)switchValueChanged:(UISwitch *)theSwitch {
	[self updateObjectWithCellValue];
}

@end
