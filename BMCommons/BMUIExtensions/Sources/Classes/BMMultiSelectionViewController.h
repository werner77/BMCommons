//
//  BMMultiSelectionViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMViewController.h>
#import <BMUIExtensions/BMEditViewController.h>
#import <BMUIExtensions/BMPickerDataSource.h>

@interface BMMultiSelectionViewController : BMViewController<BMEditViewController> {
	BMPropertyDescriptor *propertyDescriptor;
	__weak id <BMEditViewControllerDelegate> delegate;
	IBOutlet UIPickerView *picker;
	IBOutlet UIButton *submitButton;
	id <BMPickerDataSource> dataSource;
}

@property (nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;
@property (nonatomic, readonly) id <BMPickerDataSource> dataSource;

- (id)initWithDataSource:(id <BMPickerDataSource>)theDataSource;

- (IBAction)onCancel;
- (IBAction)onSelectValue;

- (UIImage *)buttonImage;

@end
