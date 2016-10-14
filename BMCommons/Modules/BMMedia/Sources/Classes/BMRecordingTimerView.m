//
//  BMRecordingTimerView.m
//  BMCommons
//
//  Created by Werner Altewischer on 17/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMRecordingTimerView.h>
#import <BMMedia/BMMedia.h>
#import <BMCommons/BMProxy.h>

@implementation BMRecordingTimerView {
    NSTimer *timer;
    NSTimeInterval maxTime;
    BOOL countDown;
    id <BMRecordingTimerViewDelegate> __weak delegate;
    NSTimeInterval criticalTimeThreshold;
    NSTimeInterval warningTimeThreshold;
}

@synthesize hourLabel;
@synthesize minuteLabel;
@synthesize secondLabel;
@synthesize maxTime;
@synthesize countDown;
@synthesize delegate;
@synthesize criticalTimeThreshold;
@synthesize warningTimeThreshold;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

    }
    return self;
}

- (void)updateWithRecordingTime:(NSTimeInterval)recordingTime {
    NSTimeInterval availableTime = 1000000;
    
    if (self.maxTime > 0.0) {
        availableTime = self.maxTime - recordingTime;
    }
    
    UIColor *textColor;
    if (availableTime < self.criticalTimeThreshold) {
        textColor = [UIColor redColor];
    } else if (availableTime < self.warningTimeThreshold) {
        textColor = [UIColor yellowColor];
    } else {
        textColor = [UIColor whiteColor];
    }
    
    if (self.countDown && self.maxTime > 0.0) {
        recordingTime = self.maxTime - recordingTime;
        if (recordingTime < 1.0) {
            [self.delegate recordingTimerViewReachedMaxDuration:self];
        }
    }
    int hours = round(recordingTime) / 3600;
    int minutes = round(recordingTime) / 60 - hours * 60;
    int seconds = round(recordingTime) - hours * 3600 - minutes * 60;
    
    self.hourLabel.text = [NSString stringWithFormat:@"%02d", hours];
    self.minuteLabel.text = [NSString stringWithFormat:@"%02d", minutes];
    self.secondLabel.text = [NSString stringWithFormat:@"%02d", seconds];
    
    self.hourLabel.textColor = textColor;
    self.minuteLabel.textColor = textColor;
    self.secondLabel.textColor = textColor;
}

- (void)onTimer:(NSTimer *)theTimer {
    NSDate *startDate = [theTimer userInfo];
    
    NSTimeInterval interval = -[startDate timeIntervalSinceNow];
    [self updateWithRecordingTime:interval];
}

- (BOOL)isTiming {
    return (timer != nil);
}

- (void)startTimer {
    if (timer) {
        [self stopTimer];
    }
    [self updateWithRecordingTime:0];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[BMProxy proxyWithObject:self threadSafe:NO retained:NO] selector:@selector(onTimer:) userInfo:[NSDate date] repeats:YES];
}

- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}

- (void)dealloc {
    if (timer) {
        [self stopTimer];
    }
}

@end
