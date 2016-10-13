//
//  BMCustomButton.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMResponderButton.h"


@implementation BMResponderButton

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
	if (![self isFirstResponder]) {
		[self becomeFirstResponder];
	}
	[super sendAction:action to:target forEvent:event];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}


@end
