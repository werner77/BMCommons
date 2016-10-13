//
//  UIButton+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/7/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BMButtonTargetBlock)(UIButton *button);

@interface UIButton(BMCommons)

/**
 * Sets the specified block as target for the touch up inside event.
 */
- (void)bmSetTargetBlock:(BMButtonTargetBlock)block;

/**
 Convenience method to receive touch up inside events.
 */
- (void)bmSetTarget:(id)target action:(SEL)action;

/**
 Utility method to construct a button for use in a barbutton item on a toolbar/navigation bar.
 */
+ (UIButton *)bmButtonForBarButtonItemWithTarget:(id)target action:(SEL)action;

@end
