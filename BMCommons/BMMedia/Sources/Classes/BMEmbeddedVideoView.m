//
//  BMEmbeddedVideoView.m
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEmbeddedVideoView.h>
#import <BMUICore/UIWebView+BMCommons.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BMUICore/UIView+BMCommons.h>
#import <BMUICore/BMBusyView.h>
#import <BMCore/BMRegexKitLite.h>
#import <BMMedia/BMMedia.h>
#import <BMMedia/BMMediaHelper.h>
#import <BMUICore/UIScreen+BMCommons.h>

@interface BMEmbeddedVideoView()

@property (nonatomic, strong) UIImage *currentBackgroundImage;

@end

@interface BMEmbeddedVideoView(Private)

- (NSString *)extractedYouTubeVideoIdFromUrl:(NSString *)theUrl;
- (BOOL)isSubviewOfSelf:(UIView *)v;
- (void)registerNotifications;
- (void)deregisterNotifications;
- (BOOL)shouldReload;
- (UIView *)viewFromNotification:(NSNotification *)notification;
- (UIView *)fullscreenViewFromNotification:(NSNotification *)notification;
- (void)loadFromUrl:(NSString *)theUrl withYouTubeVideoId:(NSString *)videoId;
- (void)loadFromUrl:(NSString *)theUrl withYouTubeVideoId:(NSString *)videoId showPlaceHolder:(BOOL)showPlaceHolder;
- (void)showBusyView;
- (void)hideBusyView;
- (void)retrieveDirectYouTubeUrlForVideoId:(NSString *)videoId withSuccess:(void (^) (NSString *url))success failure:(void (^)(NSError *error))failure;

@end

@implementation BMEmbeddedVideoView {
    UIImage *_currentBackgroundImage;
    BMBusyView *busyView;
    NSString *youTubeVideoId;
    CGSize iframeSize;
    BOOL limitTouchArea;
    BOOL playing;
    BOOL showPlaceHolderAfterMovieExit;
    BOOL nativeYouTubeModeEnabled;
    UIInterfaceOrientation orientation;
    UIInterfaceOrientation startOrientation;
    BOOL reloadAfterMovieExit;
    NSString *_youTubeDirectStreamIdentifier;
    id <BMEmbeddedVideoViewDelegate> __weak delegate;
}

@synthesize limitTouchArea, youTubeVideoId, playing, delegate, showPlaceHolderAfterMovieExit, nativeYouTubeModeEnabled;
@synthesize currentBackgroundImage = _currentBackgroundImage;
@synthesize reloadAfterMovieExit;

- (void)dealloc {
    BM_RELEASE_SAFELY(_currentBackgroundImage);
    [self hideBusyView];
    [self deregisterNotifications];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.nativeYouTubeModeEnabled = BMSTYLEVAR(nativeYouTubeModeEnabled);
        BMMediaCheckLicense();
        iframeSize = CGSizeZero;
        orientation = UIInterfaceOrientationPortrait;
        [self registerNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        self.nativeYouTubeModeEnabled = BMSTYLEVAR(nativeYouTubeModeEnabled);
        BMMediaCheckLicense();
        iframeSize = CGSizeZero;
        orientation = UIInterfaceOrientationPortrait;
        [self registerNotifications];
    }
    return self;
}

- (void)startLoading {
    [self startLoadingByShowingPlaceHolder:YES];
}

- (void)startLoadingByShowingPlaceHolder:(BOOL)showPlaceHolder {
    if (self.url || self.youTubeVideoId) {
        iframeSize = self.webView.bounds.size;
        orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        NSString *videoId = self.youTubeVideoId;
        
        if (!videoId) {
            //extract video id from url
            videoId = [self extractedYouTubeVideoIdFromUrl:self.url];
        }
        
        if (videoId) {
            if (self.nativeYouTubeModeEnabled) {
                //Try to get a direct url
                __weak __block BMEmbeddedVideoView *bSelf = self;
                [self retrieveDirectYouTubeUrlForVideoId:videoId withSuccess:^(NSString *theUrl) {
                    [bSelf loadFromUrl:theUrl withYouTubeVideoId:nil showPlaceHolder:showPlaceHolder];
                } failure:^(NSError *error) {
                    [bSelf loadFromUrl:nil withYouTubeVideoId:videoId showPlaceHolder:showPlaceHolder];
                }];
            } else {
                [self loadFromUrl:nil withYouTubeVideoId:videoId showPlaceHolder:showPlaceHolder];
            }
        } else {
            [self loadFromUrl:self.url withYouTubeVideoId:nil showPlaceHolder:showPlaceHolder];
        }
    }
}

