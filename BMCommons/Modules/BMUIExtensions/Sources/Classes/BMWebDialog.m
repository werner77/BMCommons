/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import <BMCommons/BMWebDialog.h>
#import <BMCommons/UIScreen+BMCommons.h>

@interface BMWebDialog () <UIWebViewDelegate>

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString *kDialogIconImage = @"dialogIcon.png";
static NSString *kDialogCloseImage = @"dialogClose.png";

static CGFloat kFillColor[4] = {0.42578125, 0.515625, 0.703125, 1.0};
static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
static CGFloat kBorderBlue[4] = {0.23, 0.35, 0.6, 1.0};

static CGFloat kTransitionDuration = 0.3;

static CGFloat kTitleMarginX = 8;
static CGFloat kTitleMarginY = 4;
static CGFloat kPadding = 10;
static CGFloat kBorderWidth = 10;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BMWebDialog {
    NSURL *_loadingURL;
    UIWebView *_webView;
    UIActivityIndicatorView *_spinner;
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UIButton *_closeButton;
    UIDeviceOrientation _orientation;
    BOOL _showingKeyboard;
}

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
    CGContextBeginPath(context);
    CGContextSaveGState(context);

    if (radius == 0) {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
    } else {
        rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
        CGContextTranslateCTM(context, CGRectGetMinX(rect) - 0.5, CGRectGetMinY(rect) - 0.5);
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;

        CGContextMoveToPoint(context, fw, fh / 2);
        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);
    }

    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fillColor:(UIColor *)color radius:(CGFloat)radius {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    if (color) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        if (radius) {
            [self addRoundedRectToPath:context rect:rect radius:radius];
            CGContextFillPath(context);
        } else {
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }

    CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect strokeColor:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGContextSaveGState(context);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, 1.0);

    {
        CGPoint points[] = {{(CGFloat) (rect.origin.x + 0.5), (CGFloat) (rect.origin.y - 0.5)},
                {rect.origin.x + rect.size.width, (CGFloat) (rect.origin.y - 0.5)}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{(CGFloat) (rect.origin.x + 0.5), (CGFloat) (rect.origin.y + rect.size.height - 0.5)},
                {(CGFloat) (rect.origin.x + rect.size.width - 0.5), (CGFloat) (rect.origin.y + rect.size.height - 0.5)}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{(CGFloat) (rect.origin.x + rect.size.width - 0.5), rect.origin.y},
                {(CGFloat) (rect.origin.x + rect.size.width - 0.5), rect.origin.y + rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{(CGFloat) (rect.origin.x + 0.5), rect.origin.y},
                {(CGFloat) (rect.origin.x + 0.5), rect.origin.y + rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }

    CGContextRestoreGState(context);

    CGColorSpaceRelease(space);
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    if (orientation == _orientation) {
        return NO;
    } else {
        return orientation == UIDeviceOrientationLandscapeLeft
                || orientation == UIDeviceOrientationLandscapeRight
                || orientation == UIDeviceOrientationPortrait
                || orientation == UIDeviceOrientationPortraitUpsideDown;
    }
}

- (CGAffineTransform)transformForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI * 1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI / 2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (void)sizeToFitOrientation:(BOOL)transform {
    if (transform) {
        self.transform = CGAffineTransformIdentity;
    }

    CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
    CGPoint center = CGPointMake(
            frame.origin.x + ceil(frame.size.width / 2),
            frame.origin.y + ceil(frame.size.height / 2));

    CGFloat width = frame.size.width - kPadding * 2;
    CGFloat height = frame.size.height - kPadding * 2;

    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    _orientation = (UIDeviceOrientation) interfaceOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.frame = CGRectMake(kPadding, kPadding, height, width);
    } else {
        self.frame = CGRectMake(kPadding, kPadding, width, height);
    }
    self.center = center;

    if (transform) {
        self.transform = [self transformForOrientation];
    }
}

- (void)updateWebOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_webView stringByEvaluatingJavaScriptFromString:
                @"document.body.setAttribute('orientation', 90);"];
    } else {
        [_webView stringByEvaluatingJavaScriptFromString:
                @"document.body.removeAttribute('orientation');"];
    }
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration / 2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration / 2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)postDismissCleanup {
    [self removeObservers];
    [self removeFromSuperview];
}

- (void)dismiss:(BOOL)animated {
    [self dialogWillDisappear];

    _loadingURL = nil;

    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
        self.alpha = 0;
        [UIView commitAnimations];
    } else {
        [self postDismissCleanup];
    }
}

- (void)cancel {
    [self dismissWithSuccess:NO animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _delegate = nil;
        _loadingURL = nil;
        _orientation = UIDeviceOrientationUnknown;
        _showingKeyboard = NO;

        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;

        UIImage *iconImage = [UIImage imageNamed:kDialogIconImage];
        UIImage *closeImage = [UIImage imageNamed:kDialogCloseImage];

        _iconView = [[UIImageView alloc] initWithImage:iconImage];
        [self addSubview:_iconView];

        UIColor *color = [UIColor colorWithRed:167.0 / 255 green:184.0 / 255 blue:216.0 / 255 alpha:1];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:closeImage forState:UIControlStateNormal];
        [_closeButton setTitleColor:color forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(cancel)
               forControlEvents:UIControlEventTouchUpInside];
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _closeButton.showsTouchWhenHighlighted = YES;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
                | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_closeButton];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
                | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_titleLabel];

        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_webView];

        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.autoresizingMask =
                UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_spinner];
    }
    return self;
}

