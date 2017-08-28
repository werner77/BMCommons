//
//  BMMultiSelectionViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMultiSelectionViewController.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMUICore.h>

#define MARGIN 10.0f

@implementation BMMultiSelectionViewController {
	BMPropertyDescriptor *propertyDescriptor;
	__weak id <BMEditViewControllerDelegate> delegate;
	IBOutlet UIPickerView *picker;
	IBOutlet UIButton *submitButton;
	id <BMPickerDataSource> dataSource;
}

@synthesize propertyDescriptor, delegate, dataSource;

- (id)initWithDataSource:(id <BMPickerDataSource>)theDataSource {
	if ((self = [self initWithNibName:@"MultiSelectionView" bundle:[BMUICore bundle]])) {
		dataSource = theDataSource;
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(dataSource);
	BM_RELEASE_SAFELY(propertyDescriptor);
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImage *image = [self buttonImage];
	image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width/2) topCapHeight:0];
	
	submitButton.frame = CGRectMake(0, picker.frame.size.height, picker.frame.size.width, image.size.height);
	[submitButton setBackgroundImage:image forState:UIControlStateNormal];
	
	picker.dataSource = dataSource;
	picker.delegate = dataSource;
	
	[dataSource selectValue:[propertyDescriptor callGetter] forPickerView:picker];
	
	//TODO: calculate width
	CGFloat width = 2 * MARGIN;
	for (int i = 0; i < [dataSource numberOfComponentsInPickerView:picker]; ++i) {
		width += [dataSource pickerView:picker widthForComponent:i];
	}
	self.preferredContentSize = CGSizeMake(width, CGRectGetMaxY(submitButton.frame));
}

- (void)viewDidUnload {
	BM_RELEASE_SAFELY(picker);
	BM_RELEASE_SAFELY(submitButton);
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Actions

- (IBAction)onCancel {
	[self.delegate editViewControllerWasCancelled:self];
}

- (IBAction)onSelectValue {
	[propertyDescriptor callSetter:[dataSource selectedValueForPickerView:picker]];
	[self.delegate editViewController:self didSelectValue:nil];
}

- (UIImage *)buttonImage {
    return [UIImage imageNamed:@"BMUICore.bundle/buttonOrange.png"];
}

@end
