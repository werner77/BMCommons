//
// Created by Werner Altewischer on 02/01/17.
// Copyright (c) 2017 BehindMedia. All rights reserved.
//

#import "BMSingleton.h"

@implementation BMSingleton {

}

BM_SYNTHESIZE_DEFAULT_ABSTRACT_SINGLETON

NSString * const BMReleaseSharedInstancesNotification = @"com.behindmedia.BMReleaseSharedInstancesNotification";

static BOOL sharedInstanceCreationAllowed = YES;

+ (void)releaseAllSharedInstances {
    @synchronized (BMSingleton.class) {
        sharedInstanceCreationAllowed = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:BMReleaseSharedInstancesNotification object:nil];
        sharedInstanceCreationAllowed = YES;
    }
}

+ (BOOL)isSharedInstanceCreationAllowed {
    @synchronized (BMSingleton.class) {
        return sharedInstanceCreationAllowed;
    }
}

@end