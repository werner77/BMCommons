//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMWindowView.h"


static CGFloat UIInterfaceOrientationAngleBetween(UIInterfaceOrientation o1, UIInterfaceOrientation o2);
static CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation);
static UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);


static NSMutableArray *_activeWindowViews;

@interface BMWindowView ()

@end

@implementation BMWindowView

#pragma mark - Lifecycle

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _activeWindowViews = [[NSMutableArray alloc] init];
    });
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initAndAddToWindow:(UIWindow *)window
{
    self = [self initWithFrame:CGRectZero];
    if(self)
    {
        [window addSubview:self];
    }
    return self;
}

- (id)initAndAddToKeyWindow
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self = [self initAndAddToWindow:window];
    if(self)
    {
    }
    return self;
}

- (void)setup
{
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - Handling

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    _supportedInterfaceOrientations = supportedInterfaceOrientations;

    if(self.window != nil)
    {
        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    }
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    /*
     This notification is most likely triggered inside an animation block,
     therefore no animation is needed to perform this nice transition.
     */
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations
{
    UIInterfaceOrientation orientation = [self desiredOrientation];
    CGFloat statusBarHeight = [[self class] getStatusBarHeight];
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;

    CGFloat angle = 0.0;

#ifdef __IPHONE_8_0
    BOOL relativeRotation = IS_IOS_8_OR_HIGHER();
#else
    BOOL relativeRotation = NO;
#endif

    if (relativeRotation)
    {
        angle = UIInterfaceOrientationAngleBetween(orientation, statusBarOrientation);
    }
    else
    {
        angle = UIInterfaceOrientationAngleOfOrientation(orientation);
    }

    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect frame = [[self class] rectInWindowBounds:self.window.bounds statusBarOrientation:statusBarOrientation statusBarHeight:statusBarHeight];

    [self setIfNotEqualTransform:transform frame:frame];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame
{
    if(!CGAffineTransformEqualToTransform(self.transform, transform))
    {
        self.transform = transform;
    }
    if(!CGRectEqualToRect(self.frame, frame))
    {
        self.frame = frame;
    }
}

+ (CGFloat)getStatusBarHeight
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    else
    {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

static BOOL IS_BELOW_IOS_7()
{
    static BOOL answer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        answer = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0;
    });
    return answer;
}

static BOOL IS_IOS_8_OR_HIGHER()
{
    static BOOL answer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        answer = floor([[[UIDevice currentDevice] systemVersion] floatValue]) >= 8.0;
    });
    return answer;
}

+ (CGRect)rectInWindowBounds:(CGRect)windowBounds statusBarOrientation:(UIInterfaceOrientation)statusBarOrientation statusBarHeight:(CGFloat)statusBarHeight
{
    CGRect frame = windowBounds;

    if(IS_BELOW_IOS_7())
    {
        frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
        frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
        frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
        frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
    }
    return frame;
}

- (UIInterfaceOrientation)desiredOrientation
{
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
    if(self.supportedInterfaceOrientations & statusBarOrientationAsMask)
    {
        return statusBarOrientation;
    }
    else
    {
        if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait)
        {
            return UIInterfaceOrientationPortrait;
        }
        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft)
        {
            return UIInterfaceOrientationLandscapeLeft;
        }
        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight)
        {
            return UIInterfaceOrientationLandscapeRight;
        }
        else
        {
            return UIInterfaceOrientationPortraitUpsideDown;
        }
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];

    if(self.window == nil)
    {
        self.onDidMoveOutOfWindow ? self.onDidMoveOutOfWindow() : nil;
        [_activeWindowViews removeObject:self];
    }
    else
    {
        [self assertCorrectHirearchy];
        self.onDidMoveToWindow ? self.onDidMoveToWindow() : nil;
        [_activeWindowViews addObject:self];
        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    }
}


- (void)assertCorrectHirearchy
{
    if(self.window != nil)
    {
        if(self.superview != self.window)
        {
            [NSException raise:NSInternalInconsistencyException format:@"BMWindowView should only be added directly on UIWindow"];
        }
        if([self.window.subviews indexOfObject:self] == 0)
        {
            [NSException raise:NSInternalInconsistencyException format:@"BMWindowView is not meant to be first subview on window since UIWindow automatically rotates the first view for you."];
        }
    }
}

#pragma mark - Hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self && self.onlySubviewsCapturesTouch)
    {
        return nil;
    }
    return hitView;
}

#pragma mark - Presentation

- (void)addSubViewAndKeepSamePosition:(UIView *)view
{
    if(view.superview == nil)
    {
        [NSException raise:NSInternalInconsistencyException format:@"When calling %s we are expecting the view to be moved is already in a view hierarchy.", __PRETTY_FUNCTION__];
    }

    view.frame = [view convertRect:view.bounds toView:self];
    [self addSubview:view];
}

- (void)addSubviewAndFillBounds:(UIView *)view
{
    view.frame = [self bounds];
    [self addSubview:view];
}

- (void)addSubviewAndFillBounds:(UIView *)view withSlideUpAnimationOnDone:(void(^)(void))onDone
{
    CGRect endFrame = [self bounds];
    CGRect startFrame = endFrame;
    startFrame.origin.y += startFrame.size.height;

    view.frame = startFrame;
    [self addSubview:view];

    [UIView animateWithDuration:0.4 animations:^{
        view.frame = endFrame;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        self.opaque = YES;
    } completion:^(BOOL finished) {
        if(onDone)
        {
            onDone();
        }
    }];
}

- (void)fadeOutAndRemoveFromSuperview:(void(^)(void))onDone
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(onDone)
        {
            onDone();
        }
    }];
}

- (void)slideDownSubviewsAndRemoveFromSuperview:(void(^)(void))onDone
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    self.opaque = YES;

    [UIView animateWithDuration:0.4 animations:^{

        for(UIView *subview in [self subviews])
        {
            CGRect frame = subview.frame;
            frame.origin.y += self.bounds.size.height;
            subview.frame = frame;
        }

        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(onDone)
        {
            onDone();
        }
    }];
}

- (void)bringToFront
{
    [self.superview bringSubviewToFront:self];
}

- (BOOL)isInFront
{
    NSArray *subviewsOnSuperview = [self.superview subviews];
    NSUInteger index = [subviewsOnSuperview indexOfObject:self];
    return index == subviewsOnSuperview.count - 1;
}

#pragma mark - Convenience methods

+ (NSArray *)allActiveWindowViews
{
    return _activeWindowViews;
}

+ (BMWindowView *)firstActiveWindowViewPassingTest:(BOOL (^)(BMWindowView *windowView, BOOL *stop))test
{
    __block BMWindowView *hit = nil;
    [_activeWindowViews enumerateObjectsUsingBlock:^(BMWindowView *windowView, NSUInteger idx, BOOL *stop) {
        if(test(windowView, stop))
        {
            hit = windowView;
        }
    }];
    return hit;
}

+ (BMWindowView *)activeWindowViewContainingView:(UIView *)view
{
    return [self firstActiveWindowViewPassingTest:^BOOL(BMWindowView *windowView, BOOL *stop) {
        return [view isDescendantOfView:windowView];
    }];
}

@end


static CGFloat UIInterfaceOrientationAngleBetween(UIInterfaceOrientation o1, UIInterfaceOrientation o2)
{
    CGFloat angle1 = UIInterfaceOrientationAngleOfOrientation(o1);
    CGFloat angle2 = UIInterfaceOrientationAngleOfOrientation(o2);

    return angle1 - angle2;
}

static CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
{
    CGFloat angle;
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    return angle;
}

static UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
{
    return 1 << orientation;
}
