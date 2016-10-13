//
//  BMUICoreObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMUICoreObject.h"
#import <BMCommons/BMUICore.h>

@implementation BMUICoreObject

+ (void)initialize {
    BMUICoreCheckLicense();
}

- (id)init {
    if ((self = [super init])) {
        BMUICoreCheckLicense();
    }
    return self;
}

@end
