//
//  BMSliderCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 03/04/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMCommons/BMSlider.h>

@interface BMSliderCell : BMObjectPropertyTableViewCell<BMSliderDelegate> {
	IBOutlet BMSlider *slider;
    IBOutlet UILabel *currentValueLabel;
}

@property (nonatomic, strong) IBOutlet BMSlider *slider;
@property (nonatomic, strong) IBOutlet UILabel *currentValueLabel;

@end
