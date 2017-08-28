//
//  BMSwitch.h
//  BMCommons
//
//  Created by Werner Altewischer on 05/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMSwitch : UIControl

@property (nonatomic, assign, getter=isOn) BOOL on;

@property (nullable, nonatomic, readonly) UILabel *offLabel;
@property (nullable, nonatomic, readonly) UILabel *onLabel;

- (id)initWithFrame:(CGRect)frame;              // This class enforces a size appropriate for the control. The frame size is ignored.

- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action

@end

NS_ASSUME_NONNULL_END
