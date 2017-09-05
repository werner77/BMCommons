//
// Created by Werner Altewischer on 08/04/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BMGestureRecognizerTargetBlock)(UIGestureRecognizer *gr);

@interface UIGestureRecognizer (BMCommons)

/**
 * Sets the specified block as target for the gesture recognizer event.
 */
- (void)bmSetTargetBlock:(nullable BMGestureRecognizerTargetBlock)block;

/**
 * Cancels any currently recognized gesture
 */
- (void)bmCancel;

@end

NS_ASSUME_NONNULL_END