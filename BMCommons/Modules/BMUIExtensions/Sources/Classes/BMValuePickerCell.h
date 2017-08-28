//
//  BMValuePickerCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMEnumeratedValueCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMValuePickerCell : BMEnumeratedValueCell

@property (nullable, nonatomic, strong) NSString *valueSelectionControllerNibName;

@end

NS_ASSUME_NONNULL_END