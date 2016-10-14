//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMAlertView;

/**
 * Dismissblock
 */
typedef void(^BMAlertDismissBlock)(BMAlertView *alertView, NSInteger buttonIndex);

/**
 * Super class for AlertView implementations. Override to provide custom alert styling.
 */
@interface BMAlertView : UIView

/**
 * Titles for the buttons to display
 */
@property (nonatomic, strong) NSArray *buttonTitles;

/**
 * The index for the cancel button
 */
@property (nonatomic, assign) NSInteger cancelButtonIndex;

/**
 * The attributed title for the alert
 */
@property (nonatomic, strong) NSAttributedString *title;

/**
 * The attributed message for the alert
 */
@property (nonatomic, strong) NSAttributedString *message;

/**
 * If set to a positive interval the alert will call dismiss automatically after the specified interval.
 */
@property (nonatomic, assign) NSTimeInterval automaticDismissDelay;

/**
 * The block to be called upon dismiss
 */
@property (copy) BMAlertDismissBlock dismissBlock;

- (instancetype)initWithTitle:(NSAttributedString *)title
                      message:(NSAttributedString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles;

- (instancetype)initWithTitle:(NSAttributedString *)title
                      message:(NSAttributedString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
            cancelButtonIndex:(NSInteger)cancelButtonIndex;

/**
 * Calls the dismissBlock with the specified buttonIndex.
 */
- (void)dismissWithButtonIndex:(NSInteger)buttonIndex;

/**
 * Calls dismissWithButtonIndex: with the cancelButtonIndex.
 */
- (void)dismiss;

/**
 * Call to notify that the view needs to be reconfigured due to changes in properties.
 *
 * Is called automatically for title, message and button changes.
 *
 * @see configureView
 */
- (void)setNeedsConfiguration;

/**
 * Configures the view immediately if setNeedsConfiguration was called.
 *
 * @see configureView
 */
- (void)configureViewIfNeeded;

@end

@interface BMAlertView (Protected)

/**
 * Provide a meaningful implementation to configure the view for the current title/message/buttons.
 */
- (void)configureView;

@end