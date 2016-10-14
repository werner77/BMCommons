//
//  UIToolBar+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 UIToolbar additions.
 */
@interface UIToolbar(BMCommons)

/**
 Method for replacing a bar button item with a new item.
 */
- (void)bmReplaceItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem*)item;

@end
