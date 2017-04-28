//
//  BMMultiSwitchViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/3/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMViewController.h>

// possible to use predefined viewTransition styles instead of custom enum?
typedef enum BMSwitchTransitionType {
    BMSwitchTransitionTypeNone,
    BMSwitchTransitionTypeCrossFade,
    BMSwitchTransitionTypeFlip
} BMSwitchTransitionType;


@class BMMultiSwitchViewController;

/**
 Delegate protocol to act on switch events.
 */
@protocol BMMultiSwitchViewControllerDelegate<NSObject>

@optional
- (void)multiSwitchViewController:(BMMultiSwitchViewController *)msvc didSwitchFromController:(UIViewController *)vc1 toController:(UIViewController *)vc2;
- (void)multiSwitchViewController:(BMMultiSwitchViewController *)msvc willSwitchFromController:(UIViewController *)vc1 toController:(UIViewController *)vc2;

@end

/**
 Custom container view controller (compare with UITabBarController) that supports custom animations and inserts/replacements of view controllers.
 */
@interface BMMultiSwitchViewController : BMViewController

/**
 The delegate
 */
@property (nonatomic, weak) id <BMMultiSwitchViewControllerDelegate> delegate;

/**
 The array of view controllers maintained by this instance.
 */
@property (nonatomic, strong, readonly) NSMutableArray *viewControllers;

/**
 The index of the currently selected view controller.
 */
@property (nonatomic, readonly) NSUInteger selectedIndex;

/**
 The first view controller in the array.
 */
@property (strong, nonatomic, readonly) UIViewController *firstViewController;

/**
 The last view controller in the array.
 */
@property (strong, nonatomic, readonly) UIViewController *lastViewController;

/**
 Whether a switch is currently going on or not.
 */
@property (nonatomic, readonly, getter=isSwitching) BOOL switching;

/**
 Returns the view that acts as a super view for the other view controller's views. It defaults to self.view.
 */
@property (nonatomic, strong) IBOutlet UIView *containerView;

- (id)initWithViewController:(UIViewController *)firstViewController;
- (id)initWithViewControllers:(NSArray *)theViewControllers;
- (id)initWithViewControllers:(NSArray *)theViewControllers selectedIndex:(NSUInteger)selectedIndex;

- (void)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index overwriteExisting:(BOOL)shouldOverwrite;
- (void)addViewController:(UIViewController *)viewController;
- (void)removeViewControllerAtIndex:(NSUInteger)index;
- (void)removeViewController:(UIViewController *)viewController;
- (void)removeLastViewController;

- (void)replaceSelectedViewControllerWithViewController:(UIViewController *)viewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration;
- (void)replaceSelectedViewControllerWithViewController:(UIViewController *)viewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration completion:(void (^)(BOOL success))completion;

- (void)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration;
- (void)switchToViewControllerAtIndex:(NSUInteger)index transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration completion:(void (^)(BOOL success))completion;

- (void)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration;
- (void)switchToViewController:(UIViewController *)theViewController transitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration completion:(void (^)(BOOL success))completion;

- (void)switchToFirstViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration;
- (void)switchToLastViewControllerWithTransitionType:(BMSwitchTransitionType)transitionType duration:(CGFloat)duration;

/**
 Returns the currently selected view controller.
 */
- (UIViewController *)selectedViewController;

/**
 Returns the first view controller in the array that is an instance of the specified class.
 */
- (UIViewController	*)firstViewControllerOfKind:(Class)viewControllerClass;

//Protected methods

- (void)switchWillStartToViewController:(UIViewController *)newViewController transitionType:(BMSwitchTransitionType)transitionType duration:(NSTimeInterval)duration;

- (void)switchDidFinishFromViewController:(UIViewController *)oldViewController;

/**
 Can be overridden by subclasses to perform some meaningful action upon starting of the switch animation. Deprecated, use overloaded method with view controller argument.
 */
- (void)switchWillStart;

/**
 Can be overridden by subclasses to perform some meaningful action upon ending of the switch animation. Deprecated, use overloaded method with view controller argument.
 */
- (void)switchDidFinish;

- (void)waitForSwitchToFinishWithCompletion:(void (^)(void))completion;

- (void)waitUntilSwitchIsAllowedWithCompletion:(void (^)(void))completion;


@end
