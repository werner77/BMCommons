//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMAlertView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notifications posted upon showing/dismissing an alert.
 */
extern NSString * const BMAlertViewShownNotification;
extern NSString * const BMAlertViewDismissedNotification;

@interface BMAlertController : NSObject

BM_DECLARE_DEFAULT_SINGLETON

/**
 Sub class of BMAlertView which is used for alerts.

 Defaults to BMDefaultAlertView, can be set to a sub class for custom styling.
 */
@property (nonatomic, assign) Class alertViewClass;

/**
 * Background color for the window when the alert is shown.
 *
 * Default is black with alpha value of 0.4.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 * If set this value transformer is used to convert a NSString title to a NSAttributedString version to provide rich text.
 *
 * Defaults to a BMAttributedStringTransformer with bold system font and black text color.
 */
@property (nullable, nonatomic, strong) NSValueTransformer *attributedTitleTransformer;

/**
 * If set this value transformer is used to convert a NSString message to a NSAttributedString version to provide rich text.
 *
 * * Defaults to a BMAttributedStringTransformer with normal system font and black text color.
 */
@property (nullable, nonatomic, strong) NSValueTransformer *attributedMessageTransformer;

/**
 * Show an alert with the specified title, message, cancelButtonTitle and other button titles.
 * Calls the specified dismissBlock upon dismissal.
 * If duration > 0 the alert is automatically dismissed with the cancelButton after the specified interval.
 *
 * Alert will be queued if another alert is already visible at the moment.
 */
- (BMAlertView *)showAlertWithAttributedTitle:(nullable NSAttributedString *)title attributedMessage:(nullable NSAttributedString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex duration:(CGFloat)duration dismissBlock:(nullable BMAlertDismissBlock)dismissBlock;

/**
 * Overloaded version: uses the attributedTitleTransformer and attributedMessageTransformer to convert NSString to NSAttributedString.
 *
 * @see showAlertWithAttributedTitle:attributedMessage:cancelButtonTitle:otherButtonTitles:cancelButtonIndex:duration:dismissBlock:
 */
- (BMAlertView *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex duration:(CGFloat)duration dismissBlock:(nullable BMAlertDismissBlock)dismissBlock;

/**
 * Overloaded version: uses the attributedTitleTransformer and attributedMessageTransformer to convert NSString to NSAttributedString. Uses infinite duration (no automatic dismissal). cancelButtonIndex is defaulted to first button.
 *
 * @see showAlertWithAttributedTitle:attributedMessage:cancelButtonTitle:otherButtonTitles:cancelButtonIndex:duration:dismissBlock:
 */
- (BMAlertView *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles dismissBlock:(nullable BMAlertDismissBlock)dismissBlock;

/**
 * Overloaded version: uses the attributedTitleTransformer and attributedMessageTransformer to convert NSString to NSAttributedString. No buttons version.
 *
 * @see showAlertWithAttributedTitle:attributedMessage:cancelButtonTitle:otherButtonTitles:cancelButtonIndex:duration:dismissBlock:
 */
- (BMAlertView *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message duration:(NSTimeInterval)duration dismissBlock:(nullable BMAlertDismissBlock)dismissBlock;

/**
 * Overloaded version: uses the attributedTitleTransformer and attributedMessageTransformer to convert NSString to NSAttributedString. Uses infinite duration (no automatic dismissal).
 *
 * @see showAlertWithAttributedTitle:attributedMessage:cancelButtonTitle:otherButtonTitles:cancelButtonIndex:duration:dismissBlock:
 */
- (BMAlertView *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles cancelButtonIndex:(NSInteger)cancelButtonIndex dismissBlock:(nullable BMAlertDismissBlock)dismissBlock;

/**
 * Returns true iff an alert is currently visible.
 */
- (BOOL)isAlertBeingPresented;

/**
 * Returns true iff alerts are blocked at the moment (alerts will be queued untill the block has been removed).
 */
- (BOOL)isBlocked;

/**
 * Pushes an object responsible for blocking the presentation of alerts
 *
 * @see isBlocked
 */
- (void)pushBlocker:(id)blocker;

/**
 * Pops an object responsible for blocking the presentation of alerts
 *
 * @see isBlocked
 */
- (void)popBlocker:(id)blocker;

@end

@interface BMAlertController(Protected)

/**
 * Override for custom presentation animation logic
 */
- (void)presentDialog:(BMAlertView *)dialogView inView:(UIView *)parentView withCompletion:(void (^ _Nullable)(BOOL finished))completion;

/**
 * Override for custom animation hiding logic
 */
- (void)hideDialog:(BMAlertView *)dialogView withCompletion:(void (^ _Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END