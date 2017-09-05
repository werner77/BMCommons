//
//  UIView+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMViewLayout.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, BMHitTestMode) {
    BMHitTestModeDefault = 0,
    BMHitTestModeIgnoreHitsOnSelf = 1 << 0,
    BMHitTestModeAlwaysTraverseSubviewHierarchy = 1 << 1
};

/**
 UIView additions.
 */
@interface UIView(BMCommons)


/**
 * Whether by default all layout operations work integral (i.e. at discrete pixel boundaries using CGRectIntegral etc.).
 *
 * Can be overridden by explicitly specifying the integral flag with methods that support it.
 *
 * The default is true.
 */
@property (nonatomic, assign, class) BOOL bmDefaultLayoutIntegral;

/**
 * Whether by default tranforms are ignored for layout operations.
 *
 * Can be overridden by explicitly specifying the ignoreTransform flag with methods that support it.
 *
 * The default is false.
 */
@property (nonatomic, assign, class) BOOL bmDefaultLayoutTransformsIgnore;

/**
 * The hit test mode to use for the view.
 *
 * BMHitTestModeDefault is the normal behavior.
 * BMHitTestModeIgnoreHitsOnSelf will never return self from hit test, but will only return in a positive hit if a subview is hit.
 * BMHitTestModeAlwaysTraverseSubviewHierarchy will always traverse the descendents to test for hits even if self is reported as a hit.
 */
@property (nonatomic, assign) BMHitTestMode bmHitTestMode;

/**
 * The insets for the hit area of the receiver. Use negative insets to extend the hit area beyond the bounds.
 */
@property (nonatomic, assign) UIEdgeInsets bmHitAreaInsets;

/**
 * Returns the fitting size of an instance of this class by first constructing a template instance (template instances are reused for multiple successive calls).
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param constraintSize The constraintSize to use to compute the fitting size
 * @param configuration Optional configuration block to apply to the template view before determining the fitting size.
 * @return The fitting size as returned from sizeThatFits:
 */
+ (CGSize)bmSizeThatFitsConstraintSize:(CGSize)constraintSize configuration:(void (^ _Nullable)(UIView *view))configuration;

/**
 * Returns the fitting size of an instance of this class by first constructing a template instance (template instances are reused for multiple successive calls).
 *
 * @param constraintSize The constraintSize to use to compute the fitting size
 * @param configuration Optional configuration block to apply to the template view before determining the fitting size.
 * @param integral Whether integral calculations should be performed
 * @param ignoreTransform Whether transforms should be ignored
 * @return The fitting size as returned from sizeThatFits:
 */
+ (CGSize)bmSizeThatFitsConstraintSize:(CGSize)constraintSize configuration:(void (^ _Nullable)(UIView *view))configuration integral:(BOOL)integral ignoreTransform:(BOOL)ignoreTransform;

/**
 * Lays out the specified array of views with the specified total constraintSize at the specified anchor point/alignment.
 *
 * Uses the direction and spacing to arrange the views relative to each other. Depending on the alignment the layout may occur from left to right or inversely. Same for the vertical direction.
 * Returns the resulting encompassing rect for the layout.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param views The array of views to layout
 * @param point The anchor point to use for layout.
 * @param alignment The alignment of the views relative to the anchor point.
 * @param direction The direction to use for layout (relative positioning of the views)
 * @param spacing The spacing of views relative to each other.
 * @param constraintSize The total constraintSize for all the views. Used to calculate sizeThatFits for each view for layout.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The encompassing rect for the layout.
 */
+ (CGRect)bmLayoutViews:(NSArray<UIView *> *)views atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing constraintSize:(CGSize)constraintSize apply:(BOOL)apply;

/**
 * Lays out the specified array of views with the specified total constraintSize at the specified anchor point/alignment.
 *
 * Uses the direction and spacing to arrange the views relative to each other. Depending on the alignment the layout may occur from left to right or inversely. Same for the vertical direction.
 * Returns the resulting encompassing rect for the layout.
 *
 * @param views The array of views to layout
 * @param point The anchor point to use for layout.
 * @param alignment The alignment of the views relative to the anchor point.
 * @param direction The direction to use for layout (relative positioning of the views)
 * @param spacing The spacing of views relative to each other.
 * @param constraintSize The total constraintSize for all the views. Used to calculate sizeThatFits for each view for layout.
 * @param integral Whether integral calculations should be done.
 * @param ignoreTransforms Whether transforms should be ignored.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The encompassing rect for the layout.
 */
