//
//  UISegmentedControl+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "UISegmentedControl+BMCommons.h"

@implementation UISegmentedControl(BMCommons)

- (void)bmSetTarget:(id)target action:(SEL)action {
    NSSet *allTargets = [self allTargets];
	for (id theTarget in allTargets) {
		[self removeTarget:theTarget action:NULL forControlEvents:UIControlEventValueChanged];
	}
	[self addTarget:target action:action forControlEvents:UIControlEventValueChanged];

}

@end
