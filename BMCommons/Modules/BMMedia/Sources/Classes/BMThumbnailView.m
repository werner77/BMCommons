//
//  BMThumbnailView.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMThumbnailView.h>
#import <BMMedia/BMVideoOverlayView.h>
#import <BMMedia/BMMedia.h>

@interface BMThumbnailView()

@property (nonatomic, strong) UIView *overlayView;

@end

@implementation BMThumbnailView {
    UIView *overlayView;
}

@synthesize overlayView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        self.placeHolderImage = BMSTYLEVAR(asyncImageButtonPlaceHolderImage);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

    }
    return self;
}

- (void)setVideo:(BOOL)video {
    [super setVideo:video];
    [self displayOverlayIfNeeded];
}

- (void)setThumbURL:(NSString *)thumbURL {
    [super setThumbURL:thumbURL];
    self.overlayView.hidden = (thumbURL == nil);
}

- (void)displayOverlayIfNeeded {
    Class overlayClass = nil;
    BOOL overlayEnabled = YES;
    if (self.isVideo) {
        overlayClass = [BMVideoOverlayView class];
    } else {
        overlayEnabled = NO;
    }
    [self setDisplayOverlay:overlayEnabled withViewClass:overlayClass];
}

- (void)setOverlayView:(UIView *)theOverlayView {
	[overlayView removeFromSuperview];
	overlayView = nil;
	if (theOverlayView) {
		overlayView = theOverlayView;
		[self addSubview:overlayView];
	}
}

- (void)setDisplayOverlay:(BOOL)overlayEnabled withViewClass:(Class)theClass {
	if (theClass && overlayEnabled && ![self.overlayView isKindOfClass:theClass]) {
		self.overlayView = [[theClass alloc]
							 initWithFrame:self.bounds];
		self.overlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.overlayView.hidden = self.thumbURL == nil;
	} else if (!overlayEnabled && self.overlayView) {
		self.overlayView = nil;
	}
}

@end
