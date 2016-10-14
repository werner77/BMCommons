//
//  UIResponder+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const BMResponderDidBecomeFirstNotification;
extern NSString *const BMResponderDidResignFirstNotification;

/**
 UIResponder extension that adds notifications when a UIResponder becomes active or resigns from being active.
 */
@interface UIResponder(BMCommons)

- (void)bmPostDidBecomeFirstResponderNotification;
- (void)bmPostDidResignFirstResponderNotification;

@end
