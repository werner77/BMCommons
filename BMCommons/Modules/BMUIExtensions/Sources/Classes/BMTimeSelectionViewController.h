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

NS_ASSUME_NONNULL_BEGIN

@interface BMTimeSelectionViewController : BMViewController<BMEditViewController>

@property (nullable, nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;
@property (nullable, nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nullable, nonatomic, strong) NSString *buttonImageName;

- (IBAction)onCancel;
- (IBAction)onSelectDate;	

- (nullable UIImage *)buttonImage;

@end

NS_ASSUME_NONNULL_END
