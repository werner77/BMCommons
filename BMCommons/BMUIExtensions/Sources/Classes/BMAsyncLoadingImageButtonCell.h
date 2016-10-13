//
//  BMAsyncLoadingImageButtonCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/14/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMUICore/BMObjectPropertyTableViewCell.h>
#import <BMUICore/BMAsyncLoadingImageButton.h>

@interface BMAsyncLoadingImageButtonCell : BMObjectPropertyTableViewCell

@property (nonatomic, strong) IBOutlet BMAsyncLoadingImageButton *imageButton;

@end
