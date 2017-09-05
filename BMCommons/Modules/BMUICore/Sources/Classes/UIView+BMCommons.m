//
//  UIView+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "UIView+BMCommons.h"
#import "UIGestureRecognizer+BMCommons.h"
#import "BMUICore.h"

@implementation UIView(BMCommons)

static char const *kHitAreaInsetsKey = "com.behindmedia.bmcommons.UIView.bmHitAreaInsets";
static char const *kHitTestModeKey = "com.behindmedia.bmcommons.UIView.bmHitTestMode";

static IMP originalSetAnimationsEnabledImpl = NULL;
static IMP originalPointInsideImpl = NULL;
static IMP originalHitTestImpl = NULL;
static NSMutableDictionary *prototypes = nil;
static BOOL defaultLayoutIntegral = YES;
static BOOL defaultTranformIgnore = NO;

static const BMViewLayoutAlignment kDefaultLayoutAlignment = BMViewLayoutAlignmentLeft | BMViewLayoutAlignmentTop;
static const BMViewLayoutDirection kDefaultLayoutDirection = BMViewLayoutDirectionVertical;

#if !NS_BLOCK_ASSERTIONS
static const CGFloat kBoundedThreshold = (CGFLOAT_MAX/1000000.0f);
#define BMAssertBounded(parameter) NSAssert(parameter < kBoundedThreshold, @"Parameter %s should be bounded", #parameter)
#else
#define BMAssertBounded(...) do {} while (0)
#endif

static void __BMSetAnimationsEnabled(Class self, SEL cmd, BOOL enabled) {
    //Fix for race condition in original setAnimationsEnabled method. This method is only relevant for the main thread, not for background threads.
    //This is necessary for BMNib background precaching to work, which instantiates views in a background thread (alloc/init is allowed in background thread according to UIKit documentation)
    if ([NSThread isMainThread]) {
        ((void (*)(id, SEL, BOOL))originalSetAnimationsEnabledImpl)(self, cmd, enabled);
    }
}

static BOOL __BMPointInside(UIView *self, SEL cmd, CGPoint point, UIEvent *event) {
    UIEdgeInsets hitAreaInsets = self.bmHitAreaInsets;
    if (UIEdgeInsetsEqualToEdgeInsets(hitAreaInsets, UIEdgeInsetsZero)) {
        return ((BOOL (*)(id, SEL, CGPoint, UIEvent*))originalPointInsideImpl)(self, cmd, point, event);
    } else {
        CGRect rect = BMRectInset(self.bounds, hitAreaInsets);
        return CGRectContainsPoint(rect, point);
    }
}

static UIView * __BMHitTest(UIView *self, SEL cmd, CGPoint point, UIEvent *event) {
    UIView *hitView = ((UIView* (*)(id, SEL, CGPoint, UIEvent*))originalHitTestImpl)(self, cmd, point, event);
    BMHitTestMode hitTestMode = self.bmHitTestMode;
    if (BM_CONTAINS_BIT(hitTestMode, BMHitTestModeAlwaysTraverseSubviewHierarchy) && hitView == self) {
        UIView *descendentHitView = nil;
        for (UIView *subview in [self bmDescendantViews]) {
            descendentHitView = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
            if (descendentHitView != nil) {
                break;
            }
        }
        if (descendentHitView != nil) {
            hitView = descendentHitView;
        }
    }

    if (BM_CONTAINS_BIT(hitTestMode, BMHitTestModeIgnoreHitsOnSelf) && hitView == self) {
        hitView = nil;
    }
    return hitView;
}

+ (void)load {
    BM_DISPATCH_ONCE(^{
        originalSetAnimationsEnabledImpl = BMReplaceClassMethodImplementation([UIView class], @selector(setAnimationsEnabled:), (IMP)__BMSetAnimationsEnabled);
        originalPointInsideImpl = BMReplaceMethodImplementation([UIView class], @selector(pointInside:withEvent:), (IMP) __BMPointInside);
        originalHitTestImpl = BMReplaceMethodImplementation([UIView class], @selector(hitTest:withEvent:), (IMP) __BMHitTest);
    });
}

+ (void)setBmDefaultLayoutIntegral:(BOOL)bmDefaultLayoutIntegral {
    @synchronized ([UIView class]) {
        defaultLayoutIntegral = bmDefaultLayoutIntegral;
    }
}

