//
//  BMMediaRollCell.m
//  BMCommoms
//
//  Created by Werner Altewischer on 26/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMMediaRollCell.h"
#import <BMMedia/BMMedia.h>

#define DEFAULT_HORIZONTAL_MARGIN 5.0
#define DEFAULT_VERTICAL_MARGIN 5.0

@implementation BMMediaRollCell

@synthesize mediaRoll = _mediaRoll, promptLabel = _promptLabel;
@synthesize horizontalMargin = _horizontalMargin;
@synthesize verticalMargin = _verticalMargin;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        BMMediaCheckLicense();
        self.mediaRoll = [[UITableView alloc] initWithFrame:self.bounds];
        self.promptLabel = [[UILabel alloc] initWithFrame:self.bounds];
        
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
        self.mediaRoll.backgroundColor = [UIColor clearColor];
        self.promptLabel.backgroundColor = [UIColor clearColor];
        self.horizontalMargin = DEFAULT_HORIZONTAL_MARGIN;
        self.verticalMargin = DEFAULT_VERTICAL_MARGIN;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
        self.horizontalMargin = DEFAULT_HORIZONTAL_MARGIN;
        self.verticalMargin = DEFAULT_VERTICAL_MARGIN;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI/2);
    
	self.mediaRoll.transform = transform;
    self.mediaRoll.frame = CGRectMake(self.horizontalMargin, self.verticalMargin, self.contentView.frame.size.width - 2 * self.horizontalMargin, self.contentView.frame.size.height - 2 * self.verticalMargin);
    
    self.promptLabel.frame = self.contentView.bounds;
}


@end
