//
//  UISwitch+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "UISwitch+BMCommons.h"

@interface UISwitch(BM_Private)

- (void)findLabels:(NSMutableArray *)labels inView: (UIView *) aView;

@end

@implementation UISwitch(BMCommons)

- (UILabel *)bmOffLabel {
	NSMutableArray *labels = [NSMutableArray arrayWithCapacity:4];
	[self findLabels:labels inView:self];
	if (labels.count == 2) {
		return labels[0];
	} else {
		return nil;
	}
}

- (UILabel *)bmOnLabel {
	NSMutableArray *labels = [NSMutableArray arrayWithCapacity:4];
	[self findLabels:labels inView:self];
	if (labels.count == 2) {
		return labels[1];
	} else {
		return nil;
	}
}

@end

@implementation UISwitch(BM_Private)

- (void)findLabels:(NSMutableArray *)labels inView: (UIView *) aView {  
    for (UIView *subview in [aView subviews]) {  
        if ([subview isKindOfClass:[UILabel class]]) {
			[labels addObject:subview];
        }  
        else {
			[self findLabels:labels inView:subview];  
		}   
    }  
}

@end