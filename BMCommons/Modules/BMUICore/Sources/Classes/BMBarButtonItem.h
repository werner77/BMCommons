//
//  BMBarButtonItem.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

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
+ (BMBarButtonItem *) barButtonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action;

- (id)initWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image backgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)highlightedBgImage title:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)highlightedBgImage target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)bgImage target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image backgroundImage:(UIImage *)bgImage title:(NSString *)title target:(id)target action:(SEL)action;

/**
 The underlying button used by this bar button item.
 */
- (UIButton *)button;

/**
 Sets the title for the bar button item.
 */
- (void)setTitle:(NSString *)title;

/**
 Sets the orientation, to adjust the layout for different height.
 */
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (UIInterfaceOrientation)orientation;

@end
