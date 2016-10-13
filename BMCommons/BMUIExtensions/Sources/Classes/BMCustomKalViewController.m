//
//  CustomKalViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#if KAL_ENABLED
#import "BMCustomKalViewController.h"
#import <BMCommons/BMUICore.h>

@implementation BMCustomKalViewController

@synthesize target, selector;

- (void)showPreviousMonth {
	ignore = YES;
	[super showPreviousMonth];
}

- (void)showFollowingMonth {
	ignore = YES;
	[super showFollowingMonth];
}

- (void)didSelectDate:(KalDate *)date {
	[super didSelectDate:date];
	if (!ignore) {
		[target performSelector:selector withObject:date];
	}
	ignore = NO;
}

@end
#endif
