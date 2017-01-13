//
//  BMAsyncTestCase.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/01/17.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import "BMTestCase.h"

typedef NS_ENUM(NSUInteger, BMAsyncTestCaseStatus) {
    BMAsyncTestCaseStatusUnknown = 0,
    BMAsyncTestCaseStatusWaiting,
    BMAsyncTestCaseStatusSucceeded,
    BMAsyncTestCaseStatusFailed,
    BMAsyncTestCaseStatusCancelled,
};

@interface BMAsyncTestCase : BMTestCase

- (void)waitForStatus:(BMAsyncTestCaseStatus)status timeout:(NSTimeInterval)timeout;
- (void)waitForTimeout:(NSTimeInterval)timeout;
- (void)notify:(BMAsyncTestCaseStatus)status;
- (BOOL)continueWaiting;

@end
