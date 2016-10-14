//
//  UINavigationBar+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/9/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 Custom CALayer for a UINavigationBar, allowing for adding custom background layers.
 */
@interface BMNavigationBarLayer : CALayer

- (void)bmAddBackgroundLayer:(CALayer*)layer;

@end

/**
 UINavigationBar additions.
 */
@interface UINavigationBar(BMCommons)

/**
 Sets the specified view as background view for this navigation bar.
 */
- (void)bmSetBackgroundView:(UIView *)v;

@end
