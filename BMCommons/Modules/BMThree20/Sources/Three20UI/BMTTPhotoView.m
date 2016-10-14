//
//  PhotoView.m
//  BTFD
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "Three20UI/BMTTPhotoView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <BMCommons/BMCore.h>
#import "UIViewAdditions.h"
#import "Three20UI/BMTTPhotoSource.h"
#import "Three20UI/BMTTLabel.h"

#import "Three20Style/BMTTGlobalStyle.h"
#import <BMCommons/BMUICore.h>

@implementation BMTTPhotoView

@synthesize photo         = _photo;
@synthesize hidesExtras   = _hidesExtras;
@synthesize hidesCaption  = _hidesCaption;
@synthesize defaultImage  = _defaultImage;
@synthesize captionStyle = _captionStyle;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        _photoVersion = BMTTPhotoVersionNone;
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BM_RELEASE_SAFELY(_photo);
    BM_RELEASE_SAFELY(_captionLabel);
    BM_RELEASE_SAFELY(_statusSpinner);
    BM_RELEASE_SAFELY(_statusLabel);
    BM_RELEASE_SAFELY(_captionStyle);
    BM_RELEASE_SAFELY(_defaultImage);
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadVersion:(BMTTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
    return NO;
}

- (void)layoutSubviews {
	CGRect screenBounds = BMScreenBounds();
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGFloat cx = self.bounds.origin.x + width/2;
    CGFloat cy = self.bounds.origin.y + height/2;
    CGFloat marginRight = 0, marginLeft = 0, marginBottom = BMToolbarHeight();
    
    // Since the photo view is constrained to the size of the image, but we want to position
    // the status views relative to the screen, offset by the difference
    CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);
    
    // Vertically center in the space between the bottom of the image and the bottom of the screen
    CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
    CGFloat textWidth = screenBounds.size.width - (marginLeft+marginRight);
    
    if (_statusLabel.text.length) {
        CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(textWidth, 0)];
        _statusLabel.frame =
        CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                   cy + floor(screenBounds.size.height/2 - (statusSize.height+marginBottom)),
                   textWidth, statusSize.height);
        
    } else {
        _statusLabel.frame = CGRectZero;
    }
    
    if (_captionLabel.text.length) {
        CGSize captionSize = [_captionLabel sizeThatFits:CGSizeMake(textWidth, 0)];
        _captionLabel.frame = CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                                         cy + floor(screenBounds.size.height/2
                                                    - (captionSize.height+marginBottom)),
                                         textWidth, captionSize.height);
        
    } else {
        _captionLabel.frame = CGRectZero;
    }
    
    CGFloat spinnerTop = _captionLabel.height
    ? _captionLabel.top - floor(_statusSpinner.height + _statusSpinner.height/2)
    : screenOffset + imageBottom + floor(_statusSpinner.height/2);
    
    _statusSpinner.frame =
    CGRectMake(self.bounds.origin.x + floor(self.bounds.size.width/2 - _statusSpinner.width/2),
               spinnerTop, _statusSpinner.width, _statusSpinner.height);
}

- (void)setPhoto:(id <BMTTPhoto>)photo {
	if (!photo || photo != _photo) {
        [_photo release];
        _photo = [photo retain];
        _photoVersion = BMTTPhotoVersionNone;
        
        [self showCaption:photo.caption];
        [self setNeedsLayout];
    }
    
    if (!_photo || _photo.photoSource.isLoading) {
        [self showProgress:0];
    } else {
        [self showStatus:nil];
        [self showProgress:-1];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCaption:(NSString*)caption {
    if (caption) {
        if (!_captionLabel) {
            _captionLabel = [[BMTTLabel alloc] init];
            _captionLabel.opaque = NO;
            _captionLabel.style = _captionStyle ? _captionStyle : BMTTSTYLE(photoCaption);
            _captionLabel.alpha = _hidesCaption ? 0 : 1;
            [self addSubview:_captionLabel];
        }
    }
    
    _captionLabel.text = caption;
    [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesExtras:(BOOL)hidesExtras {
    if (!hidesExtras) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:BM_FAST_TRANSITION_DURATION];
    }
    _hidesExtras = hidesExtras;
    _statusSpinner.alpha = _hidesExtras ? 0 : 1;
    _statusLabel.alpha = _hidesExtras ? 0 : 1;
    _captionLabel.alpha = _hidesExtras || _hidesCaption ? 0 : 1;
    if (!hidesExtras) {
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesCaption:(BOOL)hidesCaption {
    _hidesCaption = hidesCaption;
    _captionLabel.alpha = hidesCaption ? 0 : 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
    if (progress >= 0) {
        if (!_statusSpinner) {
            _statusSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleWhiteLarge];
            [self addSubview:_statusSpinner];
        }
        
        [_statusSpinner startAnimating];
        _statusSpinner.hidden = NO;
        [self showStatus:nil];
    } else {
        [_statusSpinner stopAnimating];
        _statusSpinner.hidden = YES;
        _captionLabel.hidden = !!_statusLabel.text.length;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)text {
    if (text) {
        if (!_statusLabel) {
            _statusLabel = [[BMTTLabel alloc] init];
            _statusLabel.style = BMTTSTYLE(photoStatusLabel);
            _statusLabel.opaque = NO;
            [self addSubview:_statusLabel];
        }
        
        _statusLabel.hidden = NO;
        [self showProgress:-1];
        _captionLabel.hidden = YES;
        
    } else {
        _statusLabel.hidden = YES;
        _captionLabel.hidden = NO;
    }
    
    _statusLabel.text = text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadPreview:(BOOL)fromNetwork {
    if (![self loadVersion:BMTTPhotoVersionThumbnail fromNetwork:fromNetwork]) {
        return NO;
    }
    return YES;
}

- (void)loadImage {
    
}

- (BOOL)isLoaded {
    return YES;
}

- (BOOL)isLoading {
    return NO;
}

- (UIImage *)image {
    return nil;
}

@end
