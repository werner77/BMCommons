//
//  BMBusyView.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMBusyView.h>
#import <QuartzCore/QuartzCore.h>
#import <BMCommons/UIButton+BMCommons.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/UIScreen+BMCommons.h>

#define BACKGROUND_VIEW_TAG 100
#define SEND_TO_BACKGROUND_BUTTON_TAG 101

#define FADE_DURATION 0.3

@interface BMBusyView(Private) 

- (void)performProgressBarAnimation;
- (void)startProgressBarAnimation;
- (void)stopProgressBarAnimation;
- (void)onSendToBackground:(UIButton *)sender;

@end

@implementation BMBusyView {
	UIActivityIndicatorView *activityIndicator;
	UILabel *cancelLabel;
	UILabel *label;
	UIProgressView *progressView;
	BOOL cancelEnabled;
    BOOL animateProgressBar;
    BOOL sendToBackgroundEnabled;
    UIButton *sendToBackgroundButton;
    UIWindow *oldKeyWindow;
}

@synthesize activityIndicator, label, cancelLabel, progressView, delegate, cancelEnabled, sendToBackgroundEnabled, sendToBackgroundButton, pulsingProgressBar;

static BMBusyView *sharedBusyView = nil;
static BMBusyViewInitBlock defaultInitBlock = nil;
static __weak UIView *defaultSuperview;

+ (UIView *)defaultSuperview {
    return defaultSuperview ?: [UIApplication sharedApplication].keyWindow;
}

+ (void)setDefaultSuperview:(UIView *)view {
    defaultSuperview = view;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(activityIndicator);
    BM_RELEASE_SAFELY(label);
    BM_RELEASE_SAFELY(cancelLabel);
    BM_RELEASE_SAFELY(progressView);
    BM_RELEASE_SAFELY(sendToBackgroundButton);
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.alpha = 0.0;
        self.fadeDuration = FADE_DURATION;
		self.contentMode = UIViewContentModeScaleToFill;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(30, 0, 260, 100)];
        bgView.tag = BACKGROUND_VIEW_TAG;
		bgView.layer.cornerRadius = 8;
		bgView.clipsToBounds = YES;
        
		[bgView setBackgroundColor:BMSTYLEVAR(busyViewBackgroundColor)];
		[bgView setAlpha:0.75f];
		
		bgView.contentMode = UIViewContentModeCenter;
		bgView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | 
									UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		//Activity indicator
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:BMSTYLEVAR(busyViewActivityIndicatorStyle)];
		self.activityIndicator.hidesWhenStopped = YES;
		self.activityIndicator.center = CGPointMake(bgView.frame.size.width/2, 20);
		
		//Label
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, bgView.frame.size.width, 20)];
		self.label.backgroundColor = [UIColor clearColor];
        self.label.text = BMUICoreLocalizedString(@"busyview.title", @"Loading...");
		self.label.textColor = BMSTYLEVAR(busyViewTitleLabelTextColor);
		self.label.textAlignment = NSTextAlignmentCenter;
		[self.label setFont:[UIFont boldSystemFontOfSize:17]];
        
        cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, bgView.frame.size.width, 20)];
        self.cancelLabel.backgroundColor = [UIColor clearColor];
		self.cancelLabel.textColor = BMSTYLEVAR(busyViewCancelLabelTextColor);
		self.cancelLabel.textAlignment = NSTextAlignmentCenter;
        self.cancelLabel.text = BMUICoreLocalizedString(@"busyview.message", @"Tap to cancel");
		[self.cancelLabel setFont:[UIFont boldSystemFontOfSize:12]];
		
		//ProgressView
		progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		self.progressView.hidden = YES;
		self.progressView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | 
											UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin; 
		self.progressView.center = CGPointMake(bgView.frame.size.width/2, 20);
        
        sendToBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendToBackgroundButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        UIImage *bgImage = BMSTYLEVAR(busyViewSendToBackgroundButtonImage);
        bgImage = [bgImage stretchableImageWithLeftCapWidth:(int)(bgImage.size.width/2) topCapHeight:(int)(bgImage.size.height/2)];

        [sendToBackgroundButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        sendToBackgroundButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        sendToBackgroundButton.tag = SEND_TO_BACKGROUND_BUTTON_TAG;
        CGFloat buttonWidth = 150;
        CGFloat buttonHeight = 30;
        [sendToBackgroundButton setFrame:CGRectMake(0,0, buttonWidth, buttonHeight)];
        [sendToBackgroundButton setTitle:BMUICoreLocalizedString(@"busyview.sendtobackgroundbutton.title", @"Continue in background") forState:UIControlStateNormal];
        [sendToBackgroundButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendToBackgroundButton bmSetTarget:self action:@selector(onSendToBackground:)];
				
		CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
		bgView.center = centerPoint;
		[bgView addSubview:label];
        [bgView addSubview:cancelLabel];
		[bgView addSubview:activityIndicator];
		[bgView addSubview:progressView];
        [self addSubview:bgView];
        
        sendToBackgroundButton.center = CGPointMake(bgView.center.x, CGRectGetMaxY(bgView.frame) + 30);
        [self addSubview:sendToBackgroundButton];
        
        self.cancelEnabled = NO;
        self.sendToBackgroundEnabled = NO;
		
		[bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)]];
	}
	return self;
}

