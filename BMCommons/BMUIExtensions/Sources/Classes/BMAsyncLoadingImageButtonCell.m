//
//  BMAsyncLoadingImageButtonCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/14/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAsyncLoadingImageButtonCell.h>

@implementation BMAsyncLoadingImageButtonCell

+ (Class)supportedValueClass {
    return [UIImage class];
}

- (void)setViewWithData:(id)value {
    self.imageButton.image = value;
}

- (id)dataFromView {
    return self.imageButton.image;
}

@end
