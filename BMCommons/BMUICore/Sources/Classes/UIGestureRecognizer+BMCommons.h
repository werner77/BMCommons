//
// Created by Werner Altewischer on 08/04/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^BMGestureRecognizerTargetBlock)(UIGestureRecognizer *gr);

@interface UIGestureRecognizer (BMCommons)

/**
 * Sets the specified block as target for the gesture recognizer event.
 */
- (void)bmSetTargetBlock:(BMGestureRecognizerTargetBlock)block;

@end