+ (CGRect)bmLayoutViews:(NSArray<UIView *> *)views atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing constraintSize:(CGSize)constraintSize integral:(BOOL)integral ignoreTransforms:(BOOL)ignoreTransforms apply:(BOOL)apply;

/**
 * Lays out the specified array of views with the specified array of sizes at the specified anchor point/alignment.
 *
 * Uses the direction and spacing to arrange the views relative to each other. Depending on the alignment the layout may occur from left to right or inversely. Same for the vertical direction.
 * Returns the resulting encompassing rect for the layout.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param views The array of views to layout
 * @param viewSizes The array of sizes for each view. The length of this array must match the length of the views array.
 * @param point The anchor point to use for layout.
 * @param alignment The alignment of the views relative to the anchor point.
 * @param direction The direction to use for layout (relative positioning of the views)
 * @param spacing The spacing of views relative to each other.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The encompassing rect for the layout.
 */
+ (CGRect)bmLayoutViews:(NSArray<UIView *> *)views withSizes:(NSArray<NSValue *> *)viewSizes atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the specified array of views with the specified array of sizes at the specified anchor point/alignment.
 *
 * Uses the direction and spacing to arrange the views relative to each other. Depending on the alignment the layout may occur from left to right or inversely. Same for the vertical direction.
 * Returns the resulting encompassing rect for the layout.
 *
 * @param views The array of views to layout
 * @param viewSizes The array of sizes for each view. The length of this array must match the length of the views array.
 * @param point The anchor point to use for layout.
 * @param alignment The alignment of the views relative to the anchor point.
 * @param direction The direction to use for layout (relative positioning of the views)
 * @param spacing The spacing of views relative to each other.
 * @param integral Whether integral calculations should be done.
 * @param ignoreTransforms Whether transforms should be ignored.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The encompassing rect for the layout.
 */
+ (CGRect)bmLayoutViews:(NSArray<UIView *> *)views withSizes:(NSArray<NSValue *> *)viewSizes atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing integral:(BOOL)integral ignoreTransforms:(BOOL)ignoreTransforms apply:(BOOL)apply;

/**
  * Searches this view's hierarchy for the first responder
 */
- (nullable UIView *)bmFirstResponder;

/**
 Gets the views content as a UIImage.
 */
- (nullable UIImage *)bmContentsAsImage;

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
 Traverses the super view hierarchy of this view and calls the specified block for every view encountered.

 If the block returns NO the hierarchy will not be traversed for superviews of the encountered view, otherwise it will.
 */
- (void)bmTraverseSuperviewHierarchyWithBlock:(BOOL (^)(UIView *view))block;

/**
 Removes any margins and insets that are added by iOS 7/8.
 */
- (void)bmRemoveMarginsAndInsets;

/**
 * Uses setBounds and setCenter instead of setFrame to avoid issues when a transform is applied to the receiver.
 */
- (void)bmSetFrameIgnoringTransform:(CGRect)frame;

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

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions  applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout completion:(void (^ _Nullable)(BOOL finished))completion;

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

- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void (^ _Nullable)(BOOL finished))completion;

/**
 * Returns an array with all descendants of this view recursively.
 */
- (NSArray<UIView *> *)bmDescendantViews;

/**
 * Returns an array by traversing all superviews recursively.
 */
- (NSArray<UIView *> *)bmAncestorViews;

/**
 * Returns a point aligned to the bounds of the receiver with the specified alignment.
 */
- (CGPoint)bmPointWithAlignment:(BMViewLayoutAlignment)alignment;

/**
 * Returns a point aligned to the bounds of the receiver with the specified alignment and insets.
 */
- (CGPoint)bmPointWithAlignment:(BMViewLayoutAlignment)alignment insets:(UIEdgeInsets)insets;

/**
 * Cancels all animations on the receiver.
 */
- (void)bmCancelAllAnimations;

/**
 * Cancels all animations on the receiver, optionally cancelling animations on all descendants as well.
 */
- (void)bmCancelAllAnimationsRecursively:(BOOL)recursively;

/**
 * Cancells all gesture recognizers on the receiver.
 */
- (void)bmCancelAllGestureRecognizers;

/**
 * Cancells all gesture recognizers on the receiver, optionally cancelling gesture recognizers on all descendants as well.
 */
- (void)bmCancelAllGestureRecognizersRecursively:(BOOL)recursively;

