//
//  BMTimeSelectionViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/6/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMViewController.h>
#import <BMCommons/BMEditViewController.h>

@interface BMTimeSelectionViewController : BMViewController<BMEditViewController> {
	BMPropertyDescriptor *propertyDescriptor;
	__weak id <BMEditViewControllerDelegate> delegate;
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UIButton *submitButton;
    NSString *buttonImageName;
}

@property (nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) NSString *buttonImageName;

- (IBAction)onCancel;
- (IBAction)onSelectDate;	

- (UIImage *)buttonImage;

@end
