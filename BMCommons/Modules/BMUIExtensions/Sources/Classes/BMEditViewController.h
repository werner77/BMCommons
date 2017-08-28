/*
 *  BMEditViewController.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 12/10/10.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */

NS_ASSUME_NONNULL_BEGIN

@class BMPropertyDescriptor;

@protocol BMEditViewControllerDelegate;

/**
 * Protocol for view controllers that support a modal style of editing (OK/Cancel)
 */
@protocol BMEditViewController<NSObject, NSCoding>

/**
 * Delegate for receiving cancel and commit events.
 */
@property (nullable, nonatomic, weak) id <BMEditViewControllerDelegate> delegate;

@end

/**
 Delegate that should respond to the EditViewController's selection of value or cancellation.
 */
@protocol BMEditViewControllerDelegate<NSObject>

- (void)editViewController:(id <BMEditViewController>)vc didSelectValue:(nullable id)value;
- (void)editViewControllerWasCancelled:(id <BMEditViewController>)vc;

@end

NS_ASSUME_NONNULL_END