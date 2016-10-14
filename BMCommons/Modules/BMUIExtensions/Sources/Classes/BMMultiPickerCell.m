//
//  BMMultiPickerCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMultiPickerCell.h>
#import <BMCommons/BMMultiSelectionViewController.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMUICore.h>

@implementation BMMultiPickerCell

@synthesize dataSource;

- (void)dealloc {
	BM_RELEASE_SAFELY(dataSource);
}

- (void)initialize {
	[super initialize];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	self.dataSource = nil;
}

#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
	BMMultiSelectionViewController *vc = [[BMMultiSelectionViewController alloc] initWithDataSource:self.dataSource];
	vc.propertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"selectedValue" 
																			 withTarget:self];
	return vc;
}

@end
