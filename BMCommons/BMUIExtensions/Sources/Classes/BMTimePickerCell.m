//
//  BMTimePickerCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/6/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMTimePickerCell.h"
#import "BMTimeSelectionViewController.h"
#import <BMCore/BMPropertyDescriptor.h>

@implementation BMTimePickerCell

#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
	BMTimeSelectionViewController *vc = [[BMTimeSelectionViewController alloc] init];
	vc.propertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"selectedValue" 
																			 withTarget:self];
	return vc;
}

@end
