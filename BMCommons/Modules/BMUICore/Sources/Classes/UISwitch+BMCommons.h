//
//  UISwitch+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Methods for getting the labels for the on and off text of a UISwitch.
 */
@interface UISwitch(BMCommons) 

/**
 The label containing the 'off' text for the switch.
 */
- (UILabel *)bmOffLabel;

/**
 The label containing the 'on' text for the switch.
 */
- (UILabel *)bmOnLabel;

@end
