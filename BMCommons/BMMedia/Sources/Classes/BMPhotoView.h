//
//  BMPhotoView.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMThree20/Three20UI/BMTTPhotoView.h>

@class BMAsyncLoadingMediaThumbnailButton;
@class BMEmbeddedVideoView;

/**
 View for use in the BMFullScreenMediaBrowserViewController.
 
 Each view represents a page or BMTTPhoto in the BMFullScreenMediaBrowserViewController. It has support for both video and pictures.
 */
@interface BMPhotoView : BMTTPhotoView 

/**
 The play button for playing video.
 */
@property (nonatomic, readonly) UIButton *playButton;

/**
 Embedded video view which is used to display web videos.
 */
@property (nonatomic, readonly) BMEmbeddedVideoView *embeddedVideoView;

/**
 Image view which is used to show still images.
 */
@property (nonatomic, readonly) BMAsyncLoadingMediaThumbnailButton *imageView;

/**
 If set to true, will return YES for any point for [UIView pointInside:withEvent:].
 */
@property (nonatomic, assign) BOOL fullScreenMode;

/**
 Returns YES if the embedded video view is used for the current item.
 */
- (BOOL)isEmbeddedVideoViewActive;

@end
