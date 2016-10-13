//
//  BMSwitch.h
//  BMCommons
//
//  Created by Werner Altewischer on 05/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMSwitch : UIControl 
{
	BOOL _on;
	
	UILabel *_offLabel;
	UILabel *_onLabel;

	NSInteger _hitCount;
	UIImageView* _backgroundImage;
	UIImageView* _switchImage;
}

@property (nonatomic, assign, getter=isOn) BOOL on;

@property (nonatomic, readonly) UILabel *offLabel;
@property (nonatomic, readonly) UILabel *onLabel;

- (id)initWithFrame:(CGRect)frame;              // This class enforces a size appropriate for the control. The frame size is ignored.

- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action

@end
