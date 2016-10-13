//
//  UITableViewCell+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "UITableViewCell+BMCommons.h"
#import "UIView+BMCommons.h"
#import <BMCommons/BMCore.h>

@implementation UITableViewCell (BMCommons)

- (void)bmRemoveMarginsAndInsets {
    [super bmRemoveMarginsAndInsets];
    
    BM_START_IGNORE_TOO_NEW
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    BM_END_IGNORE_TOO_NEW
}

@end
