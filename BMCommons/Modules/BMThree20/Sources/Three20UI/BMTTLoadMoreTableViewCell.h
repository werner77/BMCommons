//
//  BMTTLoadMoreTableViewCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/11/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMTTLoadMoreTableViewCell : UITableViewCell {
    UIActivityIndicatorView *activityIndicator;
    BOOL canLoadMore;
    UILabel *titleLabel;
    UILabel *subTitleLabel;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *subTitleLabel;

- (void)constructWithShownCount:(NSInteger)shownCount totalCount:(NSInteger)totalCount;
- (void)setAnimating:(BOOL)animating;

@end
