//
//  BMBarButtonItem.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Custom UIBarButtonItem which has the capability to display both an image and a title simultaneously.
 */
@interface BMBarButtonItem : UIBarButtonItem 

/**
 Returns the frame of the specified item relative to the specified view.
 
 Will only work if the view is a superview of the UIToolbar or UINavigationbar in which the item is present.
 */
+ (CGRect)frameOfItem:(UIBarButtonItem *)item inView:(UIView *)v;

/**
 Creates a bar button item with the specified image, title, target and action.
 */
+ (BMBarButtonItem *) barButtonItemWithImage:(nullable UIImage *)image title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;

- (id)initWithImage:(nullable UIImage *)image title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
- (id)initWithImage:(nullable UIImage *)image backgroundImage:(nullable UIImage *)bgImage highlightedBackgroundImage:(nullable UIImage *)highlightedBgImage title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
- (id)initWithTitle:(nullable NSString *)title backgroundImage:(nullable UIImage *)bgImage highlightedBackgroundImage:(nullable UIImage *)highlightedBgImage target:(nullable id)target action:(nullable SEL)action;
- (id)initWithTitle:(nullable NSString *)title backgroundImage:(nullable UIImage *)bgImage target:(nullable id)target action:(nullable SEL)action;
- (id)initWithImage:(nullable UIImage *)image backgroundImage:(nullable UIImage *)bgImage title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;

/**
 The underlying button used by this bar button item.
 */
- (nullable UIButton *)button;

/**
 Sets the title for the bar button item.
 */
- (void)setTitle:(nullable NSString *)title;

/**
 Sets the orientation, to adjust the layout for different height.
 */
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
