//
//  UISegmentedControl+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 UISegmentedControl additions.
 */
@interface UISegmentedControl(BMCommons)

/**
 Convenience method to set a target and action for value changed events.
 */
- (void)bmSetTarget:(id)target action:(SEL)action;

@end
