//
//  UIButton+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/7/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UIButton+BMCommons.h"
#import <objc/runtime.h>

@implementation UIButton(BMCommons)

static char * const kButtonTargetBlockKey = "com.behindmedia.bmcommons.UIButton.buttonTargetBlock";

- (void)bmSetTargetBlock:(BMButtonTargetBlock)block {
    objc_setAssociatedObject(self, kButtonTargetBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (block) {
        [self bmSetTarget:self action:@selector(bmTouchUpInsideBlockHandler)];
    } else {
        [self bmSetTarget:nil action:nil];
    }
}

- (BMButtonTargetBlock)bmButtonTargetBlock {
    return objc_getAssociatedObject(self, kButtonTargetBlockKey);
}

- (void)bmTouchUpInsideBlockHandler {
    BMButtonTargetBlock block = self.bmButtonTargetBlock;
    if (block) {
        block(self);
    }
}

- (void)bmSetTarget:(id)target action:(SEL)action {
	NSSet *allTargets = [self allTargets];
	for (id theTarget in allTargets) {
		[self removeTarget:theTarget action:NULL forControlEvents:UIControlEventTouchUpInside];
	}
    if (target && action) {
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

+ (UIButton *)bmButtonForBarButtonItemWithTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setAdjustsImageWhenHighlighted:NO];
    [button setShowsTouchWhenHighlighted:YES];
    [button bmSetTarget:target action:action];
    button.imageView.contentMode = UIViewContentModeCenter;
    return button;
}

@end
