//
//  UIApplication+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/26/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "UIApplication+BMCommons.h"

@implementation UIApplication (BMCommons)

- (UIViewController *)bmRootViewController:(BOOL)transcendModals {
    UIViewController *viewController = self.keyWindow.rootViewController;
    if (transcendModals) {
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
    }
    return viewController;
}

- (void)bmPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [[self bmRootViewController:YES] presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)bmDismissViewControllerAnimated:(BOOL)flag completion: (void (^)(void))completion {
    [[self bmRootViewController:YES] dismissViewControllerAnimated:flag completion:completion];
}

@end
