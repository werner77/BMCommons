//
// Created by Werner Altewischer on 02/01/17.
// Copyright (c) 2017 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSingleton.h>
#import "BMSingletons.h"

@implementation BMSingletons {

}

+ (void)releaseAllSingletons {
    [[NSNotificationCenter defaultCenter] postNotificationName:BMReleaseSharedInstancesNotification object:nil];
}

@end