- (UIView *)backgroundView {
    return [self viewWithTag:BACKGROUND_VIEW_TAG];
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0.0) {
        self.progressView.hidden = YES;
    } else {
        progress = MAX(progress, 0.01);
        self.progressView.hidden = NO;
        self.activityIndicator.hidden = YES;
        self.progressView.progress = progress;
        if (self.pulsingProgressBar) {
            [self startProgressBarAnimation];
        }
    }
}

- (void)showAnimated:(BOOL)animated inView:(UIView *)superView {
    if (![self isShown]) {
        BM_RELEASE_SAFELY(oldKeyWindow);
        if ([superView isKindOfClass:[UIWindow class]]) {
            oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
            if (oldKeyWindow != superView) {
                [(UIWindow *)superView makeKeyAndVisible];
            } else {
                oldKeyWindow = nil;
            }
        }
        
        [superView addSubview:self];
        [activityIndicator startAnimating];
        if (animated) {
            self.alpha = 0.0f;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:self.fadeDuration];
        }
        [super show];
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)remove {
    [self removeFromSuperview];
    if (oldKeyWindow) {
        [oldKeyWindow makeKeyWindow];
    }
    BM_RELEASE_SAFELY(oldKeyWindow);
}

- (BOOL)isShown {
    return [self superview] != nil;
}

- (void)hideAnimated:(BOOL)animated {
    [self stopProgressBarAnimation];
    
    if ([self isShown]) {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:self.fadeDuration];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        }
        [super hide];
        if (animated) {
            [UIView commitAnimations];
        } else {
            [self remove];
        }
    }
}

- (void)viewWasTapped:(id)sender {
	if (self.cancelEnabled) {
		[self.delegate busyViewWasCancelled:self];
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqual:@"PulseProgressBar"]) {
        [self performProgressBarAnimation];
    } else {
        [activityIndicator stopAnimating];
        [self remove];
    }
}

- (void)setCancelEnabled:(BOOL)enabled {
    self.cancelLabel.hidden = !enabled;
    cancelEnabled = enabled;
}

- (void)setSendToBackgroundEnabled:(BOOL)enabled {
    self.sendToBackgroundButton.hidden = !enabled;
    sendToBackgroundEnabled = enabled;
}

- (void)setMessage:(NSString *)message {
    self.label.text = message;
}

- (void)setCancelMessage:(NSString *)message {
    self.cancelLabel.text = message;
}

#pragma mark - Static methods

+ (BMBusyView *)showBusyViewAnimated:(BOOL)animated cancelEnabled:(BOOL)cancelEnabled {
    BMBusyView *bv = [self showBusyViewAnimated:animated];
    bv.cancelEnabled = cancelEnabled;
    return bv;
}

+ (BMBusyView *)showBusyView {
    return [self showBusyViewAnimated:YES];
}

+ (BMBusyView *)showBusyViewAnimated:(BOOL)animated {
    return [self showBusyViewWithMessage:BMUICoreLocalizedString(@"busyview.title", @"Loading...") animated:animated progress:-1.0 initBlock:defaultInitBlock];
}

+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message {
    return [self showBusyViewWithMessage:message animated:YES progress:-1.0 initBlock:defaultInitBlock];
}

+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message animated:(BOOL)animated {
    return [self showBusyViewWithMessage:message animated:animated progress:-1.0 initBlock:defaultInitBlock];
}

+ (void)setDefaultInitBlock:(BMBusyViewInitBlock)block {
    defaultInitBlock = [block copy];
}

+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message animated:(BOOL)animated progress:(CGFloat)progress initBlock:(BMBusyViewInitBlock)initBlock {
    if (!sharedBusyView) {
		sharedBusyView = [[BMBusyView alloc] init];
        if (initBlock) {
            initBlock(sharedBusyView);
        }
		[sharedBusyView showAnimated:animated inView:[self defaultSuperview]];
	}
    [sharedBusyView setMessage:message];
    [sharedBusyView setProgress:progress];
	return sharedBusyView;
}

+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message andProgress:(CGFloat)progress {
    if (message == nil) {
        message = sharedBusyView.label.text;
    }
    BMBusyView *bv = [self showBusyViewWithMessage:message];
	[bv setProgress:progress];
	return bv;
}

+ (BMBusyView *)sharedBusyView {
    return sharedBusyView;
}

+ (void)hideBusyView {
	[self hideBusyViewAnimated:YES];
}

+ (void)hideBusyViewAnimated:(BOOL)animated {
	if (sharedBusyView) {
		[sharedBusyView hideAnimated:animated];
		BM_RELEASE_SAFELY(sharedBusyView);
	}
}

@end

@implementation BMBusyView(Private) 

- (void)performProgressBarAnimation {
    if (animateProgressBar) {
        float destAlpha = progressView.alpha > 0.85 ? 0.7 : 1.0;
        
        [UIView beginAnimations:@"PulseProgressBar" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        progressView.alpha = destAlpha;
        [UIView commitAnimations];    
    }
}

- (void)startProgressBarAnimation {
    if (!animateProgressBar) {
        animateProgressBar = YES;
        [self performProgressBarAnimation];    
    }
}

- (void)stopProgressBarAnimation {
    animateProgressBar = NO;
}

- (void)onSendToBackground:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(busyViewWasSentToBackground:)]) {
        [self.delegate busyViewWasSentToBackground:self];
    }
}

@end
