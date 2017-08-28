//
//  UIToolbar+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UIToolbar additions.
 */
@interface UIToolbar(BMCommons)

/**
 Method for replacing a bar button item with a new item.
 */
- (void)bmReplaceItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem*)item;

@end

NS_ASSUME_NONNULL_END