- (id)initWithTitle:(NSString *)theTitle {
    if (self = [self initWithFrame:CGRectZero]) {
        self.title = theTitle;
    }
    return self;
}

- (void)dealloc {
    _webView.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
    CGRect grayRect = CGRectOffset(rect, -0.5, -0.5);

    UIColor *color = [UIColor colorWithRed:kBorderGray[0] green:kBorderGray[1] blue:kBorderGray[2] alpha:kBorderGray[3]];

    [self drawRect:grayRect fillColor:color radius:10];

    CGRect headerRect = CGRectMake(
            ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth),
            rect.size.width - kBorderWidth * 2, _titleLabel.frame.size.height);

    color = [UIColor colorWithRed:kFillColor[0] green:kFillColor[1] blue:kFillColor[2] alpha:kFillColor[3]];

    [self drawRect:headerRect fillColor:color radius:0];

    color = [UIColor colorWithRed:kBorderBlue[0] green:kBorderBlue[1] blue:kBorderBlue[2] alpha:kBorderBlue[3]];

    [self strokeLines:headerRect strokeColor:color];

    CGRect webRect = CGRectMake(
            ceil(rect.origin.x + kBorderWidth), headerRect.origin.y + headerRect.size.height,
            rect.size.width - kBorderWidth * 2, _webView.frame.size.height + 1);

    color = [UIColor colorWithRed:kBorderBlack[0] green:kBorderBlack[1] blue:kBorderBlack[2] alpha:kBorderBlack[3]];

    [self strokeLines:webRect strokeColor:color];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:BM_WEBDIALOG_SCHEME]) {
        if ([url.resourceSpecifier isEqualToString:BM_WEBDIALOG_CANCEL_RESOURCE_IDENTIFIER]) {
            [self dismissWithSuccess:NO animated:YES];
        } else {
            [self dialogDidSucceedWithUrl:url];
        }
        return NO;
    } else if ([_loadingURL isEqual:url]) {
        return YES;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([_delegate respondsToSelector:@selector(dialog:shouldOpenURLInExternalBrowser:)]) {
            if (![_delegate dialog:self shouldOpenURLInExternalBrowser:url]) {
                return NO;
            }
        }

        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_spinner stopAnimating];
    _spinner.hidden = YES;

    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateWebOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        [self dismissWithError:error animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void *)object {
    UIDeviceOrientation orientation = (UIDeviceOrientation) [UIApplication sharedApplication].statusBarOrientation;
    if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
        [self updateWebOrientation];

        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [self sizeToFitOrientation:YES];
        [UIView commitAnimations];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _webView.frame = CGRectInset(_webView.frame,
                -(kPadding + kBorderWidth),
                -(kPadding + kBorderWidth) - _titleLabel.frame.size.height);
    }

    _showingKeyboard = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _webView.frame = CGRectInset(_webView.frame,
                kPadding + kBorderWidth,
                kPadding + kBorderWidth + _titleLabel.frame.size.height);
    }

    _showingKeyboard = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)show {
    [self load];
    [self sizeToFitOrientation:NO];

    CGFloat innerWidth = self.frame.size.width - (kBorderWidth + 1) * 2;
    [_iconView sizeToFit];
    [_titleLabel sizeToFit];
    [_closeButton sizeToFit];

    _titleLabel.frame = CGRectMake(
            kBorderWidth + kTitleMarginX + _iconView.frame.size.width + kTitleMarginX,
            kBorderWidth,
            innerWidth - (_titleLabel.frame.size.height + _iconView.frame.size.width + kTitleMarginX * 2),
            _titleLabel.frame.size.height + kTitleMarginY * 2);

    _iconView.frame = CGRectMake(
            kBorderWidth + kTitleMarginX,
            kBorderWidth + floor(_titleLabel.frame.size.height / 2 - _iconView.frame.size.height / 2),
            _iconView.frame.size.width,
            _iconView.frame.size.height);

    _closeButton.frame = CGRectMake(
            self.frame.size.width - (_titleLabel.frame.size.height + kBorderWidth),
            kBorderWidth,
            _titleLabel.frame.size.height,
            _titleLabel.frame.size.height);

    _webView.frame = CGRectMake(
            kBorderWidth + 1,
            kBorderWidth + _titleLabel.frame.size.height,
            innerWidth,
            self.frame.size.height - (_titleLabel.frame.size.height + 1 + kBorderWidth * 2));

    [_spinner sizeToFit];
    [_spinner startAnimating];
    _spinner.center = _webView.center;

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = ([UIApplication sharedApplication].windows)[0];
    }
    [window addSubview:self];

    [self dialogWillAppear];

    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration / 1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];

    [self addObservers];
}

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated {
    if (success) {
        if ([_delegate respondsToSelector:@selector(dialogDidSucceed:)]) {
            [_delegate dialogDidSucceed:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(dialogDidCancel:)]) {
            [_delegate dialogDidCancel:self];
        }
    }

    [self dismiss:animated];
}

- (void)dismissWithError:(NSError *)error animated:(BOOL)animated {
    if ([_delegate respondsToSelector:@selector(dialog:didFailWithError:)]) {
        [_delegate dialog:self didFailWithError:error];
    }

    [self dismiss:animated];
}

- (void)load {
    // Intended for subclasses to override
}

- (void)loadRequest:(NSURLRequest *)request {
    [_webView loadRequest:request];
}

- (void)dialogWillAppear {
}

- (void)dialogWillDisappear {
}

- (void)dialogDidSucceedWithUrl:(NSURL *)url {
    [self dismissWithSuccess:YES animated:YES];
}

@end
