//
//  BMAsyncLoadingMediaThumbnailButton.h
//  BMCommons
//
//  Created by Werner Altewischer on 17/04/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMUICore/BMAsyncLoadingImageButton.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMEmbeddedVideoView.h>
#import <BMMedia/BMMediaThumbnailView.h>

@class BMAsyncLoadingMediaThumbnailButton;

/**
 Delegate protocol for BMAsyncLoadingMediaThumbnailButton.
 */
@protocol BMAsyncLoadingMediaThumbnailButtonDelegate <NSObject>

/**
 Implement to act on changes between displayed media in case an array of BMMediaContainer instances is set using [BMAsyncLoadingMediaThumbnailButton setMedias:].
 */
- (void)asyncLoadingMediaThumbnailButton:(BMAsyncLoadingMediaThumbnailButton *)button changedMedia:(id <BMMediaContainer>)media animated:(BOOL)animated;

@end

/**
 Asynchronous loading button showing a thumbnail for a BMMediaContainer.
 */
@interface BMAsyncLoadingMediaThumbnailButton : BMAsyncLoadingImageButton

@property (nonatomic, weak) id <BMAsyncLoadingMediaThumbnailButtonDelegate> delegate;
@property (nonatomic, strong) id <BMMediaContainer> media;

/**
 If set to YES a BMEmbeddedVideoView is used when displaying a BMVideoContainer.
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL useEmbeddedVideoView;

/**
 If set to YES big images are used instead of thumbnail images. 
 
 If [BMMediaContainer midSizeImageUrl] returns not nil this one is used, otherwise for BMPictureContainers the url property is consulted (returning the largest image available).
 Default is NO.
 */
@property (nonatomic, assign) BOOL useFullScreenImages;

/**
 If set to YES no placeholder image is shown in case no media thumbnail is provided.
 
 Default is NO, so a placeholder image is displayed in case media is nil.
 */
@property (nonatomic, assign) BOOL ignorePlaceHolderForNilMedia;

/**
 If set to YES no overlay is displayed depending on the BMMediaKind of the active BMMediaContainer.
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL overlayDisabled;

/**
 Returns a reference to the BMEmbeddedVideoView used. 
 
 Returns nil if no BMVideoContainer is assigned to this button or useEmbeddedVideoView is set to NO.
 */
@property (nonatomic, readonly) BMEmbeddedVideoView *embeddedVideoView;

/**
 Sets an array of BMMediaContainer instances for display in crossfade mode between the different media.
 */
- (void)setMedias:(NSArray *)allMedia;

/**
 Sets a BMMediaContainer optionally animating the transition betwee the current image and the new one with a crossfade.
 */
- (void)setMedia:(id <BMMediaContainer>)displayMedia animated:(BOOL)animated;

@end
