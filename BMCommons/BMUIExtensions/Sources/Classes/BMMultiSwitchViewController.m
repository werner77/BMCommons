//
//  BMMultiSwitchViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/3/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMMultiSwitchViewController.h"
#import "UIViewController+BMCommons.h"
#import "BMStringHelper.h"
#import <BMCore/NSObject+BMCommons.h>
#import <BMCore/NSCondition+BMCommons.h>
#import <BMUICore/BMUICore.h>
#import <BMUICore/UIScreen+BMCommons.h>

@interface BMMultiSwitchViewController()

@property (nonatomic, strong) NSCondition *switchCondition;


@end

@interface BMMultiSwitchViewController (Private)

+ (UIViewController *)constructViewControllerFromClassName:(NSString *)className;
- (BOOL)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite
              withTransition:(BMSwitchTransitionType)transtion duration:(CGFloat)duration;

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

- (id)initWithCoder:(NSCoder*)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _viewControllers = [NSMutableArray new];
        _currentFlipTransition = UIViewAnimationTransitionFlipFromLeft;
        _selectedIndex = NSNotFound;
        self.switchCondition = [NSCondition new];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _viewControllers = [NSMutableArray new];
        _currentFlipTransition = UIViewAnimationTransitionFlipFromLeft;
        _selectedIndex = NSNotFound;
        self.switchCondition = [NSCondition new];
    }
    return self;
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
            _selectedIndex = theSelectedIndex;
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

- (BOOL)replaceSelectedViewControllerWithViewController:(UIViewController *)viewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    BOOL shouldSwitch = (_selectedIndex == NSNotFound);
    BOOL ret = [self insertViewController:viewController atIndex:_selectedIndex overwriteExisting:YES withTransition:transitionType duration:duration];
    //This code is necessary because a switch is not performed by the insert method above if no view controller was selected in the first place
    if (shouldSwitch) {
        NSUInteger index = _selectedIndex;
        _selectedIndex = NSNotFound;
        [self switchToViewControllerAtIndex:index transitionType:transitionType duration:duration];
    }
    return ret;
}

- (void)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite {
    [self insertViewController:viewController atIndex:index overwriteExisting:shouldOverwrite withTransition:BMSwitchTransitionTypeNone duration:0.0];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index {
    if (index != _selectedIndex && index < self.viewControllers.count) {
        UIViewController *selectedViewController = self.selectedViewController;
        [self removeChildViewControllerAtIndex:index];
        _selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
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

- (BOOL)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration completion:(void (^)(void))completion {
    BOOL ret = [self switchToViewController:theViewController transitionType:transitionType duration:duration];
    [self waitForSwitchToFinishWithCompletion:completion];
    return ret;
}

- (BOOL)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    NSUInteger theIndex = [self.viewControllers indexOfObjectIdenticalTo:theViewController];
    if (theIndex != NSNotFound) {
        return [self switchToViewControllerAtIndex:theIndex transitionType:transitionType duration:duration];
    }
    return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)setSwitching:(BOOL)switching {
    [self.switchCondition bmBroadcastForPredicateModification:^{
        self->_switching = switching;
    }];
}

- (UIView *)setupSwitchToViewControllerAtIndex:(NSUInteger)index currentViewController:(UIViewController **)vc1 newViewController:(UIViewController **)vc2 transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    if (self.isSwitching) {
        return nil;
    }

    UIViewController *currentViewController = self.selectedViewController;
    UIViewController *otherViewController = index < self.viewControllers.count ? (self.viewControllers)[index] : nil;

    if (currentViewController == otherViewController || !otherViewController) {
        return nil;
    }

    //Will trigger viewDidLoad
    UIView *theView = otherViewController.view;

    if (!theView) {
        return nil;
    }

    self.switching = YES;

    [self switchWillStartToViewController:otherViewController transitionType:transitionType duration:duration];

    if ([self.delegate respondsToSelector:@selector(multiSwitchViewController:willSwitchFromController:toController:)]) {
        [self.delegate multiSwitchViewController:self willSwitchFromController:currentViewController toController:otherViewController];
    }

    theView.frame = self.containerView.bounds;
    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];

    if (vc1) *vc1 = currentViewController;
    if (vc2) *vc2 = otherViewController;

    return theView;
}

- (BOOL)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    BOOL ret = [self switchToViewControllerAtIndex:index transitionType:transitionType duration:duration completion:nil];
    return ret;
}