+ (BOOL)bmDefaultLayoutIntegral {
    @synchronized ([UIView class]) {
        return defaultLayoutIntegral;
    }
}

+ (void)setBmDefaultLayoutTransformsIgnore:(BOOL)bmDefaultLayoutTransformsIgnore {
    @synchronized ([UIView class]) {
        defaultTranformIgnore = bmDefaultLayoutTransformsIgnore;
    }
}

+ (BOOL)bmDefaultLayoutTransformsIgnore {
    @synchronized ([UIView class]) {
        return defaultTranformIgnore;
    }
}

- (NSArray<UIView *> *)bmDescendantViews {
    NSMutableArray *ret = [NSMutableArray new];
    [self bmTraverseSubviewHierarchyWithBlock:^BOOL(UIView *view) {
        if (view != self) {
            [ret addObject:view];
        }
        return YES;
    }];
    return ret;
}

- (NSArray<UIView *> *)bmAncestorViews {
    NSMutableArray *ret = [NSMutableArray new];
    [self bmTraverseSuperviewHierarchyWithBlock:^BOOL(UIView *view) {
        if (view != self) {
            [ret addObject:view];
        }
        return YES;
    }];
    return ret;
}

- (BMHitTestMode)bmHitTestMode {
    return (BMHitTestMode)[objc_getAssociatedObject(self, kHitTestModeKey) unsignedIntegerValue];
}

