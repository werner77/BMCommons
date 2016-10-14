//
//  UIView+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIView additions.
 */
@interface UIView(BMCommons) 

/**
  * Searches this view's hierarchy for the first responder
 */
- (UIView *)bmFirstResponder;

/**
 Gets the views content as a UIImage.
 */
- (UIImage *)bmContentsAsImage;

/**
 Returns YES if and only if the view is visible i.e. self.window is defined.
 */
- (BOOL)bmIsVisible;

/**
 Traverses the subview hierarchy of this view and calls the specified block for every view encountered. 
 
 If the block returns NO the hierarchy will not be traversed for subviews of the encountered view, otherwise it will.
 */
- (void)bmTraverseSubviewHierarchyWithBlock:(BOOL (^)(UIView *view))block;

/**
 Removes any margins and insets that are added by iOS 7/8.
 */
- (void)bmRemoveMarginsAndInsets;

/**
 Calls bmLayoutWithBlock:animationDuration:applyPendingLayoutBeforeAnimation: with applyPendingLayout set to YES.
 */
- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration;

/**
 Updates the layout of this view using the operations from the specified block.

 layoutIfNeeded is called automatically after the block is called in case the layout is animated.
 
 If duration > 0 the layout is done within an animation using default animation options (UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut)

 If applyPendingLayout == true and animationDuration > 0 a layoutIfNeeded is performed before the animation block.
 */
- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout;

/**
 Updates the layout of this view using the operations from the specified block.

 layoutIfNeeded is called automatically after the block is called in case the layout is animated.
 
 If duration > 0 the layout is done within an animation using the specified animation options.

 If applyPendingLayout == true and animationDuration > 0 a layoutIfNeeded is performed before the animation block.
 */
- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions  applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout;

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions  applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout completion:(void (^)(BOOL finished))completion;

/**
 Transitions the view using the operations from the specified block.
 
 If duration > 0 the transition is done within an animation using the default animation options (UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve)
 */
- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration;

/**
 Transitions the view using the operations from the specified block.
 
 If duration > 0 the transition is done within an animation using the specified animation options.
 */
- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions;

- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void (^)(BOOL finished))completion;


@end
