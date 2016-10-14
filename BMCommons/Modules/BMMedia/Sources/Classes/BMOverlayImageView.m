//
//  BMOverlayImageView.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/21/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMOverlayImageView.h>
#import <BMMedia/BMMedia.h>

@implementation BMOverlayImageView {
	UIView *overlayView;
}

@synthesize overlayView;

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

- (void)dealloc {
	self.overlayView = nil;
}

- (void)setImage:(UIImage *)theImage {
	overlayView.hidden = (theImage == nil);
	[super setImage:theImage];
}

- (void)setOverlayView:(UIView *)theOverlayView {
	[overlayView removeFromSuperview];
	overlayView = nil;
	if (theOverlayView) {
		overlayView = theOverlayView;
		[self addSubview:overlayView];
	}
}

- (void)setImage:(UIImage *)theImage withOverlayView:(UIView *)theOverlayView {
	[self setImage:theImage];
	[self setOverlayView:theOverlayView];
}


@end
