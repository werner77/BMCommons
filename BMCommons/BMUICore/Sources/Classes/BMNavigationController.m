//
//  BMNavigationController.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMNavigationController.h"
#import "BMViewController.h"
#import <BMCommons/BMUICore.h>

@implementation BMNavigationController {
    BOOL _firstAppearAfterLoad;
    NSMutableDictionary *_transitionDictionary;
    BOOL _styleSheetPushed;
}

- (id)init {
    if ((self = [super init])) {
        BMUICoreCheckLicense();
    }
    return self;
}

- (void)dealloc {
	if (self.isViewLoaded) {
		[self unloadView];
	}
    if (_styleSheetPushed) {
        [BMStyleSheet popStyleSheet];
    }
}

#pragma mark -
#pragma mark UIViewController methods

- (void)loadView {
    if (self.styleSheet && !_styleSheetPushed) {
        [BMStyleSheet pushStyleSheet:self.styleSheet];
        _styleSheetPushed = YES;
    }
    [super loadView];
}

- (void)unloadView {
    [self viewWillUnload];
    self.view = nil;
    [self viewDidUnload];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    if (BMOSVersionIsAtLeast(@"7.0")) {
        BM_START_IGNORE_TOO_NEW
        self.navigationBar.barTintColor = BMSTYLEVAR(navigationBarTintColor);
        self.navigationBar.tintColor = BMSTYLEVAR(navigationBarTextTintColor);
        BM_END_IGNORE_TOO_NEW
    } else {
        self.navigationBar.tintColor = BMSTYLEVAR(navigationBarTintColor);
    }
    self.navigationBar.translucent = BMSTYLEVAR(navigationBarTranslucent);
    self.navigationBar.barStyle = BMSTYLEVAR(navigationBarStyle);
    
	[[BMLocalization sharedInstance] registerLocalizable:self];
	_firstAppearAfterLoad = YES;
	
	[self localize];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (_firstAppearAfterLoad) {
		[self localize];
		_firstAppearAfterLoad = NO;
	}
}

- (void)didReceiveMemoryWarning {
    if (self.shouldUnloadViewAtMemoryWarning && BMOSVersionIsAtLeast(@"6.0")) {
        if ([self isViewLoaded] && !self.view.window) {
            [self unloadView];
        }
    }
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark BMLocalizable implementation

- (void)localize {
	
}

- (UIViewAnimationTransition)popAnimationForViewController:(UIViewController *)vc {
    id key = [self keyForViewController:vc];
    NSNumber *transitionNumber = _transitionDictionary[key];
    UIViewAnimationTransition transition = transitionNumber ? [transitionNumber integerValue] : UIViewAnimationTransitionNone;
    [_transitionDictionary removeObjectForKey:key];
    return transition;
}

- (id)keyForViewController:(UIViewController *)vc {
    return @((NSInteger)vc);
}

- (void)pushAnimation:(UIViewAnimationTransition)transition forViewController:(UIViewController *)vc {
    id key = [self keyForViewController:vc];
    NSNumber *transitionNumber = @(transition);
    
    if (!_transitionDictionary) {
        _transitionDictionary = [NSMutableDictionary new];
    }
    _transitionDictionary[key] = transitionNumber;
}

#pragma mark -
#pragma mark Overridden methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	BMViewController *currentTopViewController = nil;
	if ([self.topViewController isKindOfClass:[BMViewController class]]) {
		currentTopViewController = (BMViewController *)self.topViewController;
	}
	[super pushViewController:viewController animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewAnimationTransition)invertTransition:(UIViewAnimationTransition)transition {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UINavigationController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    UIViewAnimationTransition transition = [self popAnimationForViewController:self.topViewController];
    
    if (transition == UIViewAnimationTransitionNone) {
        return [super popViewControllerAnimated:animated];
    } else {
        return [self popViewControllerAnimatedWithTransition:[self invertTransition:transition]];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *ret = [super popToViewController:viewController animated:animated];
    
    for (UIViewController *vc in ret) {
        [self popAnimationForViewController:vc];
    }
    return ret;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *ret = [super popToRootViewControllerAnimated:animated];
    
    for (UIViewController *vc in ret) {
        [self popAnimationForViewController:vc];
    }
    return ret;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition {
    
    if (controller) {
        [self pushViewController:controller animated:NO];
        [self pushAnimation:transition forViewController:controller];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:BM_FLIP_TRANSITION_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
        [UIView setAnimationTransition:transition forView:self.view cache:YES];
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
    UIViewController* poppedController = [self popViewControllerAnimated:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:BM_FLIP_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:NO];
    [UIView commitAnimations];
    
    return poppedController;
}

@end

@implementation BMNavigationController(Protected)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushAnimationDidStop {
}

- (void)viewWillUnload {
}

- (void)viewDidUnload {
    [[BMLocalization sharedInstance] deregisterLocalizable:self];
}

@end
