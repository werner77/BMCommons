//
//  UIScreen+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/08/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "UIScreen+BMCommons.h"
#import <BMUICore/BMUICore.h>

@implementation UIScreen (BMCommons)

- (CGRect)bmPortraitApplicationFrame {
    UIInterfaceOrientation orientation = BMInterfaceOrientation();
    if (BMOSVersionIsAtLeast(@"8.0") && UIInterfaceOrientationIsLandscape(orientation)) {
        CGRect rect = CGRectMake(0, 0, self.applicationFrame.size.height, self.applicationFrame.size.width);
        if (orientation == UIInterfaceOrientationPortrait) {
            rect.origin.y = 20.0f;
        } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            rect.origin.x = 20.0f;
        }
        return rect;
    } else {
        return self.applicationFrame;
    }
}

- (CGRect)bmPortraitBounds {
    if (BMOSVersionIsAtLeast(@"8.0") && UIInterfaceOrientationIsLandscape(BMInterfaceOrientation())) {
        return CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        return self.bounds;
    }
}

@end
