//
//  BMTableFooterDragLoadMoreView.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTableFooterDragLoadMoreView.h>
#import <QuartzCore/QuartzCore.h>
#import <BMCommons/BMUICore.h>

@implementation BMTableFooterDragLoadMoreView {
    UILabel*                  _countLabel;
    UILabel*                  _statusLabel;
    UIImageView*              _arrowImage;
    UIActivityIndicatorView*  _activityView;
    BMTableFooterDragLoadMoreStatus _status;
    NSString *_itemName;
    NSString *_itemsName;
}

@synthesize itemName = _itemName, itemsName = _itemsName;

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
    
    _countLabel.font = BMSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
    _countLabel.textColor = BMSTYLEVAR(tableRefreshHeaderTextColor);
    _countLabel.shadowColor = BMSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _countLabel.shadowOffset = BMSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    
    _statusLabel.font = BMSTYLEVAR(tableRefreshHeaderStatusFont);
    _statusLabel.textColor = BMSTYLEVAR(tableRefreshHeaderTextColor);
    _statusLabel.shadowColor = BMSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _statusLabel.shadowOffset = BMSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    
    UIImage *arrowImage = BMSTYLEVAR(tableRefreshHeaderArrowImage);
    _arrowImage.frame = CGRectMake(25.0f, self.frame.size.height - 55.0f,
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
        
        _countLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                                                      frame.size.width, 20.0f)];
        _countLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLabel];
        
        _statusLabel = [[UILabel alloc]
                        initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                                                 frame.size.width, 20.0f)];
        _statusLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [self setStatus:BMTableFooterDragLoadMorePullToLoad];
        [self addSubview:_statusLabel];
        
        UIImage *arrowImage = BMSTYLEVAR(tableRefreshHeaderArrowImage);
        _arrowImage = [[UIImageView alloc]
                       initWithFrame:CGRectMake(25.0f, frame.size.height - 55.0f,
                                                arrowImage.size.width, arrowImage.size.height)];
        _arrowImage.image = arrowImage;
        [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        [self addSubview:_arrowImage];
        
        _activityView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:BMSTYLEVAR(tableRefreshHeaderActivityIndicatorStyle)];
        _activityView.frame = CGRectMake(30.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        _activityView.hidesWhenStopped = YES;
        [self addSubview:_activityView];
                
        self.itemName = BMUICoreLocalizedString(@"dragloadmoreview.text.item", @"item");
        self.itemsName = BMUICoreLocalizedString(@"dragloadmoreview.text.items", @"items");
        
        [self applyStyle];
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(_itemsName);
    BM_RELEASE_SAFELY(_itemName);
    BM_RELEASE_SAFELY(_activityView);
    BM_RELEASE_SAFELY(_statusLabel);
    BM_RELEASE_SAFELY(_arrowImage);
    BM_RELEASE_SAFELY(_countLabel);
}

- (NSString *)itemNameForCount:(NSInteger)count {
    if (count == 1) {
        return self.itemName ? self.itemName : @"item";
    } else {
        return self.itemsName ? self.itemsName : @"items";
    }
}


#pragma mark -
#pragma mark Public

- (void)setLoadedCount:(NSUInteger)loadedCount withTotalCount:(NSUInteger)totalCount {
    
    self.hidden = (loadedCount == 0);
    
    if (loadedCount == totalCount) {
        //Cannot load more
        [self setStatus:BMTableFooterDragLoadMoreNothingMoreToLoad];
        _countLabel.text = [NSString stringWithFormat:
                            @"%tu %@ %@",
                            totalCount,
                            [self itemNameForCount:totalCount],
                            BMUICoreLocalizedString(@"dragloadmoreview.text.total", @"total")];
    } else {
        _countLabel.text = [NSString stringWithFormat:
                            @"%tu %@ %@, %tu %@",
                            totalCount,
                            [self itemNameForCount:totalCount],
                            BMUICoreLocalizedString(@"dragloadmoreview.text.total", @"total"),
                            loadedCount, BMUICoreLocalizedString(@"dragloadmoreview.text.shown", @"shown")];
    }
}

- (void)setStatus:(BMTableFooterDragLoadMoreStatus)status {
    if (status != _status) {
        _status = status;
        switch (_status) {
            case BMTableFooterDragLoadMoreReleaseToLoad:
            {
                [self showActivity:NO animated:NO];
                [self setImageFlipped:NO];
                _statusLabel.text = BMUICoreLocalizedString(@"dragloadmoreview.title.release", @"Release to load more...");
                break;
            }
                
            case BMTableFooterDragLoadMorePullToLoad:
            {
                [self showActivity:NO animated:NO];
                [self setImageFlipped:YES];
                _statusLabel.text = BMUICoreLocalizedString(@"dragloadmoreview.title.pullup", @"Pull up to load more...");
                break;
            }
                
            case BMTableFooterDragLoadMoreLoading:
            {
                [self showActivity:YES animated:YES];
                [self setImageFlipped:YES];
                _statusLabel.text = BMUICoreLocalizedString(@"dragloadmoreview.title.loading", @"Loading more...");
                break;
            }
            case BMTableFooterDragLoadMoreNothingMoreToLoad:
            {
                [self showActivity:NO animated:NO];
                [self setImageFlipped:YES];
                _arrowImage.alpha = 0.0f;
                _statusLabel.text = [NSString stringWithFormat:BMUICoreLocalizedString(@"dragloadmoreview.title.allshown", @"All %@ shown"), [self itemNameForCount:2]];
                break;
            }
            default:
            {
                break;
            }
        }    
    }
}

- (BMTableFooterDragLoadMoreStatus)status {
    return _status;
}

@end
