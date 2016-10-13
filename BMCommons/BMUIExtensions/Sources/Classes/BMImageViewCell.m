//
//  BMImageViewCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMImageViewCell.h>

@implementation BMImageViewCell

@synthesize cellImageView;

+ (Class)supportedValueClass {
    return [UIImage class];
}


- (void)setViewWithData:(id)value {
    self.cellImageView.image = value;
}

- (id)dataFromView {
    return self.cellImageView.image;
}

@end
