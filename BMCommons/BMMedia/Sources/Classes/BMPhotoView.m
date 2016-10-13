//
//  BMPhotoView.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMPhotoView.h"
#import <BMMedia/BMMediaContainer.h>
#import <BMUICore/UIButton+BMCommons.h>
#import "BMMediaContainerPhoto.h"
#import <MediaPlayer/MediaPlayer.h>
#import <BMThree20/Three20UI/UIViewAdditions.h>
#import <BMCore/BMURLCache.h>
#import <BMMedia/BMEmbeddedVideoView.h>
#import <BMMedia/BMAsyncLoadingMediaThumbnailButton.h>
#import <BMCore/BMAsyncImageLoader.h>
#import <BMMedia/BMMedia.h>
#import <BMCore/BMStringHelper.h>
#import <BMCore/BMBlockServiceDelegate.h>
#import <BMMedia/BMGetYouTubeStreamInfoService.h>
#import <BMMedia/BMMediaHelper.h>
#import <BMCore/NSObject+BMCommons.h>


@interface BMPhotoView() <BMAsyncLoadingMediaThumbnailButtonDelegate, BMAsyncDataLoaderDelegate>

@end

@implementation BMPhotoView {
	//Play button for video
	UIButton *_playButton;
    BMAsyncLoadingMediaThumbnailButton *_imageView;
    
    NSMutableArray *_imageLoaders;
    BMEmbeddedVideoView *_embeddedVideoView;
    
    BMGetYouTubeStreamInfoService *_youTubeService;
}

@synthesize playButton = _playButton;
@synthesize embeddedVideoView = _embeddedVideoView;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        
        BMMediaCheckLicense();
        
        _imageView = [[BMAsyncLoadingMediaThumbnailButton alloc] initWithFrame:self.bounds];
        _imageView.userInteractionEnabled = NO;
        _imageView.delegate = self;
        _imageView.overlayDisabled = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.clipsToBounds = YES;
        _imageView.useFullScreenImages = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.useEmbeddedVideoView = NO;
        
        [self addSubview:_imageView];
        
		UIImage *buttonImage = [UIImage imageNamed:@"BMMedia.bundle/PLVideoOverlayPlay.png"];
        UIImage *buttonHighlightedImage = [UIImage imageNamed:@"BMMedia.bundle/PLVideoOverlayPlayDown.png"];
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playButton setImage:buttonImage forState:UIControlStateNormal];
        [_playButton setImage:buttonHighlightedImage forState:UIControlStateHighlighted];
		[_playButton setFrame:CGRectMake(0,0,buttonImage.size.width, buttonImage.size.height)];
        _playButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
		[self addSubview:_playButton];
        
        _embeddedVideoView = [[BMEmbeddedVideoView alloc] initWithFrame:self.bounds];
        _embeddedVideoView.placeHolderView.contentMode = UIViewContentModeCenter;
        _embeddedVideoView.limitTouchArea = YES;
        _embeddedVideoView.backgroundColor = [UIColor clearColor];
        _embeddedVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_embeddedVideoView];
        
        _imageLoaders = [NSMutableArray new];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (BMAsyncImageLoader *loader in _imageLoaders) {
        [loader cancelLoading];
        loader.delegate = nil;
    }
    [_imageView stopLoading];
    BM_RELEASE_SAFELY(_imageView);
	BM_RELEASE_SAFELY(_playButton);
    BM_RELEASE_SAFELY(_imageLoaders);
    BM_RELEASE_SAFELY(_embeddedVideoView);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadVersion:(BMTTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
    NSString* URL = [_photo URLForVersion:version];
    if (URL) {
        BOOL hasImage = [[BMURLCache sharedCache] hasImageForURL:URL fromDisk:YES];
        if (hasImage || fromNetwork) {
            _photoVersion = version;
            if (!hasImage) {
                //Load the image
                BMAsyncImageLoader *imageLoader = [[BMAsyncImageLoader alloc] initWithURLString:URL];
                imageLoader.delegate = self;
                [_imageLoaders addObject:imageLoader];
                [imageLoader startLoading];
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark - BMAsyncDataLoaderDelegate

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(NSError *)error {
    [_imageLoaders removeObjectIdenticalTo:dataLoader];
}

- (BMMediaContainerPhoto *)mediaContainerPhoto {
    if ([self.photo isKindOfClass:[BMMediaContainerPhoto class]]) {
        return (BMMediaContainerPhoto *)self.photo;
    } else {
        return nil;
    }
}

- (void)layoutSubviews {
    CGFloat width = self.width;
    CGFloat height = self.height;
    
	[super layoutSubviews];
    
    _playButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _imageView.frame = self.bounds;
    _embeddedVideoView.frame = self.bounds;
    
    if ([_photo isKindOfClass:[BMMediaContainerPhoto class]]) {
        BMMediaContainerPhoto *mcp = _photo;
        BMMediaOrientation theOrientation = mcp.orientation;
        if (theOrientation == BMMediaOrientationPortrait && height > width) {
            _imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else if (theOrientation == BMMediaOrientationLandscape && width > height) {
            _imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            _imageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

- (void)setPhoto:(id <BMTTPhoto>)photo {
    if (!photo || photo != _photo) {
        [_youTubeService cancel];
        _youTubeService = nil;
        [_imageView stopLoading];
        [_embeddedVideoView stopLoading];
        _embeddedVideoView.hidden = YES;
        _imageView.hidden = NO;
        _playButton.hidden = YES;
        
        if ([photo isKindOfClass:[BMMediaContainerPhoto class]]) {
            BMMediaContainerPhoto *mcp = photo;
            if (mcp.media.mediaKind == BMMediaKindVideo) {
                id <BMVideoContainer> videoContainer = (id <BMVideoContainer>)mcp.media;
                if ([videoContainer isStreamable]) {
                    _playButton.hidden = NO;
                    [_imageView setMedias:mcp.medias];
                } else {
                    _imageView.image = nil;
                    [_imageView setMedias:nil];
                    _embeddedVideoView.hidden = NO;
                    _imageView.hidden = YES;
                    //Entry id will be automatically extracted
                    //[_embeddedVideoView setEntryId:mcp.media.entryId];
                    [_embeddedVideoView setUrl:mcp.media.url];
                }
            } else if (mcp.media.mediaKind == BMMediaKindPicture) {
                _imageView.placeHolderImage = BMSTYLEVAR(photoViewPlaceHolderImage);
                [_imageView setMedias:mcp.medias];
            }
        }
    }
    [super setPhoto:photo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


- (BOOL)isEmbeddedVideoViewActive {
    return !_embeddedVideoView.hidden;
}

- (UIImage *)image {
    return _imageView.image;
}

#pragma mark - BMAsyncLoadingMediaThumbnailButtonDelegate

- (void)asyncLoadingMediaThumbnailButton:(BMAsyncLoadingMediaThumbnailButton *)button changedMedia:(id <BMMediaContainer>)media animated:(BOOL)animated {
    [self.mediaContainerPhoto setActiveMedia:media];
    [self showCaption:self.photo.caption];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.fullScreenMode) {
        return YES;
    } else {
        return [super pointInside:point withEvent:event];
    }
}

@end

