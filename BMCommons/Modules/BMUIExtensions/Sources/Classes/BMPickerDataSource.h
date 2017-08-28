//
//  BMPickerDataSource.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BMPickerDataSource<UIPickerViewDelegate, UIPickerViewDataSource>

- (void)selectValue:(nullable id)theValue forPickerView:(UIPickerView *)picker;
- (nullable id)selectedValueForPickerView:(UIPickerView *)picker;

@end

NS_ASSUME_NONNULL_END

