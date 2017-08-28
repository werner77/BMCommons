//
//  BMMultiPickerCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMValueSelectionCell.h>
#import <BMCommons/BMPickerDataSource.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMMultiPickerCell : BMValueSelectionCell

@property (nullable, nonatomic, strong) id <BMPickerDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
