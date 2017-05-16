//
//  BMMultiSwitchViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/3/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMultiSwitchViewController.h>
#import "UIViewController+BMCommons.h"
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSCondition+BMCommons.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/UIScreen+BMCommons.h>

@interface BMViewController()

- (void)setViewState:(BMViewState)viewState;

@end

@interface BMMultiSwitchViewController()

@property (nonatomic, strong) NSMutableArray *switchBlocks;
@property (nonatomic, strong) NSCondition *switchCondition;
@property (nonatomic) NSUInteger selectedIndex;

@end

@interface BMMultiSwitchViewController (Private)

+ (UIViewController *)constructViewControllerFromClassName:(NSString *)className;
- (BOOL)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite
              withTransition:(BMSwitchTransitionType)transtion duration:(NSTimeInterval)duration;

- (void)removeChildViewControllerAtIndex:(NSUInteger)index;
- (void)insertChildViewController:(UIViewController *)vc atIndex:(NSUInteger)index;
- (void)removeAllChildViewControllers;

@end


@implementation BMMultiSwitchViewController {
    NSMutableArray *_viewControllers;
    NSUInteger _selectedIndex;
    BOOL _switching;
    UIViewAnimationTransition _currentFlipTransition;
    IBOutlet UIView *_containerView;
}

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@synthesize switching = _switching;
@synthesize containerView = _containerView;

- (id)init {
    return [self initWithViewControllers:@[]];
}

- (void)commonInit {
    [super commonInit];
    _switchBlocks = [NSMutableArray new];
    _viewControllers = [NSMutableArray new];
    _currentFlipTransition = UIViewAnimationTransitionFlipFromLeft;
    self.selectedIndex = NSNotFound;
    self.switchCondition = [NSCondition new];
}

- (id)initWithViewController:(UIViewController *)firstViewController {
    return [self initWithViewControllers:@[firstViewController]];
}

- (id)initWithViewControllers:(NSArray *)theViewControllers {
    return [self initWithViewControllers:theViewControllers selectedIndex:0];
}

- (id)initWithViewControllers:(NSArray *)theViewControllers selectedIndex:(NSUInteger)theSelectedIndex {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        for (UIViewController *vc in theViewControllers) {
            [self insertChildViewController:vc atIndex:_viewControllers.count];
        }
        if (theViewControllers.count > 0) {
            if (theSelectedIndex >= _viewControllers.count) theSelectedIndex = 0;
            self.selectedIndex = theSelectedIndex;
        }
    }
    return self;
}

- (void)dealloc {
    UIViewController *vc = self.selectedViewController;
    [vc.view removeFromSuperview];
    [self removeAllChildViewControllers];
    BM_RELEASE_SAFELY(_viewControllers);
}

- (void)replaceSelectedViewControllerWithViewController:(UIViewController *)viewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self replaceSelectedViewControllerWithViewController:viewController transitionType:transitionType duration:duration completion:nil];
}

- (void)replaceSelectedViewControllerWithViewController:(UIViewController *)viewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration completion:(void (^)(BOOL success))completion {
    BOOL shouldSwitch = (self.selectedIndex == NSNotFound);
    BOOL insertedViewController = [self insertViewController:viewController atIndex:self.selectedIndex overwriteExisting:YES withTransition:transitionType duration:duration];
    //This code is necessary because a switch is not performed by the insert method above if no view controller was selected in the first place
    if (shouldSwitch && insertedViewController) {
        NSUInteger index = self.selectedIndex;
        self.selectedIndex = NSNotFound;
        [self switchToViewControllerAtIndex:index transitionType:transitionType duration:duration completion:completion];
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

- (void)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite {
    [self insertViewController:viewController atIndex:index overwriteExisting:shouldOverwrite withTransition:BMSwitchTransitionTypeNone duration:0.0];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index {
    if (index != self.selectedIndex && index < self.viewControllers.count) {
        UIViewController *selectedViewController = self.selectedViewController;
        [self removeChildViewControllerAtIndex:index];
        self.selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    }
}

- (void)addViewController:(UIViewController *)viewController {
    [self insertViewController:viewController atIndex:self.viewControllers.count overwriteExisting:NO];
}

- (void)removeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index != NSNotFound) {
        [self removeViewControllerAtIndex:index];
    }
}

- (void)removeLastViewController {
    [self removeViewControllerAtIndex:(self.viewControllers.count - 1)];
}

- (UIViewController *)firstViewController {
    NSUInteger count = self.viewControllers.count;
    if (count > 0) {
        return (self.viewControllers)[0];
    } else {
        return nil;
    }
}

- (UIViewController *)lastViewController {
    NSUInteger count = self.viewControllers.count;
    if (count > 0) {
        return (self.viewControllers)[(count - 1)];
    } else {
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.view) {
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bmPortraitBounds]];
    }

    if (!self.containerView) {
        self.containerView = self.view;
    }

    UIView *theView = self.selectedViewController.view;
    theView.frame = self.containerView.bounds;
    theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    if (self.viewState == BMViewStateVisible) {
        [self.selectedViewController beginAppearanceTransition:YES animated:NO];
    }
    [self bmPresentChildViewController:self.selectedViewController inView:self.containerView aboveView:nil];
    if (self.viewState == BMViewStateVisible) {
        [self.selectedViewController endAppearanceTransition];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.selectedViewController endAppearanceTransition];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.selectedViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.selectedViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.selectedViewController endAppearanceTransition];
}

