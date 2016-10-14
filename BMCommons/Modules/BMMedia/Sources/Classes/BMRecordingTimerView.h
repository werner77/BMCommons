//
//  BMRecordingTimerView.h
//  BMCommons
//
//  Created by Werner Altewischer on 17/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMRecordingTimerView;

/**
 Delegate for BMRecordingTimerView.
 */
@protocol BMRecordingTimerViewDelegate <NSObject>

/**
 Method called when the count down timer reached 0.
 */
- (void)recordingTimerViewReachedMaxDuration:(BMRecordingTimerView *)view;

@end

/**
 Semi-transparent view containing a count-down timer for recording video.
 
 Used in BMCameraOverlayView.
 */
@interface BMRecordingTimerView : UIView 

@property (nonatomic, strong) IBOutlet UILabel *hourLabel;
@property (nonatomic, strong) IBOutlet UILabel *minuteLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;

/**
 The max time that is allowed to elapse after startTimer before [BMRecordingTimerViewDelegate recordingTimerViewReachedMaxDuration:] is called.
 */
@property (nonatomic, assign) NSTimeInterval maxTime;

/**
 Whether to count down from the maxTime or to start at zero and count up.
 */
@property (nonatomic, assign) BOOL countDown;

@property (nonatomic, weak) id <BMRecordingTimerViewDelegate> delegate;

/**
 Time interval after which the view turns red.
 */
@property (nonatomic, assign) NSTimeInterval criticalTimeThreshold;

/**
 Time interval after which the view turns yellow.
 */
@property (nonatomic, assign) NSTimeInterval warningTimeThreshold;

/**
 Updates the view with the specified recording time.
 */
- (void)updateWithRecordingTime:(NSTimeInterval)recordingTime;

/**
 Starts the timer.
 */
- (void)startTimer;

/**
 Stops the timer.
 */
- (void)stopTimer;

/**
 Returns YES if the timer is currently active, NO otherwise.
 */
- (BOOL)isTiming;

@end
