//
//  BMMediaRollThumbnailCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 27/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMediaRollThumbnailCell.h>
#import <BMMedia/BMMedia.h>

@implementation BMMediaRollThumbnailCell

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        BMMediaCheckLicense();
    }
    return self;
}

- (void)initialize {
    [super initialize];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    self.thumbnailImageView.transform = transform;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.thumbnailImageView.frame = CGRectMake(0, 0, self.contentView.frame.size.height, self.contentView.frame.size.height);
}

@end
