//
//  UISegmentedControl+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UISegmentedControl additions.
 */
@interface UISegmentedControl(BMCommons)

/**
 Convenience method to set a target and action for value changed events.
 */
- (void)bmSetTarget:(nullable id)target action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
