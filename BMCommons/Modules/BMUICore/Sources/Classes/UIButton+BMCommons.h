//
//  UIButton+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/7/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BMButtonTargetBlock)(UIButton *button);

@interface UIButton(BMCommons)

/**
 * Sets the specified block as target for the touch up inside event.
 */
- (void)bmSetTargetBlock:(nullable BMButtonTargetBlock)block;

/**
 Convenience method to receive touch up inside events.
 */
- (void)bmSetTarget:(nullable id)target action:(nullable SEL)action;

/**
 Utility method to construct a button for use in a barbutton item on a toolbar/navigation bar.
 */
+ (UIButton *)bmButtonForBarButtonItemWithTarget:(nullable id)target action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
