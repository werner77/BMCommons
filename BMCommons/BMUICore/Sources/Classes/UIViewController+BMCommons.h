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

@interface UIViewController(BMCommons) 

/**
 Returns the inverted transition from the supplied transition (e.g.  UIViewAnimationTransitionFlipFromRight <--> UIViewAnimationTransitionFlipFromLeft)
 */
+ (UIViewAnimationTransition)bmInvertedTransition:(UIViewAnimationTransition)transition;

- (UINavigationController *)bmParentNavigationController;

- (UITabBarController *)bmParentTabController;

- (BOOL)bmIsModal;

/**
 Returns the CGAffineTransform for the current orientation
 */
- (CGAffineTransform)bmTransformForOrientation;

- (void)bmPresentChildViewController:(UIViewController *)vc inView:(UIView *)parentView aboveView:(UIView *)view;
- (void)bmPresentChildViewController:(UIViewController *)vc aboveView:(UIView *)view;
- (void)bmPresentChildViewController:(UIViewController *)vc;
- (void)bmDismissChildViewController:(UIViewController *)vc;

@end
