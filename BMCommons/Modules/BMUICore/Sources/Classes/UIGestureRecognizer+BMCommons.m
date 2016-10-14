//
// Created by Werner Altewischer on 08/04/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import "UIGestureRecognizer+BMCommons.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (BMCommons)

static char * const kGestureRecognizerTargetBlockKey = "com.behindmedia.bmcommons.UIGestureRecognizer.targetBlock";

- (BMGestureRecognizerTargetBlock)bmTargetBlock {
    return objc_getAssociatedObject(self, kGestureRecognizerTargetBlockKey);
}

- (void)bmSetTargetBlock:(BMGestureRecognizerTargetBlock)block {

    SEL handler = @selector(bmBlockTargetHandler);
    BMGestureRecognizerTargetBlock currentBlock = self.bmTargetBlock;

    objc_setAssociatedObject(self, kGestureRecognizerTargetBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);

    if (block == nil && currentBlock != nil) {
        [self removeTarget:self action:handler];
    } else if (block != nil && currentBlock == nil) {
        [self addTarget:self action:handler];
    }
}

- (void)bmBlockTargetHandler {
    BMGestureRecognizerTargetBlock block = self.bmTargetBlock;
    if (block) {
        block(self);
    }
}

@end