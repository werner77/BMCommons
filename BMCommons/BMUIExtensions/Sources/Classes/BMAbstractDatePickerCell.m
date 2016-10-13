//
//  BMAbstractDataPickerCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMAbstractDatePickerCell.h"
#import "BMDateSelectionViewController.h"
#import <BMCommons/BMPropertyDescriptor.h>

@implementation BMAbstractDatePickerCell

+ (Class)supportedValueClass {
	return [NSDate class];
}


#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
	return nil;
}

@end