- (BOOL)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration completion:(void (^)(void))completion {

    UIViewController *currentSelectedViewController = nil;
    UIViewController *newSelectedViewController = nil;
    UIView *theView = [self setupSwitchToViewControllerAtIndex:index currentViewController:&currentSelectedViewController newViewController:&newSelectedViewController transitionType:transitionType duration:duration];
    if (!theView) {
        return NO;
    }

    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [vcArray addObject:newSelectedViewController];
    if (currentSelectedViewController) {
        [vcArray addObject:currentSelectedViewController];
    }

    if (self.viewState == BMViewStateVisible) {
        [currentSelectedViewController beginAppearanceTransition:NO animated:YES];
        [newSelectedViewController beginAppearanceTransition:YES animated:YES];
    }

    [self.containerView addSubview:theView];

    if (transitionType == BMSwitchTransitionTypeCrossFade) {
        theView.alpha = 0.0f;
        [UIView animateWithDuration:duration animations:^{
            theView.alpha = 1.0f;
            currentSelectedViewController.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            currentSelectedViewController.view.alpha = 1.0f;
            [self animationDidStop:finished context:vcArray completion:completion];
        }];
    } else if (transitionType == BMSwitchTransitionTypeFlip) {
        UIViewAnimationOptions options;
        if (_currentFlipTransition == UIViewAnimationTransitionFlipFromLeft) {
            options = UIViewAnimationOptionTransitionFlipFromLeft;
        } else {
            options = UIViewAnimationOptionTransitionFlipFromRight;
        }

        [UIView transitionWithView:self.containerView duration:duration options:options animations:^{
            [currentSelectedViewController.view removeFromSuperview];
        } completion:^(BOOL finished) {
            [self animationDidStop:finished context:vcArray completion:completion];
        }];
        _currentFlipTransition = (_currentFlipTransition == UIViewAnimationTransitionFlipFromLeft) ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft;
    } else {
        [self finishTransition:vcArray completion:completion];
    }
    return YES;
}

- (BOOL)switchToFirstViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    return [self switchToViewControllerAtIndex:0 transitionType:transitionType duration:duration];
}

- (BOOL)switchToLastViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration {
    return [self switchToViewControllerAtIndex:(self.viewControllers.count - 1) transitionType:transitionType duration:duration];
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

- (void)animationDidStop:(BOOL)finished context:(NSArray *)vcs completion:(void (^)(void))completion {
    UIViewController *currentSelectedViewController = vcs.count == 2 ? vcs[1] : nil;
    UIViewController *newSelectedViewController = vcs[0];

    if (currentSelectedViewController.view.superview) {
        [currentSelectedViewController.view removeFromSuperview];
    }

    if (self.viewState == BMViewStateVisible) {
        [currentSelectedViewController endAppearanceTransition];
    }

    _selectedIndex = [self.viewControllers indexOfObject:newSelectedViewController];

    if (self.viewState == BMViewStateVisible) {
        [newSelectedViewController endAppearanceTransition];
    }

    self.switching = NO;

    [self switchDidFinishFromViewController:currentSelectedViewController];

    if ([self.delegate respondsToSelector:@selector(multiSwitchViewController:didSwitchFromController:toController:)]) {
        [self.delegate multiSwitchViewController:self didSwitchFromController:currentSelectedViewController toController:newSelectedViewController];
    }

    if (completion) {
        completion();
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

- (void)finishTransition:(NSArray *)vcs completion:(void (^)(void))completion {
    [self animationDidStop:YES context:vcs completion:completion];
}

- (void)waitForSwitchToFinishWithCompletion:(void (^)(void))completion {
    [self.switchCondition bmWaitForPredicate:^BOOL {
        return !self.isSwitching;
    } completion:^(BOOL waited) {
        if (completion) {
            completion();
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
              withTransition:(BMSwitchTransitionType)transition duration:(CGFloat)duration
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
    _selectedIndex = [_viewControllers indexOfObject:selectedViewController];

    BOOL ret = YES;
    if (currentIndexOccupant != nil && shouldOverwrite) {
        if (currentIndexOccupant == selectedViewController) {
            //Replacing the selectedViewController
            typeof(self) __weak weakSelf = self;
            if (![self switchToViewControllerAtIndex:index transitionType:transition duration:duration completion:^ {
                NSUInteger indexToRemove = [weakSelf.viewControllers indexOfObjectIdenticalTo:currentIndexOccupant];
                [weakSelf removeChildViewControllerAtIndex:indexToRemove];
            }]) {
                ret = NO;
            } else {
                _selectedIndex = NSNotFound;
            }
        } else {
            NSUInteger indexToRemove = [_viewControllers indexOfObjectIdenticalTo:currentIndexOccupant];
            [self removeChildViewControllerAtIndex:indexToRemove];
            _selectedIndex = [_viewControllers indexOfObject:selectedViewController];
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
