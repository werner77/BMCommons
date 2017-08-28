//
//  BMSliderCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 03/04/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMCommons/BMSlider.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMSliderCell : BMObjectPropertyTableViewCell<BMSliderDelegate>

@property (nullable, nonatomic, strong) IBOutlet BMSlider *slider;
@property (nullable, nonatomic, strong) IBOutlet UILabel *currentValueLabel;

@end

NS_ASSUME_NONNULL_END