- (void)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration completion:(void (^)(BOOL success))completion {
    NSUInteger theIndex = [self.viewControllers indexOfObjectIdenticalTo:theViewController];
    if (theIndex != NSNotFound) {
        [self switchToViewControllerAtIndex:theIndex transitionType:transitionType duration:duration completion:completion];
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

- (void)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self switchToViewController:theViewController transitionType:transitionType duration:duration completion:nil];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)setSwitching:(BOOL)switching {
    [self.switchCondition bmBroadcastForPredicateModification:^{
        self->_switching = switching;
    }];
}

- (void)setViewState:(BMViewState)viewState {
    [self.switchCondition bmBroadcastForPredicateModification:^{
        [super setViewState:viewState];
    }];
}

- (BOOL)isTransitioning {
    return self.viewState != BMViewStateVisible && self.viewState != BMViewStateInvisible;
}

- (BOOL)isSwitchingAllowed {
    return !self.isSwitching && !self.isTransitioning;
}

- (BOOL)setupSwitchToViewControllerAtIndex:(NSUInteger)index currentViewController:(UIViewController **)vc1 newViewController:(UIViewController **)vc2 transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    if (!self.isSwitchingAllowed) {
        return NO;
    }

    UIViewController *currentViewController = self.selectedViewController;
    UIViewController *otherViewController = index < self.viewControllers.count ? (self.viewControllers)[index] : nil;

    if (currentViewController == otherViewController || !otherViewController) {
        return NO;
    }

    //Will trigger viewDidLoad
    UIView *theView = otherViewController.view;

    if (!theView || !self.containerView) {
        return NO;
    }

    self.switching = YES;

    [self switchWillStartToViewController:otherViewController transitionType:transitionType duration:duration];

    if ([self.delegate respondsToSelector:@selector(multiSwitchViewController:willSwitchFromController:toController:)]) {
        [self.delegate multiSwitchViewController:self willSwitchFromController:currentViewController toController:otherViewController];
    }

    if (transitionType <= BMSwitchTransitionTypeFlip ) {
        theView.frame = self.containerView.bounds;
        [self.containerView setNeedsLayout];
        [self.containerView layoutIfNeeded];
    }

    if (vc1) *vc1 = currentViewController;
    if (vc2) *vc2 = otherViewController;

    return YES;
}

- (void)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self switchToViewControllerAtIndex:index transitionType:transitionType duration:duration completion:nil];
}

