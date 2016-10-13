//
//  BMTTLoadMoreTableViewCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/11/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMTTLoadMoreTableViewCell.h"

#import "Three20Core/BMTTCorePreprocessorMacros.h"
#import "Three20Core/BMTTGlobalCoreLocale.h"

#define MARGIN 3.0f

@implementation BMTTLoadMoreTableViewCell

@synthesize activityIndicator, titleLabel, subTitleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGIN, self.contentView.bounds.size.width, 20)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor darkGrayColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:titleLabel];
        }
        
        if (!subTitleLabel) {
            subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.contentView.bounds.size.width, 17)];
            subTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            subTitleLabel.backgroundColor = [UIColor clearColor];
            subTitleLabel.font = [UIFont systemFontOfSize:13.0];
            subTitleLabel.textColor = [UIColor grayColor];
            subTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:subTitleLabel];
        }
        
        if (!activityIndicator) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.hidesWhenStopped = YES;
            activityIndicator.tag = 100;
            activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            activityIndicator.center = CGPointMake(self.contentView.frame.size.width - activityIndicator.frame.size.width/2 - 20, self.contentView.frame.size.height/2);
            [self.contentView addSubview:activityIndicator];
        }
    }
    return self;
}

- (void)dealloc {
    [titleLabel release];
    [subTitleLabel release];
    [activityIndicator release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (canLoadMore) {
        titleLabel.frame = CGRectMake(0, MARGIN, self.contentView.bounds.size.width, 20);
        subTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 1, self.contentView.bounds.size.width, 15);
        subTitleLabel.hidden = NO;
    } else {
        subTitleLabel.hidden = YES;
        titleLabel.frame = CGRectMake(0, 8, self.contentView.bounds.size.width, 20);
    }
}

- (void)constructWithShownCount:(NSInteger)shownCount totalCount:(NSInteger)totalCount  {
    canLoadMore = shownCount < totalCount;
    
    NSString* text = canLoadMore ? BMTTLocalizedString(@"Load More...", @"") : @"";
    NSString* caption = nil;
    if (totalCount == -1 || totalCount == shownCount) {
        caption = [NSString stringWithFormat:BMTTLocalizedString(@"Showing %@ items", @""),
                   BMTTFormatInteger(shownCount)];
        
    } else {
        caption = [NSString stringWithFormat:BMTTLocalizedString(@"Showing %@ of %@ items", @""),
                   BMTTFormatInteger(shownCount),
                   BMTTFormatInteger(totalCount)];
    }
    
    self.selectionStyle = canLoadMore ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone;
    titleLabel.text = caption;
    subTitleLabel.text = text;
}


- (void)setAnimating:(BOOL)animating {
    if (animating) {
        [activityIndicator startAnimating];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        [activityIndicator stopAnimating];
    }
}

@end
