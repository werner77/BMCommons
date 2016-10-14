//
//  BMEmbeddedVideoView.h
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMMedia/BMEmbeddedWebView.h>

@class BMEmbeddedVideoView;

/**
 Delegate protocol for BMEmbeddedVideoView with methods to respond to fullscreen events.
 */
@protocol BMEmbeddedVideoViewDelegate <NSObject>

@optional
- (void)embeddedVideoViewDidEnterFullscreen:(BMEmbeddedVideoView *)view;
- (void)embeddedVideoViewWillExitFullscreen:(BMEmbeddedVideoView *)view;
- (void)embeddedVideoViewDidExitFullscreen:(BMEmbeddedVideoView *)view;

@end

@interface BMEmbeddedVideoView : BMEmbeddedWebView

/**
 The YouTube video id for loading the video.
 
 If not set, but the url corresponds to a YouTube url, the videoId will be automatically extracted from the url. 
 This property takes precedence above the url property.
 */
@property (nonatomic, strong) NSString *youTubeVideoId;

/**
 If set to YES, the touch area for interacting with the web view is restricted.
 
 If YES the touch area is restricted to roughly the middle area where normally the play button is located. Other parts of the view will send touch events to the superview to enable scrolling through swipe for example.
 */
@property (nonatomic, assign) BOOL limitTouchArea;

/**
 If set to YES a placeholder view is shown after the movie exits full screen.
 
 Enable this if you see glitches in the animation after the movie exits.
 */
@property (nonatomic, assign) BOOL showPlaceHolderAfterMovieExit;

/**
 If set to YES the webview is reloaded after the fullscreen movieplayer exits. Set this to true to resolve glitches which sometimes occur.
 */
@property (nonatomic, assign) BOOL reloadAfterMovieExit;

/**
 If set to YES the native youtube mp4 streams are used (if available) instead of webview iframes.
 
 This will provide a more streamlined experience, but may also be against the YouTube terms of service.
 */
@property (nonatomic, assign, getter = isNativeYouTubeModeEnabled) BOOL nativeYouTubeModeEnabled;

/**
 Delegate for this video view.
 */
@property (nonatomic, weak) id <BMEmbeddedVideoViewDelegate> delegate;

/**
 Returns YES if video is playing, NO otherwise.
 */
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;

@end
