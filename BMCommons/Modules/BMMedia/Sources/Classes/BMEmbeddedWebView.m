//
//  BMEmbeddedWebView.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEmbeddedWebView.h>
#import <BMCommons/UIWebView+BMCommons.h>
#import <BMCommons/BMRegexKitLite.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMURLCache.h>
#import <BMMedia/BMMedia.h>

@interface BMEmbeddedWebView()<UIWebViewDelegate>

@end

@interface BMEmbeddedWebView(Private)

- (void)initWebView;
- (void)startAnimating;
- (void)stopAnimating;

@end

@implementation BMEmbeddedWebView {
    UIWebView *webView;
    UIImageView *placeHolderView;
    NSString *url;
    BOOL needsLoading;
    UIImage *loadingImage;
    UIImage *errorImage;
    UIActivityIndicatorView *activityIndicatorView;
    BOOL showActivity;
    BOOL loaded;
}

@synthesize url, needsLoading, placeHolderView, loadingImage, errorImage, activityIndicatorView, webView, showActivity;

- (void)dealloc {
    webView.delegate = nil;
    [webView stopLoading];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        [self initWebView];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:self.activityIndicatorView];
        [self setShowActivity:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

        [self initWebView];
        [self setShowActivity:YES];
    }
    return self;
}

- (void)startLoading {
    NSURL *theUrl = [BMStringHelper urlFromString:self.url];
    if (theUrl) {
        [self prepareLoadingWithPlaceHolder:YES];
        [webView loadRequest:[NSURLRequest requestWithURL:theUrl]];
    }
}

- (void)setUrl:(NSString *)theUrl {
    if (theUrl != url && ![theUrl isEqual:url]) {
        [self stopLoading];
        url = theUrl;
        [self setNeedsLayout];
        [self setNeedsLoading];
    }
}

- (void)stopLoading {
    [webView stopLoading];
    [self stopAnimating];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    webView.frame = self.bounds;
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    if (needsLoading) {
        [self startLoading];
    }
}

- (void)setShowActivity:(BOOL)show {
    showActivity = show;
    if (!show) {
        [self stopAnimating];
    }
}

- (BOOL)isLoaded {
    return loaded;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)theWebview {
    if (webView == theWebview) {
        [self stopAnimating];
        if (placeHolderView.image) {
            [UIView animateWithDuration:BM_FAST_TRANSITION_DURATION animations:^() {
                placeHolderView.alpha = 0.0f;
                webView.alpha = 1.0f;
            }];
        } else {
            placeHolderView.alpha = 0.0f;
            webView.alpha = 1.0f;
        }
        loaded = YES;
    }
}

- (void)webView:(UIWebView *)theWebview didFailLoadWithError:(NSError *)error {
    if (![[error userInfo][NSURLErrorFailingURLStringErrorKey] isEqual:@"about:blank"] &&
        !([error code] == 204 && [[error domain] isEqual:@"WebKitErrorDomain"])
        ) {
        LogDebug(@"Could not load webview: %@", error);
        placeHolderView.image = self.errorImage;
        webView.alpha = 0.0f;
        placeHolderView.alpha = 1.0f;
        [self stopAnimating];
    }
}

@end

@implementation BMEmbeddedWebView(Protected)

- (void)prepareLoadingWithPlaceHolder:(BOOL)showPlaceholder {
    loaded = NO;
    needsLoading = NO;
    webView.alpha = 0.0f;
    placeHolderView.alpha = 1.0f;
    if (showPlaceholder) {
        placeHolderView.image = self.loadingImage;
    } else {
        placeHolderView.image = nil;
    }
    [self startAnimating];
}

- (void)setNeedsLoading {
    needsLoading = YES;
}

@end

@implementation BMEmbeddedWebView(Private)

- (void)startAnimating {
    if (self.showActivity) {
        [self.activityIndicatorView startAnimating];
    }
}

- (void)stopAnimating {
    [self.activityIndicatorView stopAnimating];
}

- (void)initWebView {
    webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [webView bmApplyRTFLabelTemplate];
    webView.userInteractionEnabled = YES;
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    
    webView.delegate = self;
    placeHolderView = [[UIImageView alloc] initWithFrame:self.bounds];
    placeHolderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    placeHolderView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *image = BMSTYLEVAR(embeddedWebViewLoadingImage);
    
    self.loadingImage = image;
    
    image = BMSTYLEVAR(embeddedWebViewErrorImage);
    
    self.errorImage = image;
    [self addSubview:placeHolderView];
    [self addSubview:webView];
}

@end

