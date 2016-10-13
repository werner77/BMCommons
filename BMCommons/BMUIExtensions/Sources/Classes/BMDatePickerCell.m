//
//  BMDatePickerCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#if KAL_ENABLED

#import "BMDatePickerCell.h"
#import "BMDateSelectionViewController.h"
#import <BMCore/BMPropertyDescriptor.h>

@implementation BMDatePickerCell

#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
	BMDateSelectionViewController *vc = [[BMDateSelectionViewController alloc] init];
	vc.propertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"selectedValue" 
																			 withTarget:self];
	return vc;
}

@end

#endif
