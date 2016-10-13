//
//  BMResizableToolbar.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMResizableToolbar.h"


@implementation BMResizableToolbar {
	CGFloat height;
}

@synthesize height;

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = self.height;
    return result;
}

@end