- (void)stopLoading {
    [super stopLoading];    
    [BMMediaHelper cancelRetrievingDirectYouTubeUrl:_youTubeDirectStreamIdentifier];
}

- (void)setUrl:(NSString *)theUrl {
    if (theUrl != self.url && ![theUrl isEqual:self.url]) {
        iframeSize = CGSizeZero;
        [self setNeedsLoading];
    }
    [super setUrl:theUrl];
}

- (void)setYouTubeVideoId:(NSString *)theEntryId {
    if (theEntryId != youTubeVideoId && ![theEntryId isEqual:youTubeVideoId]) {
        [self stopLoading];
        youTubeVideoId = theEntryId;
        iframeSize = CGSizeZero;
        [self setNeedsLayout];
        [self setNeedsLoading];
    }
}

- (void)layoutSubviews {
    if (![self isPlaying] && [self shouldReload]) {
        [self setNeedsLoading];
    }
    [super layoutSubviews];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = NO;
    if (self.limitTouchArea) {
        CGFloat playButtonWidth = 100.0f;
        CGFloat playButtonHeight = playButtonWidth;
        
        CGRect playButtonRect = CGRectMake((self.webView.bounds.size.width - playButtonWidth)/2, (self.webView.bounds.size.height - playButtonHeight)/2,
                                           playButtonWidth, playButtonHeight);
        
        CGPoint thePoint = [self.webView convertPoint:point fromView:self];
        
        inside = CGRectContainsPoint(playButtonRect, thePoint);
    } else {
        inside = [super pointInside:point withEvent:event];
    }
    
    return inside;
}

#pragma mark - Notifications

- (void)moviePlayerDidEnterFullscreen:(NSNotification *)notification {
    UIView *v = [self viewFromNotification:notification];
    if ([self isSubviewOfSelf:v]) {
        playing = YES;
        startOrientation = BMInterfaceOrientation();
        if ([self.delegate respondsToSelector:@selector(embeddedVideoViewDidEnterFullscreen:)]) {
            [self.delegate embeddedVideoViewDidEnterFullscreen:self];
        }
    }
}

- (void)moviePlayerWillExitFullscreen:(NSNotification *)notification {
    UIView *v = [self viewFromNotification:notification];
    if ([self isSubviewOfSelf:v]) {
        
        UIView *fullscreenView = [self fullscreenViewFromNotification:notification];
        
        self.currentBackgroundImage = [fullscreenView bmContentsAsImage];
        
        if (self.showPlaceHolderAfterMovieExit) {
            [self showBusyView];
        }
        
        if ([self.delegate respondsToSelector:@selector(embeddedVideoViewWillExitFullscreen:)]) {
            [self.delegate embeddedVideoViewWillExitFullscreen:self];
        }
    }
}

- (void)moviePlayerDidExitFullscreen:(NSNotification *)notification {
    UIView *v = [self viewFromNotification:notification];
    if ([self isSubviewOfSelf:v]) {
        playing = NO;
        
        //id player = [notification object];
        //UIView *movieView = [player movieView];
        
        //movieView.hidden = NO;
        
        [self hideBusyView];
        
        if (self.reloadAfterMovieExit) {
            [self startLoadingByShowingPlaceHolder:NO];
        }
        
        if ([self.delegate respondsToSelector:@selector(embeddedVideoViewDidExitFullscreen:)]) {
            [self.delegate embeddedVideoViewDidExitFullscreen:self];
        }
    }
}

@end

@implementation BMEmbeddedVideoView(Private)

- (void)startLoadingWithoutPlaceholder {
    [self startLoadingByShowingPlaceHolder:NO];
}

