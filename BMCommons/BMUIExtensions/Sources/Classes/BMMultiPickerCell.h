//
//  BMMultiPickerCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUIExtensions/BMValueSelectionCell.h>
#import <BMUIExtensions/BMPickerDataSource.h>

@interface BMMultiPickerCell : BMValueSelectionCell {
	id <BMPickerDataSource> dataSource;
}

@property (nonatomic, strong) id <BMPickerDataSource> dataSource;

@end
