//
//  BMImageViewCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMImageViewCell : BMObjectPropertyTableViewCell

@property (nullable, nonatomic, strong) IBOutlet UIImageView *cellImageView;

@end

NS_ASSUME_NONNULL_END