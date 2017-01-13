//
//  BMWeakTimerTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/3/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMWeakTimerTestCase.h"
#import <BMCommons/BMWeakTimer.h>

@interface BMObjectRetainingTimer : NSObject

@property (nonatomic, strong) BMWeakTimer *timer;

@end

@implementation BMObjectRetainingTimer

- (void)dealloc {
    //[self.timer invalidate];
    self.timer = nil;
    NSLog(@"Object deallocated");
}

- (void)timerFired:(BMWeakTimer *)timer {
    NSLog(@"Timer fired with user info: %@", timer.userInfo);
}

@end

@implementation BMWeakTimerTestCase {
    BMObjectRetainingTimer *_objectRetainingTimer;
}

- (void)testTimer {
    NSLog(@"Initializing timer");
    _objectRetainingTimer = [BMObjectRetainingTimer new];
    _objectRetainingTimer.timer = [BMWeakTimer scheduledTimerWithTimeInterval:2.0 target:_objectRetainingTimer selector:@selector(timerFired:) userInfo:@{@"aap" : @"noot"} repeats:YES];
    
    [self performSelector:@selector(releaseObject) withObject:nil afterDelay:3.0];
}

- (void)releaseObject  {
    NSLog(@"Releasing object");
    _objectRetainingTimer = nil;
}

@end
