//
//  BMTTBaseNavigationController.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/10/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMTTNavigationController : UINavigationController

- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition;
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;

@end
