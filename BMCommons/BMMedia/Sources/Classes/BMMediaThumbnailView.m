//
//  BMMediaThumbnailView.m
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMMediaThumbnailView.h"
#import "BMVideoOverlayView.h"
#import "BMAudioOverlayView.h"
#import <BMMedia/BMMedia.h>

@interface BMMediaThumbnailView(Private)

- (void)setDisplayOverlay:(BOOL)overlayEnabled withViewClass:(Class)theClass;

@end

@implementation BMMediaThumbnailView {
	BMMediaKind mediaKind;
}

@synthesize mediaKind;

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        BMMediaCheckLicense();
    }
    return self;
}


- (void)setImageFromMedia:(id <BMMediaContainer>)media {
    self.image = media.thumbnailImage;
	self.mediaKind = media.mediaKind;
}

- (void)setMediaKind:(BMMediaKind)theMediaKind {
	mediaKind = theMediaKind;
	Class overlayClass = nil;
	BOOL overlayEnabled = YES;
	if (mediaKind == BMMediaKindVideo) {
		overlayClass = [BMVideoOverlayView class];
	} else if (mediaKind == BMMediaKindAudio) {
		// audio overlay disabled for now...
		overlayClass = [BMAudioOverlayView class];
	} else {
		overlayEnabled = NO;
	}
	[self setDisplayOverlay:overlayEnabled withViewClass:overlayClass];
}

@end

@implementation BMMediaThumbnailView(Private)

- (void)setDisplayOverlay:(BOOL)overlayEnabled withViewClass:(Class)theClass {
	if (theClass && overlayEnabled && ![self.overlayView isKindOfClass:theClass]) {
		self.overlayView = [[theClass alloc] 
							 initWithFrame:self.bounds];
		self.overlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.overlayView.hidden = (self.image == nil);
	} else if (!overlayEnabled && self.overlayView) {
		self.overlayView = nil;
	}
}

@end
