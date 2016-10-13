//
//  BMTimeSelectionViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/6/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMTimeSelectionViewController.h"
#import <BMCore/BMPropertyDescriptor.h>
#import "BMUICore.h"

@implementation BMTimeSelectionViewController

@synthesize propertyDescriptor, delegate, datePicker, buttonImageName;

- (id)init {
	if ((self = [self initWithNibName:@"TimeSelectionView" bundle:[BMUICore bundle]])) {
        self.buttonImageName = @"BMUICore.bundle/buttonOrange.png";
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(buttonImageName);
	BM_RELEASE_SAFELY(propertyDescriptor);
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImage *image = [self buttonImage];
	image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width/2) topCapHeight:0];
	
	submitButton.frame = CGRectMake(0, datePicker.frame.size.height, datePicker.frame.size.width, image.size.height);
	[submitButton setBackgroundImage:image forState:UIControlStateNormal];
    
    if (!BMOSVersionIsAtLeast(@"5.0")) {
        //Bug in iOS 4: date picker doesn't scale properly
        datePicker.frame = CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y, datePicker.frame.size.width - 20, datePicker.frame.size.height);
    }
    
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	datePicker.locale = [NSLocale currentLocale];
	
	NSDate *theDate = [propertyDescriptor callGetter];
	
	if (!theDate) {
		theDate = [NSDate date];
	}
	
	datePicker.date = theDate;
	
	self.contentSizeForViewInPopover = CGSizeMake(CGRectGetMaxX(submitButton.frame), CGRectGetMaxY(submitButton.frame));
}

- (void)viewDidUnload {
	BM_RELEASE_SAFELY(datePicker);
	BM_RELEASE_SAFELY(submitButton);
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Actions

- (IBAction)onCancel {
	[self.delegate editViewControllerWasCancelled:self];
}

- (IBAction)onSelectDate {
	NSDate *selectedDate = datePicker.date;
	[propertyDescriptor callSetter:selectedDate];
	[self.delegate editViewController:self didSelectValue:selectedDate];
}


- (UIImage *)buttonImage {
    return [UIImage imageNamed:self.buttonImageName];
}

@end