- (void)setBmHitTestMode:(BMHitTestMode)hitTestMode{
    return objc_setAssociatedObject(self, kHitTestModeKey, @(hitTestMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)bmHitAreaInsets {
    NSValue *value = objc_getAssociatedObject(self, kHitAreaInsetsKey);
    return value == nil ? UIEdgeInsetsZero : [value UIEdgeInsetsValue];
}

- (void)setBmHitAreaInsets:(UIEdgeInsets)hitAreaInsets{
    return objc_setAssociatedObject(self, kHitAreaInsetsKey, [NSValue valueWithUIEdgeInsets:hitAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)bmPointWithAlignment:(BMViewLayoutAlignment)alignment {
    return [self bmPointWithAlignment:alignment insets:UIEdgeInsetsZero];
}

- (CGPoint)bmPointWithAlignment:(BMViewLayoutAlignment)alignment insets:(UIEdgeInsets)insets {
    return BMPointAlignedToRectWithInsets(alignment, self.bounds, insets);
}

- (UIView *)bmFirstResponder {
	if (self.isFirstResponder) {
		return self;
	}
	for (UIView *subView in self.subviews) {
		UIView *r = [subView bmFirstResponder];
		if (r) {
			return r;
		}
	}
	return nil;
}

- (UIImage *)bmContentsAsImage {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.bounds.size);

    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (void)bmCancelAllAnimations {
    [self bmCancelAllAnimationsRecursively:NO];
}

- (void)bmCancelAllAnimationsRecursively:(BOOL)recursively {
    [self bmTraverseSubviewHierarchyWithBlock:^BOOL(UIView *view) {
        BOOL ret = recursively || (view == self);
        [view.layer removeAllAnimations];
        return ret;
    }];
}

- (void)bmCancelAllGestureRecognizers {
    [self bmCancelAllAnimationsRecursively:NO];
}

- (void)bmCancelAllGestureRecognizersRecursively:(BOOL)recursively {
    [self bmTraverseSubviewHierarchyWithBlock:^BOOL(UIView *view) {
        BOOL ret = recursively || (view == self);
        for (UIGestureRecognizer *gr in self.gestureRecognizers) {
            [gr bmCancel];
        }
        return ret;
    }];
}

- (void)bmForceLayoutImmediately {
    [self bmForceLayoutImmediatelyRecursively:NO];
}

- (void)bmForceLayoutImmediatelyRecursively:(BOOL)recursively {
    [self bmTraverseSubviewHierarchyWithBlock:^BOOL(UIView *view) {
        BOOL ret = recursively || (view == self);
        [view setNeedsLayout];
        [view layoutIfNeeded];
        return ret;
    }];
}

- (void)bmPerformWithoutTransform:(void (^)(void))block {
    BOOL transformSet = NO;
    CGAffineTransform transform = self.transform;
    if (!CGAffineTransformIsIdentity(transform)) {
        self.transform = CGAffineTransformIdentity;
        transformSet = YES;
    }
    if (block) {
        block();
    }
    if (transformSet) {
        self.transform = transform;
    }
}

- (void)bmSetFrame:(CGRect)frame ignoreTransform:(BOOL)ignoreTransform {
    if (ignoreTransform) {
        [self bmPerformWithoutTransform:^{
            [self setFrame:frame];
        }];
    } else {
        [self setFrame:frame];
    }
}

- (CGSize)bmSizeThatFits:(CGSize)size ignoreTransform:(BOOL)ignoreTransform {
    return [self bmSizeThatFits:size withInsets:UIEdgeInsetsZero ignoreTransform:ignoreTransform];
}

- (CGSize)bmSizeThatFits:(CGSize)size withInsets:(UIEdgeInsets)insets ignoreTransform:(BOOL)ignoreTransform {
    CGSize constraintSize = BMSizeInset(size, insets);
    CGSize __block ret;
    if (ignoreTransform) {
        [self bmPerformWithoutTransform:^{
            ret = [self sizeThatFits:constraintSize];
        }];

    } else {
        ret = [self sizeThatFits:constraintSize];
    }
    ret = BMSizeInset(ret, BMEdgeInsetsInvert(insets));
    return ret;
}


+ (CGSize)bmSizeThatFitsConstraintSize:(CGSize)constraintSize configuration:(void (^)(UIView *view))configuration {
    return [self bmSizeThatFitsConstraintSize:constraintSize configuration:configuration integral:[self bmDefaultLayoutIntegral] ignoreTransform:[self bmDefaultLayoutTransformsIgnore]];
}

+ (CGSize)bmSizeThatFitsConstraintSize:(CGSize)constraintSize configuration:(void (^)(UIView *view))configuration integral:(BOOL)integral ignoreTransform:(BOOL)ignoreTransform {
    @synchronized([UIView class]) {
        static BOOL listeningForNotifications = NO;

        if (prototypes == nil) {
            prototypes = [NSMutableDictionary new];
        }

        if (!listeningForNotifications) {
            listeningForNotifications = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_BMDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }

        id key = NSStringFromClass(self);
        UIView *view = prototypes[key];

        if (view == nil) {
            view = [self new];
            prototypes[key] = view;
        }

        if (configuration) {
            configuration(view);
        }
        CGSize size = [view bmSizeThatFits:constraintSize ignoreTransform:ignoreTransform];
        return BMSizeMakeIntegral(size.width, size.height);
    }
}

- (BOOL)bmIsVisible {
    return self.window != nil;
}

- (void)bmTraverseSubviewHierarchyWithBlock:(BOOL (^)(UIView *view))block {
    if (block(self)) {
        NSArray *subviews = [NSArray arrayWithArray:self.subviews];
        for (UIView *subview in subviews) {
            [subview bmTraverseSubviewHierarchyWithBlock:block];
       }
    }
}

- (void)bmTraverseSuperviewHierarchyWithBlock:(BOOL (^)(UIView *view))block {
    if (block(self)) {
        UIView *superview = self.superview;
        if (superview) {
            [superview bmTraverseSuperviewHierarchyWithBlock:block];
        }
    }
}

- (void)bmSetFrameIgnoringTransform:(CGRect)frame {
    CGAffineTransform transform = self.transform;
    if (CGAffineTransformIsIdentity(transform)) {
        [self setFrame:frame];
    } else {
        self.transform = CGAffineTransformIdentity;
        [self setFrame:frame];
        self.transform = transform;
    }
}

- (void)bmRemoveMarginsAndInsets {
    [self setPreservesSuperviewLayoutMargins:NO];    
    [self setLayoutMargins:UIEdgeInsetsZero];
}

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration {
    [self bmLayoutWithBlock:block animationDuration:duration applyPendingLayoutBeforeAnimation:YES];
}

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout {
    [self bmLayoutWithBlock:block animationDuration:duration animationOptions:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState)
            applyPendingLayoutBeforeAnimation:applyPendingLayout];
}

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions
        applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout {
    [self bmLayoutWithBlock:block animationDuration:duration animationOptions:animationOptions applyPendingLayoutBeforeAnimation:applyPendingLayout completion:nil];
}

- (void)bmLayoutWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions  applyPendingLayoutBeforeAnimation:(BOOL)applyPendingLayout completion:(void (^)(BOOL finished))completion {
    if (duration > 0.0) {
        if (applyPendingLayout) {
            [self layoutIfNeeded];
        }
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:animationOptions
                         animations:^{
                             if (block) {
                                 block();
                             }
                             [self layoutIfNeeded];
                         } completion:completion];
    } else if (block) {
        block();
        if (completion) {
            completion(YES);
        }
    }
}

- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration {
    [self bmTransitionWithBlock:block animationDuration:duration animationOptions:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions {
    [self bmTransitionWithBlock:block animationDuration:duration animationOptions:animationOptions completion:nil];
}

- (void)bmTransitionWithBlock:(void (^)(void))block animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void (^)(BOOL finished))completion {
    if (duration > 0.0) {
        [UIView transitionWithView:self
                          duration:duration
                           options:animationOptions
                        animations:^{
                            if (block) {
                                block();
                            }
                        }
                        completion:completion];
    } else if (block) {
        block();
        if (completion) {
            completion(YES);
        }
    }
}


#pragma mark - Layout methods

- (CGRect)bmLayoutAtOrigin:(CGPoint *)origin
      withConstraintSize:(CGSize)constraintSize
                 spacing:(CGFloat)spacing
                   apply:(BOOL)apply {
    return [self bmLayoutAtOrigin:origin withConstraintSize:constraintSize
                      direction:kDefaultLayoutDirection spacing:spacing apply:apply];
}

- (CGRect)bmLayoutAtOrigin:(CGPoint *)origin
      withConstraintSize:(CGSize)constraintSize
               direction:(BMViewLayoutDirection)layoutDirection
                 spacing:(CGFloat)spacing
                   apply:(BOOL)apply {
    return [self bmLayoutAtPoint:origin withConstraintSize:constraintSize alignment:kDefaultLayoutAlignment
                     direction:layoutDirection spacing:spacing apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint *)point
     withConstraintSize:(CGSize)constraintSize
              alignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)layoutDirection
                spacing:(CGFloat)spacing
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:point
            withConstraintSize:constraintSize
                     alignment:alignment
                     direction:layoutDirection
                       spacing:spacing
                      integral:[self.class bmDefaultLayoutIntegral]
            ignoreTransform:[self.class bmDefaultLayoutTransformsIgnore]
                         apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint *)point
     withConstraintSize:(CGSize)constraintSize
              alignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)layoutDirection
                spacing:(CGFloat)spacing
               integral:(BOOL)integral
          ignoreTransform:(BOOL)ignoreTransform
                  apply:(BOOL)apply {
    CGSize size = [self bmSizeThatFits:constraintSize ignoreTransform:ignoreTransform];
    size.width = MIN(size.width, constraintSize.width);
    size.height = MIN(size.height, constraintSize.height);
    return [self bmLayoutAtPoint:point withSize:size alignment:alignment
                     direction:layoutDirection spacing:spacing integral:integral ignoreTranform:ignoreTransform apply:apply];
}

- (CGRect)bmLayoutAtOrigin:(CGPoint *)origin
                withSize:(CGSize)size
                 spacing:(CGFloat)spacing
                   apply:(BOOL)apply {
    return [self bmLayoutAtOrigin:origin withSize:size
                      direction:kDefaultLayoutDirection spacing:spacing apply:apply];
}

- (CGRect)bmLayoutAtOrigin:(CGPoint *)origin
                withSize:(CGSize)size
               direction:(BMViewLayoutDirection)layoutDirection
                 spacing:(CGFloat)spacing
                   apply:(BOOL)apply {
    return [self bmLayoutAtPoint:origin withSize:size
                     alignment:kDefaultLayoutAlignment
                     direction:layoutDirection spacing:spacing apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint *)point
               withSize:(CGSize)size
              alignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)layoutDirection
                spacing:(CGFloat)spacing
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:point
                      withSize:size
                     alignment:alignment
                     direction:layoutDirection
                       spacing:spacing
                      integral:[self.class bmDefaultLayoutIntegral]
                  ignoreTranform:[self.class bmDefaultLayoutTransformsIgnore]
                         apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint *)point
               withSize:(CGSize)size
              alignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)layoutDirection
                spacing:(CGFloat)spacing
               integral:(BOOL)integral
          ignoreTranform:(BOOL)ignoreTransform
                  apply:(BOOL)apply {

    CGPoint thePoint = (point == NULL ? CGPointZero : *point);
    CGPoint origin = thePoint;
    BMAssertBounded(origin.x);
    BMAssertBounded(origin.y);
    BMAssertBounded(size.width);
    BMAssertBounded(size.height);
    if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterHorizontally)) {
        origin.x -= size.width/2.0;
    } else if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentRight)) {
        origin.x -= size.width;
    }

    if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterVertically)) {
        origin.y -= size.height/2.0;
    } else if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentBottom)) {
        origin.y -= size.height;
    }

    CGRect theFrame = CGRectMake(origin.x, origin.y, size.width, size.height);
    if (integral) {
        theFrame = CGRectIntegral(theFrame);
    }
    if (apply) {
        [self bmSetFrame:theFrame ignoreTransform:ignoreTransform];
    }
    if (point != NULL) {
        CGPoint newPoint = thePoint;
        if (BM_CONTAINS_BIT(layoutDirection, BMViewLayoutDirectionHorizontal)) {
            if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentRight)) {
                newPoint.x -= size.width + spacing;
            } else {
                newPoint.x += size.width + spacing;
            }
        }
        if (BM_CONTAINS_BIT(layoutDirection, BMViewLayoutDirectionVertical)) {
            if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentBottom)) {
                newPoint.y -= size.height + spacing;
            } else {
                newPoint.y += size.height + spacing;
            }
        }
        *point = newPoint;
    }
    return theFrame;
}

