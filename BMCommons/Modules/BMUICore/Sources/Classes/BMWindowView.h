//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BMWindowView : UIView

@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations;

@property (nonatomic, copy) void (^onDidMoveToWindow)(void);
@property (nonatomic, copy) void (^onDidMoveOutOfWindow)(void);
@property (nonatomic, assign) BOOL onlySubviewsCapturesTouch;

- (id)initAndAddToWindow:(UIWindow *)window;
- (id)initAndAddToKeyWindow;

- (void)addSubViewAndKeepSamePosition:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view withSlideUpAnimationOnDone:(void(^)(void))onDone;
- (void)fadeOutAndRemoveFromSuperview:(void(^)(void))onDone;
- (void)slideDownSubviewsAndRemoveFromSuperview:(void(^)(void))onDone;

- (void)bringToFront;
- (BOOL)isInFront;

+ (NSArray *)allActiveWindowViews;
+ (BMWindowView *)firstActiveWindowViewPassingTest:(BOOL (^)(BMWindowView *windowView, BOOL *stop))test;
+ (BMWindowView *)activeWindowViewContainingView:(UIView *)view;

@end


