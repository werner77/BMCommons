//
//  UIScreen+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 18/08/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (BMCommons)

/**
 * The application frame corresponding with portrait orientation.
 */
- (CGRect)bmPortraitApplicationFrame;

/**
 * The bounds corresponding with the portrait orientation.
 */
- (CGRect)bmPortraitBounds;

/**
 * The application frame corresponding with the current orientation.
 */
- (CGRect)bmApplicationFrame;

/**
 * The bounds corresponding with the current orientation.
 */
- (CGRect)bmBounds;

@end