- (CGRect)bmLayoutAtOrigin:(CGPoint)origin
                withSize:(CGSize)size
                   apply:(BOOL)apply {
    return [self bmLayoutAtOrigin:&origin withSize:size
                      direction:BMViewLayoutDirectionNone spacing:0 apply:apply];
}

- (CGRect)bmLayoutAtOrigin:(CGPoint)origin
      withConstraintSize:(CGSize)constraintSize
                   apply:(BOOL)apply {
    return [self bmLayoutAtOrigin:&origin withConstraintSize:constraintSize
                      direction:BMViewLayoutDirectionNone spacing:0 apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint)point
               withSize:(CGSize)size
              alignment:(BMViewLayoutAlignment)alignment
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:&point withSize:size alignment:alignment
                     direction:BMViewLayoutDirectionNone spacing:0 apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint)point
     withConstraintSize:(CGSize)constraintSize
              alignment:(BMViewLayoutAlignment)alignment
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:&point withConstraintSize:constraintSize alignment:alignment
                     direction:BMViewLayoutDirectionNone spacing:0 apply:apply];
}


- (CGRect)bmLayoutAtPoint:(CGPoint)point
               withSize:(CGSize)size
              alignment:(BMViewLayoutAlignment)alignment
               integral:(BOOL)integral
          ignoreTransform:(BOOL)ignoreTransform
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:&point withSize:size alignment:alignment
                     direction:BMViewLayoutDirectionNone spacing:0 integral:integral ignoreTranform:ignoreTransform apply:apply];
}

