//
//  UIScreen+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/08/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "UIScreen+BMCommons.h"
#import <BMCommons/BMUICore.h>

@implementation UIScreen (BMCommons)

- (CGRect)bmPortraitApplicationFrame {
    CGFloat statusBarHeight = BMStatusHeight();
    CGRect applicationFrame = self.bmApplicationFrame;
    UIInterfaceOrientation orientation = BMInterfaceOrientation();
    CGRect rect;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        rect = CGRectMake(0, 0, applicationFrame.size.height, applicationFrame.size.width);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            rect.origin.x = statusBarHeight;
        }
    } else {
        rect = CGRectMake(0, 0, applicationFrame.size.width, applicationFrame.size.height);
        if (orientation == UIInterfaceOrientationPortrait) {
            rect.origin.y = statusBarHeight;
        }
    }
    return rect;
}

- (CGRect)bmPortraitBounds {
    if (BMOSVersionIsAtLeast(@"8.0") && UIInterfaceOrientationIsLandscape(BMInterfaceOrientation())) {
        return CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        return self.bounds;
    }
}

- (CGRect)bmApplicationFrame {
    CGFloat statusBarHeight = BMStatusHeight();
    CGRect bounds = self.bmBounds;
    return CGRectMake(0, statusBarHeight, bounds.size.width, bounds.size.height - statusBarHeight);
}

- (CGRect)bmBounds {
    if (BMOSVersionIsAtLeast(@"8.0") || UIInterfaceOrientationIsPortrait(BMInterfaceOrientation())) {
        return self.bounds;
    } else {
        return CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    }
}

@end
