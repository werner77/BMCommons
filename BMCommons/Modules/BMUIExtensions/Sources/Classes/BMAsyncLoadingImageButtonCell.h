//
//  BMAsyncLoadingImageButtonCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/14/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMCommons/BMAsyncLoadingImageButton.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAsyncLoadingImageButtonCell : BMObjectPropertyTableViewCell

@property (nullable, nonatomic, strong) IBOutlet BMAsyncLoadingImageButton *imageButton;

@end

NS_ASSUME_NONNULL_END
