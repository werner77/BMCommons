//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAlertController.h>
#import <BMCommons/BMBooleanStack.h>
#import <BMCommons/BMAlertView.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMDefaultAlertView.h>
#import <BMCommons/BMWindowView.h>
#import <BMCommons/BMAttributedStringTransformer.h>

@implementation BMAlertController {
    BMBooleanStack *_blockedStack;
    UIView *_parentView;
}

NSString * const BMAlertViewShownNotification = @"BMAlertViewShownNotification";
NSString * const BMAlertViewDismissedNotification = @"BMAlertViewDismissedNotification";

BM_SYNTHESIZE_DEFAULT_SINGLETON

static NSMutableArray *alertQueue = nil;
static BMAlertView __weak *currentAlertView = nil;

static const CGFloat kIOS7MotionEffectExtent = 10.0;
static const CGFloat kHorizontalPadding = 30.0f;

- (id)init {
    if ((self = [super init])) {
        self.alertViewClass = [BMDefaultAlertView class];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        BMAttributedStringTransformer *transformer = [[BMAttributedStringTransformer alloc] init];
        transformer.font = [UIFont boldSystemFontOfSize:17.0f];
        transformer.textColor = [UIColor blackColor];
        self.attributedTitleTransformer = transformer;

        transformer = [[BMAttributedStringTransformer alloc] init];
        transformer.font = [UIFont systemFontOfSize:17.0f];
        transformer.textColor = [UIColor blackColor];
        self.attributedMessageTransformer = transformer;
    }
    return self;
}

