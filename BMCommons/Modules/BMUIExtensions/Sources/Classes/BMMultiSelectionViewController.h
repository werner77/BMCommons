//
//  BMMultiSelectionViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMViewController.h>
#import <BMCommons/BMEditViewController.h>
#import <BMCommons/BMPickerDataSource.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMMultiSelectionViewController : BMViewController<BMEditViewController>

@property (nullable, nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;
@property (nullable, nonatomic, readonly) id <BMPickerDataSource> dataSource;

- (id)initWithDataSource:(nullable id <BMPickerDataSource>)theDataSource;

- (IBAction)onCancel;
- (IBAction)onSelectValue;

- (nullable UIImage *)buttonImage;

@end

NS_ASSUME_NONNULL_END
