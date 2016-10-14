//
//  BMPickerDataSource.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BMPickerDataSource<UIPickerViewDelegate, UIPickerViewDataSource>

- (void)selectValue:(id)theValue forPickerView:(UIPickerView *)picker;
- (id)selectedValueForPickerView:(UIPickerView *)picker;

@end

