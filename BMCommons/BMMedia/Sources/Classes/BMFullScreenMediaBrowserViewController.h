//
//  BMFullScreenMediaBrowserViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMThree20/Three20UI/BMTTPhotoViewController.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BMUICore/BMStyleSheet.h>

@class BMFullScreenMediaBrowserViewController;
@protocol BMMutablePhotoSource;
@class BMTTPostController;
@class BMEmbeddedVideoView;

/**
 Delegate for the BMFullScreenMediaBrowserViewController.
 */
@protocol BMFullScreenMediaBrowserViewControllerDelegate <NSObject>

/**
 Sent to the delegate when the view controller is finished. 
 
 The delegate is responsible for dismissing the view controller in the opposite way it was shown.
 */
- (void)photoViewControllerShouldBeDismissed:(BMFullScreenMediaBrowserViewController *)vc;

@end

/**
 Extension of the BMTTPhotoViewController inherited from the Three20 framework.
 
 This controller adds the following functionality:
 
 - Load more functionality if the user scrolls past the end of the already loaded media.
 - Support for video in addition to photos
 - Support for YouTube videos, either in UIWebView mode (default) or native streaming mode.
 - Support for adding captions by showing a BMTTPostController
 - Support for deletion of media with a nice trash can animation
 - Support for showing thumbnails for all loaded media, including the video
 - Support for slideshow when play button is pressed.
 - Support for autohiding navigationbar and toolbar
 */
@interface BMFullScreenMediaBrowserViewController : BMTTPhotoViewController 

/**
 The interval between crossfades when slideshow is active.
 */
@property (nonatomic, assign) NSTimeInterval slideShowInterval;

/**
 The delegate.
 
 @see BMFullScreenMediaBrowserViewControllerDelegate
 */
@property (nonatomic, weak) id <BMFullScreenMediaBrowserViewControllerDelegate> delegate;

/**
 Interval of inactivity after which the toolbar and navigationbar are automatically hidden. Default is 0 (no auto hiding).
 */
@property (nonatomic, assign) NSTimeInterval autoHideBarsInterval;

/**
 Whether or not to show the editing buttons.
 */
@property (nonatomic, assign) BOOL showEditingButtons;

/**
 Whether or not load more is enabled.
 
 Load more triggers the BMTTPhotoSource connected to this viewcontroller to load more results when the user scrolls past the end of the already loaded results. If true it calls [BMTTPhotoSource load:more:] for loading more results.
 */
@property (nonatomic, assign) BOOL loadMoreEnabled;

/**
 Whether or not to use directy YouTube streaming mode, making use of the private direct mp4 YouTube streams.
 
 Default is NO.
 */
@property (nonatomic, assign, getter = isNativeYouTubeModeEnabled) BOOL nativeYouTubeModeEnabled;

/**
 Delete button in the toolbar, by default a trash can.
 */
@property (nonatomic, strong) UIBarButtonItem *deleteButton;

/**
 Button for caption editing.
 */
@property (nonatomic, strong) UIBarButtonItem *captionButton;

/**
 Play button.
 */
@property (nonatomic, strong) UIBarButtonItem *playButton;

/**
 Pause button.
 */
@property (nonatomic, strong) UIBarButtonItem *pauseButton;

/**
 Space item in the toolbar.
 */
@property (nonatomic, strong) UIBarButtonItem *spaceItem;

/**
 Whether currently playing an item.
 */
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;

/**
 Whether the slideshow mode is currently active or not. 
 
 Is active after play is called. Stops on a subsequent stop.
 */
@property (nonatomic, readonly, getter = isPlayingSlideShow) BOOL playingSlideShow;

/**
 Attach a custom stylesheet to use while this view controller is active.
 */
@property (nonatomic, strong) BMStyleSheet *styleSheet;

/**
 Whether to stop playing video automatically upon dragging (moving to the next item).
 */
@property (nonatomic, assign) BOOL stopPlayingWhenDragging;

/**
 Initializes with the specified photo and showing editing buttons.
 */
- (id)initWithPhoto:(id <BMTTPhoto>)photo showEditingButtons:(BOOL)showEditing;

/**
 @name Actions.
 */

/**
 Dismisses the controller.
 
 A message [BMFullScreenMediaBrowserViewControllerDelegate photoViewControllerShouldBeDismissed:] is sent to the delegate. The delegate is responsible for the actual dismissal.
 */
- (void)dismiss;

/**
 Hides the bars with animation
 */
- (void)hideBars;

/**
 Plays the currently selected item.
 
 For video the video player is started, for an image a crossfade is started after the slideShowInterval has passed.
 */
- (void)playCurrentItem;

/**
 Starts a slideshow.
 */
- (void)play;

/**
 Pauses playing/slideshow.
 */
- (void)pause;

/**
 Stops playing/slideshow.
 */
- (void)stop;

/**
 Deletes the currently selected photo.
 
 By default shows an action sheet asking whether the user wants to delete and when confirmed performs the deletion by showing an animation and calling performCurrentPhotoDeletionOnSource:.
 */
- (void)deleteCurrentPhoto;

/**
 Edits the caption for the currently selected photo by showing a text edit controller.
 
 By default shows a BMTTPostController allowing you to edit a caption. Override to provide a custom mechanism for editing captions.
 */
- (void)editCaptionForCurrentPhoto;

@end

/**
 @name Protected methods for sub classes.
 */
@interface BMFullScreenMediaBrowserViewController(Protected)

/**
 Override to do custom setup for the movie player before playing.
 */
- (void)initMoviePlayer:(MPMoviePlayerController *)moviePlayer;

/**
 Returns an array of UIToolbarItems to show in the toolbar at the bottom of the screen.
 
 Override to return a custom array of toolbar items.
 */
- (NSArray *)toolbarItemsForEditingMode:(BOOL)editing;

/**
 Updates the UI (navigation bar/tool bar and corresponding items) to reflect the current state.
 */
- (void)updateChrome;

/**
 Implementation of the actual deletion of the current photo from the source.
 
 Default is to just call [BMTTPhotoSource deletePhotoAtIndex:] but you may override to include additional actions such as communicating with a server to update some state.
 */
- (void)performCurrentPhotoDeletionOnSource:(id <BMMutablePhotoSource>)source;

@end
