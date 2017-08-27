//
//  BMAsyncLoadingImageButton.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAsyncLoadingImageButton.h>
#import <BMCommons/BMAsyncImageLoader.h>
#import <BMCommons/UIButton+BMCommons.h>
#import <BMCommons/BMUICore.h>

@interface BMAsyncLoadingImageButton() <BMAsyncDataLoaderDelegate>

@end

@implementation BMAsyncLoadingImageButton {
	BMAsyncImageLoader *imageLoader;
	UIImage *placeHolderImage;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIImageView *imageView;
    __weak id target;
    SEL action;
    UIView *overlayView;
    BOOL enabled;
    BOOL highlighted;
    id context;
    BOOL adjustsImageWhenDisabled;
    BOOL adjustsImageWhenHighlighted;
    BOOL showActivity;
}

@synthesize activityIndicator, placeHolderImage, imageView, enabled, highlighted, context, adjustsImageWhenDisabled, adjustsImageWhenHighlighted, showActivity;

- (id)initWithURL:(NSURL *)theURL {
    if ((self = [self initWithFrame:CGRectZero])) {

        self.url = theURL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {

        self.userInteractionEnabled = YES;
        enabled = YES;
        self.adjustsImageWhenDisabled = YES;
        self.adjustsImageWhenHighlighted = YES;
        self.placeHolderImage = BMSTYLEVAR(asyncImageButtonPlaceHolderImage);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        enabled = YES;
        self.adjustsImageWhenDisabled = YES;
        self.adjustsImageWhenHighlighted = YES;
        self.placeHolderImage = BMSTYLEVAR(asyncImageButtonPlaceHolderImage);
        [self setupImageView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupImageView];
}

- (void)dealloc {
    imageLoader.delegate = nil;
    [imageLoader cancelLoading];
    BM_RELEASE_SAFELY(placeHolderImage);
    BM_RELEASE_SAFELY(imageLoader);
    BM_RELEASE_SAFELY(activityIndicator);
    BM_RELEASE_SAFELY(imageView);
    BM_RELEASE_SAFELY(overlayView);
    BM_RELEASE_SAFELY(context);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.activityIndicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.imageView.frame = self.bounds;
}

- (void)setEnabled:(BOOL)b {
    if (enabled != b) {
        enabled = b;
        [overlayView removeFromSuperview];
        BM_RELEASE_SAFELY(overlayView);
        if (!enabled && self.adjustsImageWhenDisabled) {
            overlayView = [[UIView alloc] initWithFrame:self.bounds];
            overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            [self addSubview:overlayView];
        } 
    }
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)b {
    if (b != adjustsImageWhenHighlighted) {
        adjustsImageWhenHighlighted = b;
        
        BOOL isHighlighted = self.isHighlighted;
        [self setHighlighted:!isHighlighted];
        [self setHighlighted:isHighlighted];
    }
}

- (void)setAdjustsImageWhenDisabled:(BOOL)b {
    if (b != adjustsImageWhenDisabled) {
        adjustsImageWhenDisabled = b;
        
        BOOL isEnabled = self.isEnabled;
        [self setEnabled:!isEnabled];
        [self setEnabled:isEnabled];
    }
}

- (void)setUrl:(NSURL *)theURL {
    if (![imageLoader.url isEqual:theURL]) {
        [self stopLoading];
        BM_RELEASE_SAFELY(imageLoader);
        if (theURL) {
            imageLoader = [[BMAsyncImageLoader alloc] initWithURL:theURL];
            imageLoader.delegate = self;
        }

    }
}

- (NSURL *)url {
    return imageLoader.url;
}

- (void)setImage:(UIImage *)theImage {
    [self.imageView setImage:theImage];
}

- (UIImage *)image {
    return [self.imageView image];
}

- (void)setPlaceHolderImage:(UIImage *)theImage {
    if (placeHolderImage != theImage) {
        placeHolderImage = nil;
        if (theImage) {
            placeHolderImage = theImage;
            if (!self.image) {
                self.image = placeHolderImage;
            }
        }
    }
}

- (void)startLoadingByShowingPlaceHolder:(BOOL)showPlaceHolder {
    UIImage *cachedImage = (UIImage *) [imageLoader cachedObject];
    if (cachedImage) {
        self.image = cachedImage;
        [self.activityIndicator stopAnimating];
    } else {
        if (!self.image || showPlaceHolder) {
            self.image = self.placeHolderImage;
        }
        [imageLoader startLoading];
        if (self.showActivity) {
            [self.activityIndicator startAnimating];
        }
    }
}

- (void)startLoading {
    [self startLoadingByShowingPlaceHolder:YES];
}

- (void)stopLoading {
    imageLoader.delegate = nil;
    [imageLoader cancelLoading];
    [self.activityIndicator stopAnimating];
}

- (void)setShowActivity:(BOOL)show {
    showActivity = show;
    if (!show) {
        [self.activityIndicator stopAnimating];
    }
}

- (void)setTarget:(id)theTarget action:(SEL)theAction {
    target = theTarget;
    action = theAction;
}

- (void)onTap {
    if (self.isEnabled) {
        BM_IGNORE_SELECTOR_LEAK_WARNING(
        [target performSelector:action withObject:self];
        )
    }
}

#pragma mark -
#pragma mark Touch handling

- (BOOL)isTouchInsideBounds:(UITouch *)touch {
    if (touch) {
        return CGRectContainsPoint(self.bounds, [touch locationInView:self]);
    } else {
        return NO;
    }
}

- (void)setHighlighted:(BOOL)h {
    if (highlighted != h) {
        highlighted = h;
    }
    if (self.isEnabled) {
        [overlayView removeFromSuperview];
        BM_RELEASE_SAFELY(overlayView);
        if (h && self.adjustsImageWhenHighlighted) {
            overlayView = [[UIView alloc] initWithFrame:self.bounds];
            overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
            [self addSubview:overlayView];
        }    
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isTouchInsideBounds:[touches anyObject]]) {
        [self setHighlighted:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:[self isTouchInsideBounds:[touches anyObject]]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isTouchInsideBounds:[touches anyObject]]) {
        [self onTap];
    }
    [self setHighlighted:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:NO];
}

#pragma mark -
#pragma mark AsyncDataLoaderDelegate

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(NSError *)error {
    UIImage *theImage = self.placeHolderImage;
    if (error) {
        LogWarn(@"Failed loading image for URL: %@: %@", dataLoader.url, error);
    } else {
        theImage = (UIImage *)dataLoader.object;
    }
    self.image = theImage;
    [self.activityIndicator stopAnimating];
}

#pragma mark - Private

- (void)setupImageView {
    if (self.imageView == nil) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.imageView];
    }
}

@end