/**
 * Forces immediate layout of the receiver by calling setNeedsLayout and layoutIfNeeded.
 */
- (void)bmForceLayoutImmediately;

/**
 * Forces immediate layout of the receiver by calling setNeedsLayout and layoutIfNeeded, optionally forces layout on all descendents as well.
 */
- (void)bmForceLayoutImmediatelyRecursively:(BOOL)recursively;

/**
 * Performs the specified block by first setting the transform of the receiver to the identity tranform.
 * After the block is performed, the transformed is reset to the original value.
 *
 * @param block The block to perform.
 */
- (void)bmPerformWithoutTransform:(void (^)(void))block;

/**
 * Sets the frame of the receiver, optionally ignoring any tranform set.
 *
 * @param frame The frame to set
 * @param ignoreTransform Whether transforms should be ignored or not.
 */
- (void)bmSetFrame:(CGRect)frame ignoreTransform:(BOOL)ignoreTransform;

/**
 * Returns the size that fits the receiver, optionally ignoring any transform set
 *
 * @param size The constraint size
 * @param ignoreTransform Whether transforms should be ignored or not
 * @return The fitting size
 */
- (CGSize)bmSizeThatFits:(CGSize)size ignoreTransform:(BOOL)ignoreTransform;

/**
 * Returns the size that fits the receiver by first insetting the constraint size with the specified insets, optionally ignoring any transform set.
 *
 * On result the insets are inversely applied.
 *
 * @param size The constraint size The constraint size
 * @param insets The insets to apply to the constraint size
 * @param ignoreTransform Whether transforms should be ignored or not
 * @return The fitting size
 */
- (CGSize)bmSizeThatFits:(CGSize)size withInsets:(UIEdgeInsets)insets ignoreTransform:(BOOL)ignoreTransform;

