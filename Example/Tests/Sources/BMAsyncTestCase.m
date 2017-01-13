//
//  BMAsyncTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/01/17.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import "BMAsyncTestCase.h"
#import <BMCommons/NSArray+BMCommons.h>

@interface BMAsyncTestCaseFailureInfo : NSObject

@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSUInteger lineNumber;
@property (nonatomic, assign) BOOL expected;

@end

@implementation BMAsyncTestCaseFailureInfo

@end

@interface BMAsyncTestCase ()

@property (nonatomic, strong) NSDate *loopUntil;
@property (nonatomic, assign) BOOL notified;
@property (nonatomic, assign) BOOL shouldWait;
@property (nonatomic, assign, getter=isWaiting) BOOL waiting;
@property (nonatomic, assign) BMAsyncTestCaseStatus notifiedStatus;
@property (nonatomic, assign) BMAsyncTestCaseStatus expectedStatus;
@property (nonatomic, strong) BMAsyncTestCaseFailureInfo *failureInfo;

@end


@implementation BMAsyncTestCase

@synthesize loopUntil = _loopUntil;
@synthesize notified = _notified;
@synthesize notifiedStatus = _notifiedStatus;
@synthesize expectedStatus = _expectedStatus;


#pragma mark - Public

- (void)setUp {
    [super setUp];
    self.shouldWait = YES;
    self.failureInfo = nil;
}

- (void)waitForStatus:(BMAsyncTestCaseStatus)status timeout:(NSTimeInterval)timeout
{
    if (self.shouldWait) {
        self.notified = NO;
        self.expectedStatus = status;
        self.waiting = YES;
        self.loopUntil = timeout > 0.0 ? [NSDate dateWithTimeIntervalSinceNow:timeout] : nil;
        
        while (self.continueWaiting && (self.loopUntil == nil || [self.loopUntil timeIntervalSinceNow] > 0)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        self.waiting = NO;
        
        // Only assert when notified. Do not assert when timed out
        // Fail if not notified
        if (self.notified) {
            if (self.failureInfo != nil) {
                [self recordFailureWithDescription:self.failureInfo.descriptionString inFile:self.failureInfo.filePath atLine:self.failureInfo.lineNumber expected:self.failureInfo.expected];
            } else {
                XCTAssertEqual(self.notifiedStatus, self.expectedStatus, @"Notified status does not match the expected status.");
            }
        } else {
            XCTFail(@"Async test timed out.");
        }
    }
}

- (void)waitForTimeout:(NSTimeInterval)timeout
{
    self.notified = NO;
    self.waiting = YES;
    self.expectedStatus = BMAsyncTestCaseStatusUnknown;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while (self.continueWaiting && [self.loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    self.waiting = NO;
    
    if (self.notified && self.failureInfo != nil) {
        [self recordFailureWithDescription:self.failureInfo.descriptionString inFile:self.failureInfo.filePath atLine:self.failureInfo.lineNumber expected:self.failureInfo.expected];
    }
}

- (BOOL)continueWaiting {
    return !self.notified;
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber expected:(BOOL)expected {
    self.shouldWait = NO;
    if ([self isWaiting] && self.failureInfo == nil) {
        BMAsyncTestCaseFailureInfo *info = [BMAsyncTestCaseFailureInfo new];
        info.descriptionString = description;
        info.filePath = filePath;
        info.lineNumber = lineNumber;
        info.expected = expected;
        self.failureInfo = info;
        [self notify:BMAsyncTestCaseStatusFailed];
    } else {
        [super recordFailureWithDescription:description inFile:filePath atLine:lineNumber expected:expected];
    }
}

- (void)notify:(BMAsyncTestCaseStatus)status
{
    self.notifiedStatus = status;
    // self.notified must be set at the last of this method
    self.notified = YES;
}

@end


