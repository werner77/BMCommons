//
//  BMErrorView.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMErrorView.h"
#import <BMCommons/BMUICore.h>

@implementation BMErrorView {
    UIButton *_refreshButton;
    UILabel *_descriptionLabel;
    UIImageView*  _imageView;
    UILabel*      _titleLabel;
    UILabel*      _subtitleLabel;
}

@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize refreshButton = _refreshButton;
@synthesize descriptionLabel = _descriptionLabel;

- (void)dealloc {
    BM_RELEASE_SAFELY(_descriptionLabel);
    BM_RELEASE_SAFELY(_refreshButton);
    BM_RELEASE_SAFELY(_subtitleLabel);
    BM_RELEASE_SAFELY(_titleLabel);
    BM_RELEASE_SAFELY(_imageView);
}

@end
