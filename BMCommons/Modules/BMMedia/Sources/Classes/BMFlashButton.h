//
//  BMFlashButton.h
//  BMCommons
//
//  Created by Werner Altewischer on 17/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @constant The time interval used for the flash button expansion animation.
 */
extern const NSTimeInterval BMFlashButtonExpandAnimationDuration;

@class BMEnumeratedValue;

/**
 Custom segmented control containing multiple buttons that expand or contract with an animation.
 
 Used by BMCameraOverlayView.
 */
@interface BMFlashButton : UIControl 

/**
 Instances of BMEnumeratedValue. The [BMEnumeratedValue label] property is used to display the title for the respective item.
 */
@property (nonatomic, strong) NSArray *items;

/**
 The selected index. Should be less than the count of items.
 */
@property (nonatomic, assign) NSUInteger selectedIndex;

/**
 Whether or not the control is expanded.
 */
@property (nonatomic, readonly, getter = isExpanded) BOOL expanded;

/**
 The selected item.
 
 @see items
 */
- (BMEnumeratedValue *)selectedItem;

@end
