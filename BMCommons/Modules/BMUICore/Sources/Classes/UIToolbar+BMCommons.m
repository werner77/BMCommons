//
//  UIToolbar+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "UIToolbar+BMCommons.h"

@implementation UIToolbar(BMCommons)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bmReplaceItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem*)item {
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in self.items) {
        if (button == oldItem) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.items];
            newItems[buttonIndex] = item;
            self.items = newItems;
            break;
        }
        ++buttonIndex;
    }
}

@end