- (CGRect)bmLayoutAtPoint:(CGPoint)point
     withConstraintSize:(CGSize)constraintSize
              alignment:(BMViewLayoutAlignment)alignment
               integral:(BOOL)integral
          ignoreTransform:(BOOL)ignoreTransform
                  apply:(BOOL)apply {
    return [self bmLayoutAtPoint:&point withConstraintSize:constraintSize alignment:alignment
                     direction:BMViewLayoutDirectionNone spacing:0 integral:integral ignoreTransform:ignoreTransform apply:apply];
}

+ (CGRect)bmLayoutViews:(NSArray<UIView *>*)views atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction
                spacing:(CGFloat)spacing constraintSize:(CGSize)constraintSize apply:(BOOL)apply {
    return [self bmLayoutViews:views atPoint:point withAlignment:alignment direction:direction spacing:spacing constraintSize:constraintSize integral:[self bmDefaultLayoutIntegral] ignoreTransforms:[self bmDefaultLayoutTransformsIgnore] apply:apply];
}

+ (CGRect)bmLayoutViews:(NSArray<UIView *>*)views atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment direction:(BMViewLayoutDirection)direction
                spacing:(CGFloat)spacing constraintSize:(CGSize)constraintSize integral:(BOOL)integral ignoreTransforms:(BOOL)ignoreTransforms apply:(BOOL)apply {
    //First calculate the array of sizes for the views
    NSMutableArray *viewSizes = [[NSMutableArray alloc] initWithCapacity:views.count];

    UIView *lastView = [views lastObject];
    for (UIView *view in views) {
        CGSize viewSize = [view bmSizeThatFits:constraintSize ignoreTransform:ignoreTransforms];
        viewSize.width = MIN(ceilf(constraintSize.width), viewSize.width);
        viewSize.height = MIN(ceilf(constraintSize.height), viewSize.height);
        [viewSizes addObject:[NSValue valueWithCGSize:viewSize]];

        BOOL last = (view == lastView);

        if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionHorizontal)) {
            CGFloat increment = viewSize.width;
            if (!last) {
                increment += spacing;
            }
            constraintSize.width -= increment;
        }
        if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionVertical)) {
            CGFloat increment = viewSize.height;
            if (!last) {
                increment += spacing;
            }
            constraintSize.height -= increment;
        }
    }

    return [self bmLayoutViews:views withSizes:viewSizes atPoint:point withAlignment:alignment direction:direction spacing:spacing integral:integral ignoreTransforms:ignoreTransforms apply:apply];
}