- (void)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)theDuration completion:(void (^)(BOOL success))completion {
    __typeof(self) __weak weakSelf = self;

    void (^switchBlock)(void) = ^{
        NSTimeInterval duration = theDuration;
        if (weakSelf.viewState == BMViewStateInvisible) {
            //Force non animated:
            duration = 0.0;
        }

        BOOL animated = duration > 0.0;

        BMSwitchTransitionType effectiveTransitionType = transitionType;

        if (!animated) {
            effectiveTransitionType = BMSwitchTransitionTypeNone;
        }

        UIViewController *currentSelectedViewController = nil;
        UIViewController *newSelectedViewController = nil;
        BOOL canSwitch = [weakSelf setupSwitchToViewControllerAtIndex:index currentViewController:&currentSelectedViewController newViewController:&newSelectedViewController transitionType:effectiveTransitionType duration:duration];
        if (!canSwitch) {
            if (completion) {
                completion(NO);
            }
        } else {
            UIView *theView = [newSelectedViewController view];
            NSMutableArray *vcArray = [[NSMutableArray alloc] init];
            [vcArray addObject:newSelectedViewController];
            if (currentSelectedViewController) {
                [vcArray addObject:currentSelectedViewController];
            }

            if (weakSelf.viewState == BMViewStateVisible) {
                [currentSelectedViewController beginAppearanceTransition:NO animated:animated];
                [newSelectedViewController beginAppearanceTransition:YES animated:animated];
            }

            [weakSelf.containerView addSubview:theView];

            if (effectiveTransitionType == BMSwitchTransitionTypeCrossFade && animated) {
                currentSelectedViewController.view.alpha = 1.0f;
                theView.alpha = 0.0f;
                [UIView animateWithDuration:duration animations:^{
                    theView.alpha = 1.0f;
                    currentSelectedViewController.view.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    currentSelectedViewController.view.alpha = 1.0f;
                    [weakSelf animationDidStop:finished context:vcArray completion:completion];
                }];
            } else if (effectiveTransitionType == BMSwitchTransitionTypeFlip) {
                UIViewAnimationOptions options;
                if (_currentFlipTransition == UIViewAnimationTransitionFlipFromLeft) {
                    options = UIViewAnimationOptionTransitionFlipFromLeft;
                } else {
                    options = UIViewAnimationOptionTransitionFlipFromRight;
                }
                [UIView transitionWithView:weakSelf.containerView duration:duration options:options animations:^{
                    [currentSelectedViewController.view removeFromSuperview];
                }               completion:^(BOOL finished) {
                    [weakSelf animationDidStop:finished context:vcArray completion:completion];
                }];
                _currentFlipTransition = (_currentFlipTransition == UIViewAnimationTransitionFlipFromLeft) ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft;
            } else if (effectiveTransitionType == BMSwitchTransitionTypeNone || !self.customTransitionAnimationBlock) {
                [weakSelf finishTransition:vcArray completion:completion];
            } else {
                weakSelf.customTransitionAnimationBlock(currentSelectedViewController, newSelectedViewController, weakSelf.containerView, effectiveTransitionType, duration, ^(BOOL finished) {
                    [weakSelf animationDidStop:finished context:vcArray completion:completion];
                });
            }
        }
    };

    BOOL waiting = [self waitUntilSwitchIsAllowedWithCompletion:^(BOOL waited) {
        if (waited) {
            [weakSelf dequeueSwitchBlock];
        } else {
            [weakSelf queueSwitchBlock:switchBlock];
            [weakSelf dequeueSwitchBlock];
        }
    }];
    if (waiting) {
        [self queueSwitchBlock:switchBlock];
    }
}

- (void)queueSwitchBlock:(void (^)(void))block {
    [_switchBlocks addObject:[block copy]];
}

- (void)dequeueSwitchBlock {
    void (^block)(void) = [_switchBlocks firstObject];
    if (block != nil) {
        [_switchBlocks removeObjectAtIndex:0];
        block();
        if (_switchBlocks.count > 0) {
            __typeof(self) __weak weakSelf = self;
            [self waitUntilSwitchIsAllowedWithCompletion:^(BOOL waited) {
                [weakSelf dequeueSwitchBlock];
            }];
        }
    }
}

- (void)switchToFirstViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self switchToViewControllerAtIndex:0 transitionType:transitionType duration:duration];
}

- (void)switchToLastViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self switchToViewControllerAtIndex:(self.viewControllers.count - 1) transitionType:transitionType duration:duration];
}

- (UIViewController *)selectedViewController {
    if (_selectedIndex < _viewControllers.count) {
        return _viewControllers[_selectedIndex];
    } else {
        return nil;
    }
}

- (UIViewController	*)firstViewControllerOfKind:(Class)viewControllerClass {
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:viewControllerClass]) {
            return viewController;
        }
    }
    return nil;
}

- (void)animationDidStop:(BOOL)finished context:(NSArray *)vcs completion:(void (^)(BOOL success))completion {
    UIViewController *currentSelectedViewController = vcs.count == 2 ? vcs[1] : nil;
    UIViewController *newSelectedViewController = vcs[0];

    if (currentSelectedViewController.view.superview) {
        [currentSelectedViewController.view removeFromSuperview];
    }

    if (self.viewState == BMViewStateVisible) {
        [currentSelectedViewController endAppearanceTransition];
    }

    self.selectedIndex = [self.viewControllers indexOfObject:newSelectedViewController];

    if (self.viewState == BMViewStateVisible) {
        [newSelectedViewController endAppearanceTransition];
    }

    self.switching = NO;

    [self switchDidFinishFromViewController:currentSelectedViewController];

    if ([self.delegate respondsToSelector:@selector(multiSwitchViewController:didSwitchFromController:toController:)]) {
        [self.delegate multiSwitchViewController:self didSwitchFromController:currentSelectedViewController toController:newSelectedViewController];
    }

    if (completion) {
        completion(YES);
    }
}

