//
//  UIViewController+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(BMCommons) 

/**
 Returns the inverted transition from the supplied transition (e.g.  UIViewAnimationTransitionFlipFromRight <--> UIViewAnimationTransitionFlipFromLeft)
 */
+ (UIViewAnimationTransition)bmInvertedTransition:(UIViewAnimationTransition)transition;

- (nullable UINavigationController *)bmParentNavigationController;

- (nullable UITabBarController *)bmParentTabController;

- (BOOL)bmIsModal;

/**
 Returns the CGAffineTransform for the current orientation
 */
- (CGAffineTransform)bmTransformForOrientation;

- (void)bmPresentChildViewController:(UIViewController *)vc inView:(nullable UIView *)parentView aboveView:(nullable UIView *)view;
- (void)bmPresentChildViewController:(UIViewController *)vc aboveView:(nullable UIView *)view;
- (void)bmPresentChildViewController:(UIViewController *)vc;
- (void)bmDismissChildViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
