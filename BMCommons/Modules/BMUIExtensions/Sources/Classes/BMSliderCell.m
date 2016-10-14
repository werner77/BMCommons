//
//  BMSliderCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 03/04/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSliderCell.h>

@implementation BMSliderCell

@synthesize slider;
@synthesize currentValueLabel;

- (void)dealloc {
	self.slider.delegate = nil;
}

- (void)initialize {
    [super initialize];
    self.slider.delegate = self;
}

/**
 * Override the following methods to fill the view from the data
 * and the other way around
 */
- (id)dataFromView {
	return @(self.slider.realValue);
}

- (void)setViewWithData:(id)value {
	NSNumber *n = value;
	self.slider.realValue = [n floatValue];
	self.currentValueLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.slider.realValue)];
}

- (void)sliderValueChanged:(UISlider *)slider {
	[self updateObjectWithCellValue];
	self.currentValueLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.slider.realValue)];
}

@end
