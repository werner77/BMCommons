//
//  BMDateSelectionViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#if KAL_ENABLED

#import "BMDateSelectionViewController.h"
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMCustomKalViewController.h>
#import "KalDate.h"
#import <BMCommons/BMUICore.h>

@implementation BMDateSelectionViewController

@synthesize propertyDescriptor, delegate;

- (id)init {
	if ((self = [super init])) {
		NSCalendar *utcCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[utcCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[KalDate setCurrentCalendar:utcCalendar];
		kalViewController = [[BMCustomKalViewController alloc] init];
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(propertyDescriptor);
	BM_RELEASE_SAFELY(kalViewController);
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	KalView *kalView = (KalView *)kalViewController.view;
	
	kalView.frame = CGRectMake(0, 1, kalView.frame.size.width, kalView.frame.size.height);
	[self.view addSubview:kalView];
	
	kalViewController.title = self.title;
	
	NSDate *date = [propertyDescriptor callGetter];
	
	if (!date) {
		date = [NSDate date];
	}
	[kalViewController showAndSelectDate:date];
	self.contentSizeForViewInPopover = CGSizeMake(320, 266);
	
	kalViewController.target = self;
	kalViewController.selector = @selector(didSelectDate:);
}

- (void)viewDidUnload {
	kalViewController.target = nil;
	kalViewController.selector = nil;
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Actions

- (void)onCancel {
	[self.delegate editViewControllerWasCancelled:self];
}

- (void)didSelectDate:(KalDate *)kalDate {
	NSDate *selectedDate = [kalDate NSDate];
	[propertyDescriptor callSetter:selectedDate];
	[self.delegate editViewController:self didSelectValue:selectedDate];
}

@end

#endif