- (void)showBusyView {
    if (!busyView) {
        UIWindow *modalWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bmPortraitBounds];
        modalWindow.windowLevel = UIWindowLevelAlert;
        busyView = [[BMBusyView alloc] initWithSuperView:modalWindow];
        [busyView showAnimated:NO];
        
        UIImage *image = self.currentBackgroundImage;
        
        if (!image) image = self.placeHolderView.image;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        [imageView addSubview:activityIndicator];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = busyView.bounds;
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        activityIndicator.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
        
        [busyView addSubview:imageView];
    }
}

- (void)hideBusyView {
    if (busyView) {
        [busyView hideAnimated:YES];
        BM_RELEASE_SAFELY(busyView);
    }
}

- (void)loadFromUrl:(NSString *)theUrl withYouTubeVideoId:(NSString *)videoId {
    [self loadFromUrl:theUrl withYouTubeVideoId:videoId showPlaceHolder:YES];
}

- (void)loadFromUrl:(NSString *)theUrl withYouTubeVideoId:(NSString *)videoId showPlaceHolder:(BOOL)showPlaceHolder {
    NSString *html = nil;
    NSString* embedHTML = nil;
    
    NSString *widthString = @"100%";
    NSString *heightString = @"100%";
    
    NSString *style = [NSString stringWithFormat:@"display: block; position: relative; width: %@; height: %@", widthString, heightString];
    if (videoId) {
        embedHTML = @"<html><head><style type=\"text/css\">"
            @"body {background-color: transparent; color: black}"
            @"</style></head>"
            @"<body style=\"margin:0\">"
            @"<iframe id=\"yt\" type=\"text/html\" "
            @"src=\"http://www.youtube.com/embed/%@?showsearch=0&hd=1&rel=0&iv_load_policy=3&modestbranding=1&showinfo=0&origin=http://www.behindthefrontdoor.com\" "
            @"style=\"%@\" "
            @"frameborder=\"0\" allowfullscreen></iframe>"
            @"</body></html>";
        html = [NSString stringWithFormat:embedHTML, videoId, style];
    } else {
        embedHTML = @"<html><head><style type=\"text/css\">"
        @"body {background-color: transparent; color: black}"
        @"</style></head>"
        @"<body style=\"margin:0\">"
        @"<embed id=\"yt\" src=\"%@\" style=\"%@\" scale=\"aspect\"></embed>"
        @"</body></html>";
        html = [NSString stringWithFormat:embedHTML, theUrl, style];
    }
    [self prepareLoadingWithPlaceHolder:showPlaceHolder];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)retrieveDirectYouTubeUrlForVideoId:(NSString *)videoId withSuccess:(void (^) (NSString *theUrl))success failure:(void (^)(NSError *theError))failure {
    _youTubeDirectStreamIdentifier = [BMMediaHelper retrieveDirectYouTubeUrlForVideoId:videoId withSuccess:^(NSString *theUrl) {
        success(theUrl);
        _youTubeDirectStreamIdentifier = nil;
    } failure:^(NSError *theError) {
        failure(theError);
        _youTubeDirectStreamIdentifier = nil;
    }];
}

- (void)fadeOutPlaceHolderView:(UIView *)v {
    [UIView animateWithDuration:0.2 animations:^() {
        v.alpha = 0.0;
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
    }];
}

- (NSString *)extractedYouTubeVideoIdFromUrl:(NSString *)theUrl {
    return [BMMediaHelper extractedYouTubeVideoIdFromUrl:theUrl];
}

- (BOOL)shouldReload {
    return UIInterfaceOrientationIsLandscape(orientation) && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

- (BOOL)isSubviewOfSelf:(UIView *)v {
    while (v != nil) {
        v = [v superview];
        if (v == self) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)viewFromNotification:(NSNotification *)notification {
    id player = [notification object];
    UIView *v = nil;
    SEL viewSelector = NSSelectorFromString(@"view");
    if ([player respondsToSelector:viewSelector]) {
        v = [player performSelector:viewSelector];
    }
    return v;
}

- (UIView *)fullscreenViewFromNotification:(NSNotification *)notification {
    id player = [notification object];
    UIView *v = nil;
    SEL fullScreenSelector = NSSelectorFromString(@"fullscreenView");
    if ([player respondsToSelector:fullScreenSelector]) {
        v = [player performSelector:fullScreenSelector];
    }
    return v;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidEnterFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillExitFullscreen:) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidExitFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
}

- (void)deregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}

@end
