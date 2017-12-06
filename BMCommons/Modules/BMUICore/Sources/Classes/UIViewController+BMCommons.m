//
//  "UIViewController+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 11/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "UIViewController+BMCommons.h"
#import <BMCommons/UIView+BMCommons.h>
#import <BMCommons/BMUICoreObject.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/UIScreen+BMCommons.h>

@implementation UIViewController(BMCommons)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGAffineTransform)bmTransformForOrientation {
    return BMRotateTransformForOrientation(BMInterfaceOrientation());
}

+ (UIViewAnimationTransition)bmInvertedTransition:(UIViewAnimationTransition)transition {
	switch (transition) {
		case UIViewAnimationTransitionCurlUp:
			return UIViewAnimationTransitionCurlDown;
		case UIViewAnimationTransitionCurlDown:
			return UIViewAnimationTransitionCurlUp;
		case UIViewAnimationTransitionFlipFromLeft:
			return UIViewAnimationTransitionFlipFromRight;
		case UIViewAnimationTransitionFlipFromRight:
			return UIViewAnimationTransitionFlipFromLeft;
		default:
			return UIViewAnimationTransitionNone;
	}
}

- (UINavigationController *)bmParentNavigationController {
    UINavigationController *navigationController = self.navigationController;
    UIViewController *vc = self;
    while (!navigationController && vc) {
        vc = vc.parentViewController;
        navigationController = vc.navigationController;
    }
    return navigationController;
}

- (UITabBarController *)bmParentTabController {
    UITabBarController *tabController = self.tabBarController;
    UIViewController *vc = self;
    while (!tabController && vc) {
        vc = vc.parentViewController;
        tabController = vc.tabBarController;
    }
    return tabController;
}

- (BOOL)bmIsModal {
    BOOL isModal = ((self.parentViewController && self.parentViewController.presentedViewController == self) ||
                    //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                    ( self.navigationController && self.navigationController.parentViewController && self.navigationController.parentViewController.presentedViewController == self.navigationController) ||
                    //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    
    //iOS 5+
    if (!isModal && [self respondsToSelector:@selector(presentingViewController)]) {
        
        isModal = ((self.presentingViewController && self.presentingViewController.presentedViewController == self) || 
                   //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                   (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.presentedViewController == self.navigationController) ||
                   //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                   [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]);
        
    }
    return isModal;
}

#pragma mark - Child view controllers

- (void)bmPresentChildViewController:(UIViewController *)vc inView:(UIView *)parentView aboveView:(UIView *)view {
    [self addChildViewController:vc];
    if (vc.view.superview != parentView) {
        [vc.view removeFromSuperview];
        if (view == nil || ![parentView.subviews containsObject:view]) {
            [parentView addSubview:vc.view];
        } else {
            [parentView insertSubview:vc.view aboveSubview:view];
        }
    }
    [vc didMoveToParentViewController:self];
}

- (void)bmPresentChildViewController:(UIViewController *)vc aboveView:(UIView *)view {
    UIView *parentView = vc.view.superview;
    if (parentView == nil) {
        parentView = self.view;
    }
    [self bmPresentChildViewController:vc inView:parentView aboveView:view];
}

- (void)bmPresentChildViewController:(UIViewController *)vc {
    [self bmPresentChildViewController:vc aboveView:nil];
}

- (void)bmDismissChildViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
}

@end