- (void)switchWillStartToViewController:(UIViewController *)newViewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration {
    [self switchWillStart];
}

- (void)switchDidFinishFromViewController:(UIViewController *)oldViewController {
    [self switchDidFinish];
}


- (void)switchWillStart {
}

- (void)switchDidFinish {
}

- (void)finishTransition:(NSArray *)vcs completion:(void (^)(BOOL))completion {
    [self animationDidStop:YES context:vcs completion:completion];
}

- (void)waitForSwitchToFinishWithCompletion:(void (^)(void))completion {
    __typeof(self) __weak weakSelf = self;
    [self.switchCondition bmWaitForPredicate:^BOOL {
        return !weakSelf.isSwitching;
    } completion:^(BOOL waited) {
        if (completion) {
            completion();
        }
    }];
}

- (BOOL)waitUntilSwitchIsAllowedWithCompletion:(void (^)(BOOL waited))completion {
    __typeof(self) __weak weakSelf = self;
    return [self.switchCondition bmWaitForPredicate:^BOOL {
        return weakSelf.isSwitchingAllowed;
    } completion:^(BOOL waited) {
        if (completion) {
            completion(waited);
        }
    }];
}

@end

@implementation BMMultiSwitchViewController (Private)

+ (UIViewController *)constructViewControllerFromClassName:(NSString *)className {
    UIViewController *vc = nil;
    if (![BMStringHelper isEmpty:className]) {
        Class c = NSClassFromString(className);
        vc = [c alloc];
        vc = [vc init];
    }
    return vc;
}

- (BOOL)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite
              withTransition:(BMSwitchTransitionType)transition duration:(NSTimeInterval)duration
{
    if (!viewController) {
        return NO;
    }

    if ([self.viewControllers bmContainsObjectIdenticalTo:viewController]) {
        return NO;
    }

    if (index > self.viewControllers.count) {
        index = self.viewControllers.count;
    }

    UIViewController *currentIndexOccupant = nil;

    if (self.viewControllers.count > index) {
        currentIndexOccupant = (self.viewControllers)[index];
    }

    UIViewController *selectedViewController = self.selectedViewController;
    if (selectedViewController == nil) {
        //No selected view controller yet: ensure we switch to the selected one
        selectedViewController = viewController;
    }

    [self insertChildViewController:viewController atIndex:index];
    self.selectedIndex = [_viewControllers indexOfObject:selectedViewController];

    BOOL ret = YES;
    if (currentIndexOccupant != nil && shouldOverwrite) {
        if (currentIndexOccupant == selectedViewController) {
            //Replacing the selectedViewController
            typeof(self) __weak weakSelf = self;
            [self switchToViewControllerAtIndex:index transitionType:transition duration:duration completion:^(BOOL success) {
                if (success) {
                    NSUInteger indexToRemove = [weakSelf.viewControllers indexOfObjectIdenticalTo:currentIndexOccupant];
                    [weakSelf removeChildViewControllerAtIndex:indexToRemove];
                } else {
                    NSUInteger indexToRemove = [weakSelf.viewControllers indexOfObjectIdenticalTo:viewController];
                    [weakSelf removeChildViewControllerAtIndex:indexToRemove];
                    weakSelf.selectedIndex = [weakSelf.viewControllers indexOfObjectIdenticalTo:currentIndexOccupant];
                }
            }];
            self.selectedIndex = NSNotFound;
        } else {
            NSUInteger indexToRemove = [_viewControllers indexOfObjectIdenticalTo:currentIndexOccupant];
            [self removeChildViewControllerAtIndex:indexToRemove];
            self.selectedIndex = [_viewControllers indexOfObject:selectedViewController];
        }
    }
    return ret;
}

#pragma mark - Child view controller methods

- (void)removeChildViewControllerAtIndex:(NSUInteger)index {
    if (index < _viewControllers.count) {
        UIViewController *existingViewController = [_viewControllers bmPopObjectAtIndex:index];
        [existingViewController willMoveToParentViewController:nil];
        [existingViewController removeFromParentViewController];
    }
}

- (void)insertChildViewController:(UIViewController *)vc atIndex:(NSUInteger)index {
    index = MIN(index, _viewControllers.count);
    if (vc != nil) {
        [self addChildViewController:vc];
        [_viewControllers insertObject:vc atIndex:index];
        [vc didMoveToParentViewController:self];
    }
}

- (void)removeAllChildViewControllers {
    while (_viewControllers.count > 0) {
        [self removeChildViewControllerAtIndex:0];
    }
}


@end