- (BMAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles dismissBlock:(BMAlertDismissBlock)dismissBlock {
    return [self showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles cancelButtonIndex:0 duration:0.0 dismissBlock:dismissBlock];
}

- (BMAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex dismissBlock:(BMAlertDismissBlock)dismissBlock {
    return [self showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles cancelButtonIndex:cancelButtonIndex duration:0.0 dismissBlock:dismissBlock];
}

- (BMAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex duration:(CGFloat)duration dismissBlock:(BMAlertDismissBlock)dismissBlock {

    NSAttributedString *attributedTitle = [self attributedStringFromString:title withTransformer:self.attributedTitleTransformer];
    NSAttributedString *attributedMessage = [self attributedStringFromString:message withTransformer:self.attributedMessageTransformer];

    return [self showAlertWithAttributedTitle:attributedTitle attributedMessage:attributedMessage cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles cancelButtonIndex:cancelButtonIndex duration:duration dismissBlock:dismissBlock];
}

- (NSAttributedString *)attributedStringFromString:(NSString *)string withTransformer:(NSValueTransformer *)transformer {
    NSAttributedString *attributedString = nil;
    if (string != nil) {
        if (transformer != nil) {
            attributedString = [transformer transformedValue:string];
        } else {
            attributedString = [[NSAttributedString alloc] initWithString:string];
        }
    }
    return attributedString;
}

- (BMAlertView *)showAlertWithAttributedTitle:(NSAttributedString *)title attributedMessage:(NSAttributedString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex duration:(CGFloat)duration dismissBlock:(BMAlertDismissBlock)dismissBlock {
    // Custom

    __weak BMAlertController *weakSelf = self;

    BMAlertView *alert = [(id)[self.alertViewClass alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles cancelButtonIndex:cancelButtonIndex];
    alert.dismissBlock = ^(BMAlertView *alertView, NSInteger clickedButtonIndex) {

        [weakSelf hideAlert:alertView withCompletion:^(BOOL finished) {
            currentAlertView = nil;
            [weakSelf dequeueAlert];
        }];

        if (dismissBlock) {
            dismissBlock(alertView, clickedButtonIndex);
        }
    };
    alert.automaticDismissDelay = duration;
    [self queueAlert:alert];
    return alert;
}

- (BMAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration dismissBlock:(BMAlertDismissBlock)dismissBlock {
    return [self showAlertWithTitle:title message:message cancelButtonTitle:nil otherButtonTitles:nil cancelButtonIndex:0 duration:duration dismissBlock:dismissBlock];
}

- (void)queueAlert:(BMAlertView *)alertView {
    if (alertQueue == nil) {
        alertQueue = [NSMutableArray new];
    }
    [alertQueue addObject:alertView];
    [self dequeueAlert];
}

- (void)dequeueAlert {
    if (![self isAlertBeingPresented] && ![self isBlocked]) {
        BMAlertView *alert = [alertQueue firstObject];
        if (alert) {
            [alertQueue removeObjectAtIndex:0];
            [self showAlert:alert withCompletion:nil];
            currentAlertView = alert;
        }
    }
}

- (BOOL)isAlertBeingPresented {
    return currentAlertView != nil;
}

- (BOOL)isBlocked {
    return _blockedStack.state;
}

- (void)pushBlocker:(id)blocker {
    if (_blockedStack == nil) {
        _blockedStack = [BMBooleanStack new];
        [_blockedStack setShouldAutomaticallyCleanupStatesForDeallocatedOwners:YES];
    }
    [_blockedStack pushState:YES forOwner:blocker];
}

- (void)popBlocker:(id)blocker {
    [_blockedStack popStateForOwner:blocker];

    if (![self isBlocked]) {
        //Continue with queued transitions
        [self dequeueAlert];
    }
}

- (void)showAlert:(BMAlertView *)alertView withCompletion:(void (^)(BOOL finished))completion
{
    UIView *parentView = [self parentView];
    UIView *alertBackgroundView = [[UIView alloc] initWithFrame:parentView.bounds];
    alertBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    alertBackgroundView.backgroundColor = [UIColor clearColor];
    [parentView addSubview:alertBackgroundView];
    [alertView configureViewIfNeeded];
    [self presentDialog:alertView inView:alertBackgroundView withCompletion:completion];
    [[NSNotificationCenter defaultCenter] postNotificationName:BMAlertViewShownNotification object:self];
}

- (void)hideAlert:(BMAlertView *)alertView withCompletion:(void (^)(BOOL finished))completion {
    BMAlertController __weak *weakSelf = self;
    [self hideDialog:alertView withCompletion:^void(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BMAlertViewDismissedNotification object:weakSelf];
        [weakSelf destroyParentView];
        if (completion) {
            completion(finished);
        }
    }];
}

- (UIView *)parentView {
    if (_parentView == nil) {
        _parentView = [[BMWindowView alloc] initAndAddToKeyWindow];
    }
    return _parentView;
}

- (void)destroyParentView {
    [_parentView removeFromSuperview];
    _parentView = nil;
}

- (void)applyMotionEffectsToView:(UIView *)dialogView
{
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}

- (void)presentDialog:(BMAlertView *)dialogView inView:(UIView *)parentView withCompletion:(void (^)(BOOL finished))completion {

    dialogView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);

    [self applyMotionEffectsToView:dialogView];
    [parentView addSubview:dialogView];

    CGSize dialogSize = [dialogView sizeThatFits:CGSizeMake(parentView.bounds.size.width - 2 * kHorizontalPadding, CGFLOAT_MAX)];
    dialogView.bounds = BMRectMakeIntegral(0, 0, dialogSize.width, dialogSize.height);
    dialogView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);

    BMAlertController *__weak weakSelf = self;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         parentView.backgroundColor = weakSelf.backgroundColor;
                         dialogView.layer.opacity = 1.0f;
                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }
    ];
}

- (void)hideDialog:(BMAlertView *)dialogView withCompletion:(void (^)(BOOL finished))completion {

    UIView *parentView = dialogView.superview;

    CATransform3D currentTransform = dialogView.layer.transform;
    CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

    dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    dialogView.layer.opacity = 1.0f;

    [UIView
            animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         parentView.backgroundColor = [UIColor clearColor];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.8f, 0.8f, 1.0));
                         dialogView.layer.opacity = 0.0f;
                     } completion:^(BOOL finished) {
                [dialogView removeFromSuperview];
                if (completion) {
                    completion(finished);
                }
            }];
}

@end
