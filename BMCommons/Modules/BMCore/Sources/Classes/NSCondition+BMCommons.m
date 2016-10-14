//
//  NSCondition+BMCore.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/09/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSCondition+BMCommons.h"
#import <BMCommons/NSObject+BMCommons.h>

@implementation NSCondition (BMCommons)

- (BOOL)bmWaitForPredicate:(BOOL (^)(void))predicate completion:(void (^)(BOOL waited))completion {
    return [self bmWaitForPredicate:predicate timeout:0.0 completion:^(BOOL predicateResult, BOOL waited) {
        if (completion) {
            completion(waited);
        }
    }];
}

- (BOOL)bmWaitForPredicate:(BOOL (^)(void))predicate timeout:(NSTimeInterval)timeout completion:(void (^)(BOOL predicateResult, BOOL waited))completion {
    return [self bmWaitForPredicate:predicate timeout:timeout completion:completion timeoutOccured:NO waited:NO];
}

- (BOOL)bmWaitForPredicate:(BOOL (^)(void))predicate timeout:(NSTimeInterval)timeout completion:(void (^)(BOOL predicateEvaluation, BOOL waited))completion timeoutOccured:(BOOL)timeoutOccured waited:(BOOL)waited {
    
    BOOL predicateResult = NO;
    
    [self lock];
    predicateResult = predicate();
    [self unlock];
    
    if (predicateResult || timeoutOccured) {
        if (completion) {
            completion(predicateResult, waited);
        }
        return NO;
    } else {
        
        NSDate *expirationDate = nil;
        if (timeout > 0.0) {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
        }
        
        id __weak weakSelf = self;

        [self bmPerformBlockInBackground:^id {
            BOOL predicateResult = NO;
            [weakSelf lock];
            while (weakSelf != nil && (predicateResult = predicate()) == NO && (expirationDate == nil || [expirationDate timeIntervalSinceNow] > 0.0)) {
                if (expirationDate == nil) {
                    //Wait for max 1 second to be able to check again if weakSelf != nil (object could be deallocated).
                    [weakSelf waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
                } else {
                    [weakSelf waitUntilDate:expirationDate];
                }
            }
            [weakSelf unlock];
            return @(predicateResult);
        }                 withCompletion:^(id resultFromBlock) {
            BOOL timeoutOccured = ![resultFromBlock boolValue];
            [weakSelf bmWaitForPredicate:predicate timeout:timeout completion:completion timeoutOccured:timeoutOccured waited:YES];
        }];
        return YES;
    }
}


/**
 Performs a thread safe predicate modification while broadcasting the condition which is paired to it.
 */
- (void)bmBroadcastForPredicateModification:(void (^)(void))modification {
    [self lock];
    modification();
    [self broadcast];
    [self unlock];
}

@end