+ (CGRect)bmLayoutViews:(NSArray<UIView *>*)views withSizes:(NSArray<NSValue *> *)viewSizes atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing apply:(BOOL)apply {
    return [self bmLayoutViews:views withSizes:viewSizes atPoint:point withAlignment:alignment direction:direction spacing:spacing integral:[self bmDefaultLayoutIntegral] ignoreTransforms:[self bmDefaultLayoutTransformsIgnore] apply:apply];
}

+ (CGRect)bmLayoutViews:(NSArray<UIView *>*)views withSizes:(NSArray<NSValue *> *)viewSizes atPoint:(CGPoint)point withAlignment:(BMViewLayoutAlignment)alignment
              direction:(BMViewLayoutDirection)direction spacing:(CGFloat)spacing integral:(BOOL)integral ignoreTransforms:(BOOL)ignoreTransforms apply:(BOOL)apply {
    CGSize totalSize = CGSizeZero;
    for (NSInteger i = 0; i < viewSizes.count; i++) {
        NSValue *viewSizeValue = viewSizes[i];
        CGSize viewSize = viewSizeValue.CGSizeValue;

        BOOL last = i == viewSizes.count - 1;
        if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionHorizontal)) {
            CGFloat increment = viewSize.width;
            if (!last) {
                increment += spacing;
            }
            totalSize.width += increment;
        }
        if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionVertical)) {
            CGFloat increment = viewSize.height;
            if (!last) {
                increment += spacing;
            }
            totalSize.height += increment;
        }
    }

    CGPoint origin = point;
    if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionHorizontal) && BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterHorizontally)) {
        //Convert to left alignment for the total of all views
        origin.x -= totalSize.width / 2.0f;
        BM_UNSET_BIT(alignment, BMViewLayoutAlignmentCenterHorizontally);
        BM_SET_BIT(alignment, BMViewLayoutAlignmentLeft);
    }
    if (BM_CONTAINS_BIT(direction, BMViewLayoutDirectionVertical) && BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterVertically)) {
        origin.y -= totalSize.height / 2.0f;
        BM_UNSET_BIT(alignment, BMViewLayoutAlignmentCenterVertically);
        BM_SET_BIT(alignment, BMViewLayoutAlignmentTop);
    }

    CGRect encompassingRect = CGRectNull;
    for (NSUInteger i = 0; i < views.count; ++i) {
        UIView *view = views[i];
        CGSize viewSize = [(NSValue *)viewSizes[i] CGSizeValue];

        CGRect rect = [view bmLayoutAtPoint:&origin withSize:viewSize alignment:alignment direction:direction spacing:spacing integral:integral ignoreTranform:ignoreTransforms apply:apply];

        if (CGRectIsNull(encompassingRect)) {
            encompassingRect = rect;
        } else {
            encompassingRect = CGRectUnion(rect, encompassingRect);
        }
    }

    return encompassingRect;
}

+ (void)_BMDidReceiveMemoryWarning:(NSNotification *)notification {
    @synchronized([UIView class]) {
        prototypes = nil;
    }
}


@end












