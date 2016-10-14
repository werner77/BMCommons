//
//  BMBusyView.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMaskView.h>

@class BMBusyView;

/**
 Delegate protocol for BMBusyView.
 */
@protocol BMBusyViewDelegate<NSObject>

/**
 Called when the busy view is cancelled.
 
 If you use the busy view for showing a service progress indication you may wish to cancel the underlying service when this event happens.
 */
- (void)busyViewWasCancelled:(BMBusyView *)view;

@optional

/**
 Support for sending the busy view (and underlying operation) to the background.
 */
- (void)busyViewWasSentToBackground:(BMBusyView *)view;

@end

typedef void (^BMBusyViewInitBlock)(BMBusyView *);

/**
 Busy view which may be used as a loading indicator, covering the entire window.
 */
@interface BMBusyView : BMMaskView

/**
 A reference to the activity indicator.
 */
@property(nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

/**
 A reference to the main text label.
 */
@property(nonatomic, readonly) UILabel *label;

/**
 A reference to the cancel label.
 */
@property(nonatomic, readonly) UILabel *cancelLabel;

/**
 A reference to the progress view.
 */
@property(nonatomic, readonly) UIProgressView *progressView;

/**
 A reference to the send to background button.
 */
@property(nonatomic, readonly) UIButton *sendToBackgroundButton;

/**
 A reference to the background view which is superview for the label, progressView, cancelLabel and activityIndicator.
 */
@property(strong, nonatomic, readonly) UIView *backgroundView;

/**
 The delegate.
 */
@property(nonatomic, weak) id <BMBusyViewDelegate> delegate;

/**
 Whether or not cancellation is enabled.
 
 If enabled the cancel label will be shown and the busy view will send a [BMBusyViewDelegate busyViewWasCancelled] to its delegate.
 Default is NO.
 */
@property(nonatomic, assign) BOOL cancelEnabled;

/**
 Whether or not send to background is enabled.
 
 If enabled the sendToBackgroundButton is shown. When this button is pressed a [BMBusyViewDelegate busyViewWasSentToBackground] message is sent to the delegate. Default is NO.
 */
@property(nonatomic, assign) BOOL sendToBackgroundEnabled;

/**
 If set to YES the progressbar will animate with a pulsing alpha value to show it's busy even while progress is not going fast.
 
 Default is NO.
 */
@property(nonatomic, assign) BOOL pulsingProgressBar;

/**
 The duration to use for fading in/out the busy view when showing or hiding animated.
 
 Default is 0.2 seconds
 */
@property(nonatomic, assign) NSTimeInterval fadeDuration;

/**
 Initializer with the specified super view.
 
 This is the designated initializer. init calls this method with as argument a new modal window with windowLevel of UIWindowLevelStatusBar.
 */
- (id)initWithSuperView:(UIView *)view;

/**
 Sets the progress with a value between 0.0 and 1.0.
 
 If not shown, calling this method will show the progress indicator.
 */
- (void)setProgress:(CGFloat)progress;

/**
 Sets the message for the busy view.
 
 Default is "Loading..."
 */
- (void)setMessage:(NSString *)message;

/**
 The text to display for tap to cancel.
 
 Default is "Tap to cancel"
 */
- (void)setCancelMessage:(NSString *)message;

/**
 Shows the busy view with optional fade in animation.
 */
- (void)showAnimated:(BOOL)animated;

/**
 Hides the busy view with optional fade out animation.
 */
- (void)hideAnimated:(BOOL)animated;

/**
 Whether the busy view is currently shown or not.
 */
- (BOOL)isShown;


/**
 @name Static utility methods for a shared busy view.
 */

+ (BMBusyView *)showBusyViewAnimated:(BOOL)animated cancelEnabled:(BOOL)cancelEnabled;
+ (BMBusyView *)showBusyView;
+ (BMBusyView *)showBusyViewAnimated:(BOOL)animated;
+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message;
+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message animated:(BOOL)animated progress:(CGFloat)progress initBlock:(BMBusyViewInitBlock)initBlock;
+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message animated:(BOOL)animated;
+ (BMBusyView *)showBusyViewWithMessage:(NSString *)message andProgress:(CGFloat)progress;

/**
 A reference to the shared busy view.
 
 Returns nil if no busy view is shown at the moment.
 */
+ (BMBusyView *)sharedBusyView;

/**
 Default initializer block which is called just before the sharedBusyView is shown.
 */
+ (void)setDefaultInitBlock:(BMBusyViewInitBlock)block;

/**
 Hides the sharedBusyView with animation.
 */
+ (void)hideBusyView;
+ (void)hideBusyViewAnimated:(BOOL)animated;

@end
