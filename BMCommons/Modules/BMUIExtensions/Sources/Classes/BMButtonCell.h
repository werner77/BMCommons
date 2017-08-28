//
//  BMButtonCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMButtonCell : BMObjectPropertyTableViewCell

@property (nullable, nonatomic, strong) IBOutlet UIButton *button;

@end

NS_ASSUME_NONNULL_END
