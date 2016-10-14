//
//  UIApplication+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 3/26/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (BMCommons)

/**
 Returns the root viewcontroller of the application which is the root view controller of the current key window.
 
 In case transcendModals == YES the topmost modal viewcoontroller is returned in the case the root view controller has presented modal view controllers.
 */
- (UIViewController *)bmRootViewController:(BOOL)transcendModals;

/**
 Presents the specified view controller from the view controller returned by calling [UIApplication rootViewController:YES]
 */
- (void)bmPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

/**
 Calls dissmissViewControllerAnimated:completion: on the view controller returned by [UIApplication rootViewController:YES]
 */
- (void)bmDismissViewControllerAnimated:(BOOL)flag completion: (void (^)(void))completion;


@end
