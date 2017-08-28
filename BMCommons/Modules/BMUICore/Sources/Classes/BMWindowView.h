//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMWindowView : UIView

@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations;

@property (nullable, nonatomic, copy) void (^onDidMoveToWindow)(void);
@property (nullable, nonatomic, copy) void (^onDidMoveOutOfWindow)(void);
@property (nonatomic, assign) BOOL onlySubviewsCapturesTouch;

- (id)initWithWindow:(nullable UIWindow *)window;
- (id)initWithKeyWindow;

- (void)addToWindow:(nullable UIWindow *)window;

- (void)addSubViewAndKeepSamePosition:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view withSlideUpAnimationOnDone:(void(^ _Nullable)(void))onDone;
- (void)fadeOutAndRemoveFromSuperview:(void(^ _Nullable)(void))onDone;
- (void)slideDownSubviewsAndRemoveFromSuperview:(void(^ _Nullable)(void))onDone;

- (void)bringToFront;
- (BOOL)isInFront;

+ (NSArray *)allActiveWindowViews;
+ (nullable BMWindowView *)firstActiveWindowViewPassingTest:(BOOL (^)(BMWindowView *windowView, BOOL *stop))test;
+ (nullable BMWindowView *)activeWindowViewContainingView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END


