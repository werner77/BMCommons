//
//  UISwitch+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Methods for getting the labels for the on and off text of a UISwitch.
 */
@interface UISwitch(BMCommons) 

/**
 The label containing the 'off' text for the switch.
 */
- (nullable UILabel *)bmOffLabel;

/**
 The label containing the 'on' text for the switch.
 */
- (nullable UILabel *)bmOnLabel;

@end

NS_ASSUME_NONNULL_END