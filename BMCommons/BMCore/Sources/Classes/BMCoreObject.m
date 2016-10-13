//
//  BMCoreObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMCoreObject.h"
#import <BMCommons/BMCore.h>

@implementation BMCoreObject

+ (void)initialize {
    BMCoreCheckLicense();
}

- (id)init {
    if ((self = [super init])) {
        BMCoreCheckLicense();
    }
    return self;
}

@end
