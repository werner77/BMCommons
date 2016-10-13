//
//  Asset.m
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAssetThumbnailView.h>
#import <BMCommons/BMAssetTablePickerController.h>
#import <BMCommons/BMMediaThumbnailView.h>
#import "ALAsset+BMMedia.h"
#import <BMMedia/BMMedia.h>

@implementation BMAssetThumbnailView {
	ALAsset *asset;
	UIImageView *overlayView;
    BMMediaThumbnailView *assetImageView;
	BOOL selected;
    id <BMAssetThumbnailViewDelegate> __weak delegate;
}

@synthesize asset;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        BMMediaCheckLicense();
        assetImageView = [[BMMediaThumbnailView alloc] initWithFrame:self.bounds];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
        assetImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:assetImageView];
		
		overlayView = [[UIImageView alloc] initWithFrame:self.bounds];
		[overlayView setImage:BMSTYLEVAR(assetPickerSelectionOverlayImage)];
		[overlayView setHidden:YES];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:overlayView];
		[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection)]];
    }
    return self;
}

-(BOOL)selected {	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    [overlayView setHidden:!_selected];
}

-(void)toggleSelection {
    if (asset) {
        BOOL newStatus = ![self selected];
        if ([self.delegate respondsToSelector:@selector(assetThumbnailView:shouldChangeSelectionStatus:)]) {
            if (![self.delegate assetThumbnailView:self shouldChangeSelectionStatus:newStatus]) {
                return;
            }
        }
        [self setSelected:newStatus];
        if ([self.delegate respondsToSelector:@selector(assetThumbnailView:didChangeSelectionStatus:)]) {
            [self.delegate assetThumbnailView:self didChangeSelectionStatus:newStatus];
        }
    }
}

- (void)setAsset:(ALAsset *)_asset {
    if (asset != _asset) {
        asset = _asset;
        if (asset) {
            [assetImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
            [assetImageView setMediaKind:asset.bmMediaKind];
        } else {
            [assetImageView setImage:nil];
            [self setSelected:NO];
        }
    }
}


@end

