//
//  BMDraggableButton.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum BMDraggableButtonState {
    BMDraggableButtonStateMin = 0,
    BMDraggableButtonStateMax = 1
} BMDraggableButtonState;

/**
 A sliding button which has two states.
 
 Can be used as a slidable switch.
 */
@interface BMDraggableButton : UIButton

@property (nonatomic, assign) CGRect slidingRange;

/**
 The current state of the button.
 
 Assignment will call setState:animated: with animated set to NO.
 */
@property (nonatomic, assign) BMDraggableButtonState buttonState;

/**
 Call to modify the state programmatically. 
 
 Will not trigger control events.
 */
- (void)setButtonState:(BMDraggableButtonState)state animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