/**
 * Lays out the receiver at the specified origin, using the size resulting from sizeThatFits with the specified constraintSize.
 * A vertical layout direction is assumed.
 *
 * Upon result the origin point is updated using the size of the receiver and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point (top-left) to layout the receiver at
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param spacing The spacing to apply after layout to update the origin point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint * _Nonnull)origin withConstraintSize:(CGSize)constraintSize spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified origin, using the size resulting from sizeThatFits with the specified constraintSize.
 * The layout direction is specified.
 *
 * Upon result the origin point is updated using the size of the receiver and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point (top-left) to layout the receiver at
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment the origin point with the spacing after layout.
 * @param spacing The spacing to apply after layout to update the origin point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint * _Nonnull)origin withConstraintSize:(CGSize)constraintSize direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified point with the specified alignment, using the size resulting from sizeThatFits with the specified constraintSize.
 * The layout direction is specified.
 *
 * Upon result the point is updated using the size of the receiver, the layoutDirection and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param point The anchor point to layout the receiver at. Depending on the alignment this can be top-left, top-center, top-right, etc.
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param alignment The alignment to use for the layout relative to the anchor point
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment/decrement the anchor point's position with the spacing after layout. If the alignment is right and/or bottom the position is decremented with the spacing instead of incremented.
 * @param spacing The spacing to apply after layout to update the anchor point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint * _Nonnull)point withConstraintSize:(CGSize)constraintSize alignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified point with the specified alignment, using the size resulting from sizeThatFits with the specified constraintSize.
 * The layout direction is specified.
 *
 * Upon result the point is updated using the size of the receiver, the layoutDirection and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * @param point The anchor point to layout the receiver at. Depending on the alignment this can be top-left, top-center, top-right, etc.
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param alignment The alignment to use for the layout relative to the anchor point
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment/decrement the anchor point's position with the spacing after layout. If the alignment is right and/or bottom the position is decremented with the spacing instead of incremented.
 * @param spacing The spacing to apply after layout to update the anchor point with.
 * @param integral Whether integral calculations should be applied (CGRectIntegral, CGSizeIntegral)
 * @param ignoreTransform Whether transforms should be ignored when setting the frame
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint * _Nonnull)point withConstraintSize:(CGSize)constraintSize alignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing integral:(BOOL)integral ignoreTransform:(BOOL)ignoreTransform apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified origin, using the specified size.
 * A vertical layout direction is assumed.
 *
 * Upon result the origin point is updated using the size of the receiver and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point (top-left) to layout the receiver at
 * @param size The size for layout.
 * @param spacing The spacing to apply after layout to update the origin point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint * _Nonnull)origin withSize:(CGSize)size spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified origin, using the specified size.
 * The layout direction is specified.
 *
 * Upon result the origin point is updated using the size of the receiver and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point (top-left) to layout the receiver at
 * @param size The size for layout.
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment the origin point with the spacing after layout.
 * @param spacing The spacing to apply after layout to update the origin point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint * _Nonnull)origin withSize:(CGSize)size direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified point with the specified alignment, using the specified size.
 * The layout direction is specified.
 *
 * Upon result the point is updated using the size of the receiver, the layoutDirection and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param point The anchor point to layout the receiver at. Depending on the alignment this can be top-left, top-center, top-right, etc.
 * @param size The size for layout.
 * @param alignment The alignment to use for the layout relative to the anchor point
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment/decrement the anchor point's position with the spacing after layout. If the alignment is right and/or bottom the position is decremented with the spacing instead of incremented.
 * @param spacing The spacing to apply after layout to update the anchor point with.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint * _Nonnull)point withSize:(CGSize)size alignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified point with the specified alignment, using the specified size.
 * The layout direction is specified.
 *
 * Upon result the point is updated using the size of the receiver, the layoutDirection and the spacing so it can immediately be used to layout a subsequent view in the same direction.
 *
 * @param point The anchor point to layout the receiver at. Depending on the alignment this can be top-left, top-center, top-right, etc.
 * @param size The size for layout.
 * @param alignment The alignment to use for the layout relative to the anchor point
 * @param layoutDirection The layout direction to use (horizontal/vertical or both) to increment/decrement the anchor point's position with the spacing after layout. If the alignment is right and/or bottom the position is decremented with the spacing instead of incremented.
 * @param spacing The spacing to apply after layout to update the anchor point with.
 * @param integral Whether integral calculations should be used (CGRectIntegral, etc)
 * @param ignoreTransform Whether tranform should be ignored when applying the frame.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint * _Nonnull)point withSize:(CGSize)size alignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing integral:(BOOL)integral ignoreTranform:(BOOL)ignoreTransform apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified top-left origin, with the specified size.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point to use for layout
 * @param size The size to use for layout
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint)origin withSize:(CGSize)size apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified top-left origin, with the fitting size corresponding to the specified constraintSize.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param origin The origin point to use for layout
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtOrigin:(CGPoint)origin withConstraintSize:(CGSize)constraintSize apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified anchor point, with the specified alignment and size.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param point The anchor point to use for layout
 * @param size The size to use for layout
 * @param alignment The alignment for the anchor point
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint)point withSize:(CGSize)size alignment:(BMViewLayoutAlignment)alignment apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified anchor point, using the specified alignment with the fitting size corresponding to the specified constraintSize.
 *
 * Uses default layoutIntegral and layoutIgnoreTransform modes.
 *
 * @param point The anchor point to use for layout
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param alignment The alignment for the anchor point
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint)point withConstraintSize:(CGSize)constraintSize alignment:(BMViewLayoutAlignment)alignment apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified anchor point, with the specified alignment and size.
 *
 * @param point The anchor point to use for layout
 * @param size The size to use for layout
 * @param alignment The alignment for the anchor point
 * @param integral Whether integral calculations should be used (CGRectIntegral, etc)
 * @param ignoreTransform Whether tranform should be ignored when applying the frame.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint)point withSize:(CGSize)size alignment:(BMViewLayoutAlignment)alignment integral:(BOOL)integral ignoreTransform:(BOOL)ignoreTransform apply:(BOOL)apply;

/**
 * Lays out the receiver at the specified anchor point, using the specified alignment with the fitting size corresponding to the specified constraintSize.
 *
 * @param point The anchor point to use for layout
 * @param constraintSize The constraintSize used to compute the fitting size for layout.
 * @param alignment The alignment for the anchor point
 * @param integral Whether integral calculations should be used (CGRectIntegral, etc)
 * @param ignoreTransform Whether tranform should be ignored when applying the frame.
 * @param apply Whether the layout should actually be applied (setFrame called) or only calculated.
 * @return The resulting frame from layout. Is only actually applied if apply was true.
 */
- (CGRect)bmLayoutAtPoint:(CGPoint)point withConstraintSize:(CGSize)constraintSize alignment:(BMViewLayoutAlignment)alignment integral:(BOOL)integral ignoreTransform:(BOOL)ignoreTransform apply:(BOOL)apply;

@end

NS_ASSUME_NONNULL_END
