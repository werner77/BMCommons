//
//  BMTableHeaderDragRefreshView.h
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BMTableHeaderDragRefreshView.h"
#import "BMStyleSheet.h"
#import <BMCommons/BMUICore.h>

@implementation BMTableHeaderDragRefreshView {
    NSDate*                   _lastUpdatedDate;
    UILabel*                  _lastUpdatedLabel;
    UILabel*                  _statusLabel;
    UIImageView*              _arrowImage;
    UIActivityIndicatorView*  _activityView;
    BMTableHeaderDragRefreshStatus _status;
}

#pragma mark -
#pragma mark Private


- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow) {
        [_activityView startAnimating];

    } else {
        [_activityView stopAnimating];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:(animated ? BM_FAST_TRANSITION_DURATION : 0.0)];
    _arrowImage.alpha = (shouldShow ? 0.0 : 1.0);
    [UIView commitAnimations];
}


- (void)setImageFlipped:(BOOL)flipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:BM_FAST_TRANSITION_DURATION];
    [_arrowImage layer].transform = (flipped ?
            CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) :
            CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
    [UIView commitAnimations];
}


#pragma mark -
#pragma mark NSObject

- (void)applyStyle {
    
    _lastUpdatedLabel.font = BMSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
    _lastUpdatedLabel.textColor = BMSTYLEVAR(tableRefreshHeaderTextColor);
    _lastUpdatedLabel.shadowColor = BMSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _lastUpdatedLabel.shadowOffset = BMSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    
    _statusLabel.font = BMSTYLEVAR(tableRefreshHeaderStatusFont);
    _statusLabel.textColor = BMSTYLEVAR(tableRefreshHeaderTextColor);
    _statusLabel.shadowColor = BMSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _statusLabel.shadowOffset = BMSTYLEVAR(tableRefreshHeaderTextShadowOffset);

    UIImage *arrowImage = BMSTYLEVAR(tableRefreshHeaderArrowImage);
    _arrowImage.frame = CGRectMake(25.0f, self.frame.size.height - 60.0f,
                                            arrowImage.size.width, arrowImage.size.height);
    _arrowImage.image = arrowImage;
    self.backgroundColor = BMSTYLEVAR(tableRefreshHeaderBackgroundColor);
}

- (void)applyStyleSheet:(BMStyleSheet *)styleSheet {
    [BMStyleSheet pushStyleSheet:styleSheet];
    [self applyStyle];
    [BMStyleSheet popStyleSheet];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        BMUICoreCheckLicense();
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _lastUpdatedLabel = [[UILabel alloc]
                initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                        frame.size.width, 20.0f)];
        _lastUpdatedLabel.autoresizingMask =
                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdatedLabel];

        _statusLabel = [[UILabel alloc]
                initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                        frame.size.width, 20.0f)];
        _statusLabel.autoresizingMask =
                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [self setStatus:BMTableHeaderDragRefreshPullToReload];
        [self addSubview:_statusLabel];

        UIImage *arrowImage = BMSTYLEVAR(tableRefreshHeaderArrowImage);
        _arrowImage = [[UIImageView alloc]
                initWithFrame:CGRectMake(25.0f, frame.size.height - 60.0f,
                        arrowImage.size.width, arrowImage.size.height)];
        _arrowImage.image = arrowImage;
        [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        [self addSubview:_arrowImage];

        _activityView = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:BMSTYLEVAR(tableRefreshHeaderActivityIndicatorStyle)];
        _activityView.frame = CGRectMake(30.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        _activityView.hidesWhenStopped = YES;
        [self addSubview:_activityView];

        [self applyStyle];
    }
    return self;
}


- (void)dealloc {
    BM_RELEASE_SAFELY(_activityView);
    BM_RELEASE_SAFELY(_statusLabel);
    BM_RELEASE_SAFELY(_arrowImage);
    BM_RELEASE_SAFELY(_lastUpdatedLabel);
    BM_RELEASE_SAFELY(_lastUpdatedDate);
}


#pragma mark -
#pragma mark Public


- (void)setUpdateDate:(NSDate *)newDate {
    if (newDate) {

        _lastUpdatedDate = newDate;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[BMLocalization sharedInstance].currentLocale];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@",
                BMUICoreLocalizedString(@"dragrefreshview.title.lastupdated", @"Last updated"),
                [formatter stringFromDate:_lastUpdatedDate]];

    } else {
        _lastUpdatedDate = nil;
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@",
                                  BMUICoreLocalizedString(@"dragrefreshview.title.lastupdated", @"Last updated"),
                                  BMUICoreLocalizedString(@"dragrefreshview.text.never", @"never")];
    }
}

- (void)setCurrentDate {
    [self setUpdateDate:[NSDate date]];
}

- (void)setStatus:(BMTableHeaderDragRefreshStatus)status {
    _status = status;
    switch (_status) {
        case BMTableHeaderDragRefreshReleaseToReload:
        {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:YES];
            _statusLabel.text = BMUICoreLocalizedString(@"dragrefreshview.title.release", @"Release to update...");
            break;
        }

        case BMTableHeaderDragRefreshPullToReload:
        {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:NO];
            _statusLabel.text = BMUICoreLocalizedString(@"dragrefreshview.title.pulldown", @"Pull down to update...");
            break;
        }

        case BMTableHeaderDragRefreshLoading:
        {
            [self showActivity:YES animated:YES];
            [self setImageFlipped:NO];
            _statusLabel.text = BMUICoreLocalizedString(@"dragrefreshview.title.updating", @"Updating...");
            break;
        }

        default:
        {
            break;
        }
    }
}

- (BMTableHeaderDragRefreshStatus)status {
    return _status;
}

@end
