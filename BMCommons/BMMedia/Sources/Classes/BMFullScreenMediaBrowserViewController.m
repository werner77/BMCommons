//
//  BMFullScreenMediaBrowserViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMFullScreenMediaBrowserViewController.h"
#import "BMMutablePhotoSource.h"
#import "BMPhotoView.h"
#import <BMCore/BMStringHelper.h>
#import "BMMediaContainerPhoto.h"
#import <BMThree20/Three20UI/UIToolbarAdditions.h>
#import <BMUICore/UIView+BMCommons.h>
#import <BMUICore/UIButton+BMCommons.h>
#import <BMUICore/BMViewController.h>
#import <BMUICore/UIToolBar+BMCommons.h>
#import <BMThree20/Three20UICommon/UIViewControllerAdditions.h>
#import <BMUICore/BMBarButtonItem.h>
#import <BMUICore/BMUICore.h>
#import <BMUICore/BMNavigationController.h>
#import <BMMedia/BMEmbeddedVideoView.h>
#import <BMMedia/BMPhotoView.h>
#import <BMMedia/BMAsyncLoadingMediaThumbnailButton.h>
#import <BMMedia/BMThumbnailsViewController.h>
#import <BMUICore/UIView+Genie.h>
#import <BMMedia/BMMedia.h>
#import <BMMedia/BMMediaHelper.h>
#import <BMCore/NSObject+BMCommons.h>

// UI
#import <BMThree20/Three20UI/BMTTPostController.h>
#import <BMThree20/Three20UI/BMTTPostControllerDelegate.h>
#import <BMThree20/Three20UI/BMTTPhotoSource.h>
#import <BMThree20/Three20UI/BMTTPhoto.h>
#import <BMThree20/Three20UI/BMTTPhotoView.h>
#import <BMThree20/Three20UI/BMTTScrollView.h>
#import <BMThree20/Three20UI/UIViewAdditions.h>
#import <BMThree20/Three20UI/UINavigationControllerAdditions.h>
#import <BMThree20/Three20UI/UIToolbarAdditions.h>

// UICommon
#import <BMThree20/Three20UICommon/BMTTGlobalUICommon.h>
#import <BMThree20/Three20UICommon/UIViewControllerAdditions.h>

// Core
#import <BMThree20/Three20Core/BMTTCorePreprocessorMacros.h>
#import <BMThree20/Three20Core/BMTTGlobalCoreLocale.h>

#import <BMUICore/UIScreen+BMCommons.h>


#define CAPTION_BAR_HEIGHT 30
#define DEFAULT_SLIDESHOW_INTERVAL 4.0
#define CROSSFADE_DURATION 1.0

#define DELETE_CURRENT_PHOTO_TAG 100

@interface BMTTPhotoViewController () <UIActionSheetDelegate, BMTTPostControllerDelegate, BMEmbeddedVideoViewDelegate>

- (void)showBars:(BOOL)show animated:(BOOL)animated;

- (BMTTPhotoView *)centerPhotoView;

- (void)updateChrome;

- (void)startSlideShowTimer;

- (void)playVideo;

- (void)play;

- (void)playCurrentItem;

- (void)pause;

- (void)stop;

- (void)cancelImageLoadTimer;

- (void)updateZoomEnabledState;

- (void)showPhoto:(id<BMTTPhoto>)photo inView:(BMTTPhotoView*)photoView;

- (BOOL)isShowingChrome;

@end

@interface BMFullScreenMediaBrowserViewController (Private)

- (void)startHideBarsTimer;

- (void)stopHideBarsTimer;

- (void)displayPauseButton;

- (void)displayPlayButton;

- (BOOL)containsPlayableVideo:(BMTTPhotoView *)photoView;

- (BOOL)loadMore;

- (void)animateTrashcan:(BOOL)open withCompletionBlock:(void(^)(void))completion;

- (BOOL)autoHideBars;

@end

@implementation BMFullScreenMediaBrowserViewController {
    UIBarButtonItem *_deleteButton;
	UIBarButtonItem *_captionButton;
    UIBarButtonItem *_playButton;
    UIBarButtonItem *_pauseButton;
    UIBarButtonItem *_spaceItem;
	BOOL _showEditingButtons;
	BMTTPostController *_postController;
	NSTimeInterval _slideShowInterval;
	NSTimer *_hideBarsTimer;
	BOOL _playing;
	BOOL _playingSlideShow;
    BOOL _nativeYouTubeModeEnabled;
	MPMoviePlayerController *_moviePlayer;
	id <BMFullScreenMediaBrowserViewControllerDelegate> __weak delegate;
    BOOL  _loadMoreEnabled;
    BMStyleSheet *_styleSheet;
    BOOL _styleSheetPushed;
}

@synthesize slideShowInterval = _slideShowInterval;
@synthesize delegate;
@synthesize showEditingButtons = _showEditingButtons;
@synthesize loadMoreEnabled = _loadMoreEnabled;
@synthesize nativeYouTubeModeEnabled = _nativeYouTubeModeEnabled;
@synthesize autoHideBarsInterval = _autoHideBarsInterval;
@synthesize deleteButton = _deleteButton;
@synthesize captionButton = _captionButton;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize spaceItem = _spaceItem;
@synthesize playing = _playing;
@synthesize playingSlideShow = _playingSlideShow;
@synthesize styleSheet = _styleSheet;

#pragma mark -
#pragma mark Initialization and deallocation

- (id)init {
    UIBarStyle nBarStyle = UIBarStyleBlackTranslucent;
    UIColor *nBarTintColor = nil;

    if ((self = [super init])) {
        self.navigationBarStyle = nBarStyle;
        self.navigationBarTintColor = nBarTintColor;
        self.slideShowInterval = DEFAULT_SLIDESHOW_INTERVAL;
    }
    return self;
}

- (id)initWithPhoto:(id <BMTTPhoto>)photo showEditingButtons:(BOOL)showEditing {
    if ((self = [self initWithPhoto:photo])) {
        _showEditingButtons = showEditing;
    }
    return self;
}

- (id)initWithPhoto:(id <BMTTPhoto>)photo {
    if ((self = [super initWithPhoto:photo])) {
        self.slideShowInterval = DEFAULT_SLIDESHOW_INTERVAL;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        BMMediaCheckLicense();
        self.nativeYouTubeModeEnabled = BMSTYLEVAR(nativeYouTubeModeEnabled);
    }
    return self;
}

- (void)dealloc {
    if (_styleSheetPushed) {
        [BMStyleSheet popStyleSheet];
    }
    BM_RELEASE_SAFELY(_styleSheet);
}

#pragma mark -
#pragma mark UIViewController methods


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BMViewControllerWillAppearNotification object:self];
        
    [self showBars:YES animated:NO];
    [self startHideBarsTimer];
    [self updateZoomEnabledState];

    if (self.navigationController.viewControllers.count > 0 &&
            (self.navigationController.viewControllers)[0] == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BMMediaLocalizedString(@"mediabrowser.barbutton.back", @"Back") style:UIBarButtonItemStyleBordered
                                                                                 target:self action:@selector(dismiss)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopHideBarsTimer];
}

- (void)viewDidUnload {
    if (_moviePlayer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:_moviePlayer];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    _playingSlideShow = NO;
    [_slideshowTimer invalidate];
    BM_RELEASE_SAFELY(_slideshowTimer);
    BM_RELEASE_SAFELY(_moviePlayer);
    BM_RELEASE_SAFELY(_deleteButton);
    BM_RELEASE_SAFELY(_captionButton);
    BM_RELEASE_SAFELY(_playButton);
    BM_RELEASE_SAFELY(_pauseButton);
    BM_RELEASE_SAFELY(_spaceItem);
    BM_RELEASE_SAFELY(_postController);
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.styleSheet && !_styleSheetPushed) {
        [BMStyleSheet pushStyleSheet:self.styleSheet];
        _styleSheetPushed = YES;
    }
    
    _scrollView.centerPageIndex = _centerPhotoIndex;
    
    if (BMOSVersionIsAtLeast(@"7.0")) {
        BM_START_IGNORE_TOO_NEW
        _toolbar.barTintColor = self.navigationBarTintColor;
        _toolbar.tintColor = self.navigationBarTextTintColor;
        BM_END_IGNORE_TOO_NEW
    } else {
        _toolbar.tintColor = self.navigationBarTintColor;
    }
    _toolbar.barStyle = self.navigationBarStyle;
    
    UIButton *button = [UIButton bmButtonForBarButtonItemWithTarget:self action:@selector(deleteCurrentPhoto)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
    _deleteButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    button = [UIButton bmButtonForBarButtonItemWithTarget:self action:@selector(editCaptionForCurrentPhoto)];
    _captionButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                target:self
                                                                action:@selector(play)];
    _pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                   target:self
                                                   action:@selector(pause)];
    _spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace                        
                                                               target:nil action:nil];
    
    [self updateToolbar];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (![self isShowingChrome])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (![self isShowingChrome])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark Overridden methods

- (void)updateChrome {
    [super updateChrome];    
    _playButton.enabled = _photoSource.numberOfPhotos > 1;
    
    [self updateToolbar];
}

- (BMTTPhotoView *)createPhotoView {
    BMPhotoView *photoView = [[BMPhotoView alloc] init];
    [photoView.playButton bmSetTarget:self action:@selector(playCurrentItem)];

    UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmbeddedVideoViewTap:)];
    gr.cancelsTouchesInView = NO;
    [photoView.embeddedVideoView addGestureRecognizer:gr];
    photoView.embeddedVideoView.delegate = self;
    photoView.embeddedVideoView.nativeYouTubeModeEnabled = self.nativeYouTubeModeEnabled;
    photoView.embeddedVideoView.showPlaceHolderAfterMovieExit = YES;
    
    return (BMTTPhotoView *)photoView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTThumbsViewController*)createThumbsViewController {
    return [[BMThumbnailsViewController alloc] initWithDelegate:self];
}

#pragma mark - TTScrollViewDelegate

- (void)scrollView:(BMTTScrollView *)scrollView tapped:(UITouch *)touch {
    if (!_moviePlayer || _moviePlayer.playbackState != MPMoviePlaybackStatePlaying) {
        [self startHideBarsTimer];
        [self stop];
        [super scrollView:scrollView tapped:touch];
    }
}

- (void)scrollViewWillBeginDragging:(BMTTScrollView *)scrollView {
    _playingSlideShow = NO;
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    if (self.autoHideBars) {
        [super scrollViewWillBeginDragging:scrollView];
    } else {
        [self cancelImageLoadTimer];
    }
    [self pause];
}

- (BOOL)scrollView:(BMTTScrollView *)scrollView flickedBoundary:(BOOL)right {
    if (right && self.loadMoreEnabled) {
        return [self loadMore];
    } else {
        return NO;
    }
}

- (void)scrollViewDidEndDecelerating:(BMTTScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    [self stop];
}

#pragma mark - TTPhoto

- (void)didMoveToPhoto:(id <BMTTPhoto>)photo fromPhoto:(id <BMTTPhoto>)fromPhoto {
    [self updateZoomEnabledState];
    
    [super didMoveToPhoto:photo fromPhoto:fromPhoto];
}

#pragma mark -
#pragma mark Protected methods

- (void)performCurrentPhotoDeletionOnSource:(id <BMMutablePhotoSource>)source {
    [source deletePhotoAtIndex:self.centerPhotoIndex];
}

- (NSArray *)toolbarItemsForEditingMode:(BOOL)editing {
    NSArray *ret = nil;
    if (editing) {
        
        ret = @[_captionButton, _spaceItem, _previousButton, _spaceItem, _playButton, _spaceItem, _nextButton, _spaceItem, _deleteButton];
    } else {
        ret =  @[_spaceItem, _previousButton, _spaceItem, _playButton, _spaceItem, _nextButton, _spaceItem];
    }
    return ret;
}

- (void)updateToolbar {
    _toolbar.items = [self toolbarItemsForEditingMode:_showEditingButtons];
}

#pragma mark -
#pragma mark Actions

- (void)dismiss {
    [self.delegate photoViewControllerShouldBeDismissed:self];
}

- (void)hideBars {
    [self stopHideBarsTimer];
    [self showBars:NO animated:YES];
}

- (void)playCurrentItem {
    if (!_playing) {
        _playing = YES;

        [self displayPauseButton];

        [self stopHideBarsTimer];

        BMTTPhotoView *currentPhotoView = [self centerPhotoView];
        if ([self containsPlayableVideo:currentPhotoView]) {
            [self playVideo];
        } else {
            [self startSlideShowTimer];
        }
    }
}

- (void)play {
    _playingSlideShow = YES;
    [self playCurrentItem];
}

- (void)pause {
    if (_slideshowTimer) {
        [_slideshowTimer invalidate];
        BM_RELEASE_SAFELY(_slideshowTimer);
    }
    if (_playing) {
        _playing = NO;

        [self displayPlayButton];

        if (_moviePlayer && _moviePlayer.playbackState != MPMoviePlaybackStateStopped) {
            [_moviePlayer pause];
        }
    }
}

- (void)stop {
    _playingSlideShow = NO;
    if (_moviePlayer) {
        if (_moviePlayer.playbackState != MPMoviePlaybackStateStopped) {
            [_moviePlayer stop];
        }
        [_moviePlayer.view removeFromSuperview];
        BM_RELEASE_SAFELY(_moviePlayer);
    }
    [self pause];
}

- (void)deleteCurrentPhoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:BMMediaLocalizedString(@"mediabrowser.alert.message.deleteconfirmation", @"Are you sure you want to delete this item?")
                                                              delegate:self
                                                     cancelButtonTitle:BMMediaLocalizedString(@"button.cancel", @"Cancel")
                                                destructiveButtonTitle:BMMediaLocalizedString(@"mediabrowser.alert.button.delete", @"Delete") otherButtonTitles:nil];
    actionSheet.tag = DELETE_CURRENT_PHOTO_TAG;
    [actionSheet showInView:self.view];
    [self startHideBarsTimer];
}

- (void)editCaptionForCurrentPhoto {
    if ([self.photoSource conformsToProtocol:@protocol(BMMutablePhotoSource)]) {
        NSArray *postKeys = @[@"text", @"title", @"__target__", @"originRect"];
        NSString *currCaption = self.centerPhoto.caption;
        CGRect appFrame = [UIScreen mainScreen].bmPortraitApplicationFrame;
        CGRect labelFrame = CGRectMake(0, appFrame.size.height - BM_TABBAR_HEIGHT - CAPTION_BAR_HEIGHT, appFrame.size.width, CAPTION_BAR_HEIGHT);
        NSArray *postValues = @[[BMStringHelper filterNilString:currCaption],
                                                        BMMediaLocalizedString(@"mediabrowser.editcaption.title", @"Caption"),
                                                        self.view,
                                                        [NSValue valueWithCGRect:labelFrame]];

        NSDictionary *query = [NSDictionary dictionaryWithObjects:postValues forKeys:postKeys];


        _postController = [[BMTTPostController alloc] initWithNavigatorURL:nil query:query];
        _postController.navigatorBar.tintColor = self.navigationController.navigationBar.tintColor;
        _postController.delegate = self;

        self.popupViewController = _postController;
        _postController.superController = self;

        [_postController showInView:self.view animated:YES];
        [self stopHideBarsTimer];

    } else {
        [[[UIAlertView alloc] initWithTitle:BMMediaLocalizedString(@"alert.title.sorry", @"Sorry") message:BMMediaLocalizedString(@"mediabrowser.alert.message.captionsnotsupported", @"Captions are not supported for this item") delegate:nil cancelButtonTitle:BMMediaLocalizedString(@"button.ok", @"OK") otherButtonTitles:nil] show];
        [self startHideBarsTimer];
    }
}

#pragma mark -
#pragma mark SlideShow

- (void)startCrossFadeAnimation:(UIImageView *)oldPhotoView {
    BMTTPhotoView *newPhotoView = [self centerPhotoView];

    newPhotoView.alpha = 0.0;

    [UIView animateWithDuration:CROSSFADE_DURATION animations:^{
        oldPhotoView.alpha = 0.0;
        newPhotoView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self animationDidStop:@"SlideShow" finished:finished context:oldPhotoView];
    }];
}

- (void)slideshowTimer {

    BMTTPhotoView *currentPhotoView = [self centerPhotoView];
    UIView *superView = [currentPhotoView superview];

    CGRect currentFrame = currentPhotoView.frame;

    UIImage *image = [currentPhotoView bmContentsAsImage];

    UIImageView *oldPhotoView = [[UIImageView alloc] init];
    oldPhotoView.image = image;
    oldPhotoView.contentMode = currentPhotoView.contentMode;
    oldPhotoView.frame = currentFrame;
    [superView addSubview:oldPhotoView];

    NSInteger newIndex = 0;

    if (_centerPhotoIndex < _photoSource.numberOfPhotos - 1) {
        newIndex = _centerPhotoIndex + 1;
    }
    _scrollView.centerPageIndex = newIndex;

    [self startCrossFadeAnimation:oldPhotoView];
}

#pragma mark -
#pragma mark Animation callback

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(UIImageView *)imageView {
    if ([animationID isEqual:@"SlideShow"]) {
        [imageView removeFromSuperview];
        if (_playingSlideShow) {
            BMTTPhotoView *currentPhotoView = [self centerPhotoView];
            if ([self containsPlayableVideo:currentPhotoView]) {
                [_slideshowTimer invalidate];
                BM_RELEASE_SAFELY(_slideshowTimer);
                [self playVideo];
            } else if (!_slideshowTimer) {
                [self startSlideShowTimer];
            }
        } else {
            [_slideshowTimer invalidate];
            BM_RELEASE_SAFELY(_slideshowTimer);
        }
    }
}

#pragma mark -
#pragma mark PostControllerDelegate

/**
 * The user has posted text and an animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(BMTTPostController *)postController willPostText:(NSString *)text {
    [(id <BMMutablePhotoSource>) self.photoSource setCaption:text forPhotoAtIndex:self.centerPhotoIndex];
    return YES;
}

/**
 * The text has been posted.
 */
- (void)postController:(BMTTPostController *)postController didPostText:(NSString *)text withResult:(id)result {
    [self startHideBarsTimer];
    BM_AUTORELEASE_SAFELY(_postController);
}

/**
 * The controller was cancelled before posting.
 */
- (void)postControllerDidCancel:(BMTTPostController *)postController {
    [self startHideBarsTimer];
    BM_AUTORELEASE_SAFELY(_postController);
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == DELETE_CURRENT_PHOTO_TAG) {
        if (buttonIndex == 0) {
            if ([self.photoSource conformsToProtocol:@protocol(BMMutablePhotoSource)]) {
                
                [self animateTrashcan:YES withCompletionBlock:^{
                
                    //Animate deletion
                    BMTTPhotoView *currentPhotoView = [self centerPhotoView];
                    UIView *superView = currentPhotoView.superview;
                    CGRect currentFrame = currentPhotoView.frame;
                    UIImage *image = [currentPhotoView bmContentsAsImage];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    
                    [self performCurrentPhotoDeletionOnSource:(id <BMMutablePhotoSource>)self.photoSource];
                    
                    currentFrame.origin.x = 0.0;
                    imageView.frame = currentFrame;
                    
                    [superView addSubview:imageView];
                    
                    CGRect deleteButtonFrame = [BMBarButtonItem frameOfItem:_deleteButton inView:superView];
                    
                    deleteButtonFrame = CGRectMake(CGRectGetMidX(deleteButtonFrame) - 10.0, CGRectGetMidY(deleteButtonFrame) - 7.0, 5.0, 0.0);

                    [imageView bmGenieInTransitionWithDuration:0.5 destinationRect:deleteButtonFrame destinationEdge:BCRectEdgeTop completion:^{
                        [imageView removeFromSuperview];
                        [self animateTrashcan:NO withCompletionBlock:^{
                            if (self.photoSource.numberOfPhotos == 0) {
                                [self.delegate photoViewControllerShouldBeDismissed:self];
                            }
                        }];

                    }];
                }];
                
            } else {
                [[[UIAlertView alloc] initWithTitle:BMMediaLocalizedString(@"alert.title.sorry", @"Sorry") message:BMMediaLocalizedString(@"mediabrowser.alert.message.deletenotsupported", @"This item cannot be deleted") delegate:nil cancelButtonTitle:BMMediaLocalizedString(@"button.ok", @"OK") otherButtonTitles:nil] show];
            }
        }    
    }
}

#pragma mark -
#pragma mark TTModel delegate

- (void)model:(id <BMTTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    [super model:model didUpdateObject:object atIndexPath:indexPath];
    BMTTPhotoView *photoView = (BMTTPhotoView *) _scrollView.centerPage;

    //The caption is updated when photo property is set of photoview, so the following hack is necessary:
    id <BMTTPhoto> photo = photoView.photo;
    photoView.photo = nil;
    photoView.photo = photo;

    [self refresh];
}

- (void)modelDidFinishLoad:(id<BMTTModel>)model {
    [super modelDidFinishLoad:model];
    [_scrollView scrollToCenterPage:YES];
}

- (void)modelDidCancelLoad:(id<BMTTModel>)model {
    [super modelDidCancelLoad:model];
    [_scrollView scrollToCenterPage:YES];
}

#pragma mark -
#pragma mark MoviePlayer notifications

- (void)moviePlayerDidFinish:(NSNotification *)notification {
    
    for (UIView *v in _scrollView.visiblePages.objectEnumerator) {
        BMPhotoView *photoView = [v bmCastSafely:[BMPhotoView class]];
        photoView.fullScreenMode = NO;
    }

    NSError *error = (notification.userInfo)[@"error"];

    if (error) {
        LogWarn(@"Could not play movie: %@", error);
    }

    BOOL continueSlideShow = _playingSlideShow;

    //Remove the movie player
    [_moviePlayer.view removeFromSuperview];
    BM_RELEASE_SAFELY(_moviePlayer);
    
    if (_toolbar.alpha == 0.0f) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }

    if (continueSlideShow) {
        [self slideshowTimer];
    }
}

- (void)moviePlayerDidChangeLoadState:(NSNotification *)notification {
    _moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
}

- (void)moviePlayerPlaybackStateDidChange:(NSNotification *)notification {
    if (_moviePlayer.playbackState == MPMoviePlaybackStateStopped || _moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        [self pause];
    } else if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self playCurrentItem];
        [self showBars:NO animated:YES];
    }
}

#pragma mark - BMEmbeddedVideoViewDelegate

- (void)embeddedVideoViewDidEnterFullscreen:(BMEmbeddedVideoView *)view {
    [self stopHideBarsTimer];
}

- (void)embeddedVideoViewWillExitFullscreen:(BMEmbeddedVideoView *)view {
    [self willRotateToInterfaceOrientation:BMInterfaceOrientation() duration:0.0];
    [self willAnimateRotationToInterfaceOrientation:BMInterfaceOrientation() duration:0.0];
    [self didRotateFromInterfaceOrientation:BMInterfaceOrientation()];
}

- (void)embeddedVideoViewDidExitFullscreen:(BMEmbeddedVideoView *)view {
    [self showBars:YES animated:NO];
    [self startHideBarsTimer];
}


@end

@implementation BMFullScreenMediaBrowserViewController (Private)

- (void)moviePlayerViewWasDragged:(UIPanGestureRecognizer *)gr {
    
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self showBars:!self.navigationController.navigationBarHidden animated:NO];
    
}

- (void)startHideBarsTimer {
    if (self.autoHideBars) {
        [_hideBarsTimer invalidate];
        _hideBarsTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoHideBarsInterval target:self
                                                        selector:@selector(hideBars)
                                                        userInfo:nil repeats:NO];
    }
}

- (void)stopHideBarsTimer {
    [_hideBarsTimer invalidate];
    _hideBarsTimer = nil;
}

- (void)startSlideShowTimer {
    if (!_slideshowTimer) {
        _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:self.slideShowInterval
                                                            target:self
                                                          selector:@selector(slideshowTimer)
                                                          userInfo:nil repeats:YES];
    }
}

- (void)displayPauseButton {
    [_toolbar bmReplaceItem:_playButton withItem:_pauseButton];
}

- (void)displayPlayButton {
    [_toolbar bmReplaceItem:_pauseButton withItem:_playButton];
}

- (BOOL)containsPlayableVideo:(BMTTPhotoView *)photoView {
    BOOL isEmbeddedVideoView = [photoView isKindOfClass:[BMPhotoView class]] && [(BMPhotoView *) photoView isEmbeddedVideoViewActive];
    BMMediaContainerPhoto *photo = (BMMediaContainerPhoto *) photoView.photo;
    return (photo.media.mediaKind == BMMediaKindVideo && !isEmbeddedVideoView);
}

- (void)playVideoFromUrl:(NSURL *)theUrl {
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:theUrl];
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        
        /*
         BMPhotoView *currentPhotoView = (BMPhotoView *)[self centerPhotoView];
         BOOL isLandscapeContent = currentPhotoView.imageView.imageView.frame.size.width > currentPhotoView.imageView.imageView.frame.size.height;
         BOOL isLandscapeOrientation = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
         
         if (currentPhotoView.imageView.imageView.contentMode == UIViewContentModeScaleAspectFill && isLandscapeContent == isLandscapeOrientation) {
         _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
         } else {
         _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
         }
         */
        
        [self initMoviePlayer:_moviePlayer];
        
        if (self.stopPlayingWhenDragging) {
            UIGestureRecognizer *gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moviePlayerViewWasDragged:)];
            gr.cancelsTouchesInView = NO;
            [_moviePlayer.view addGestureRecognizer:gr];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidChangeLoadState:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:_moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
        [_moviePlayer prepareToPlay];
    } else if (![_moviePlayer.contentURL isEqual:theUrl]) {
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        
        [self initMoviePlayer:_moviePlayer];
        
        [_moviePlayer stop];
        [_moviePlayer setContentURL:theUrl];
    }
    
    UIView *parentView = self.centerPhotoView;
    
    BMPhotoView *photoView = [parentView bmCastSafely:[BMPhotoView class]];
    photoView.fullScreenMode = YES;
    
    if (_moviePlayer.view.superview != parentView) {
        UIView *moviePlayerView = _moviePlayer.view;
        [moviePlayerView removeFromSuperview];
        
        [parentView addSubview:moviePlayerView];
        
        //CGRect frame = parentView.bounds;
        CGRect frame = [parentView.superview convertRect:parentView.superview.bounds toView:parentView];
        
        moviePlayerView.frame = frame;
        moviePlayerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [parentView addSubview:moviePlayerView];
        
        moviePlayerView.alpha = 0.0f;
        [UIView animateWithDuration:0.3 animations:^() {
            moviePlayerView.alpha = 1.0f;
        }];
    }
    [_moviePlayer play];
}

- (void)initMoviePlayer:(MPMoviePlayerController *)moviePlayer {
    
}

- (void)playVideo {
    BMPhotoView *currentPhotoView = (BMPhotoView *)[self centerPhotoView];
    BMMediaContainerPhoto *mcp = (BMMediaContainerPhoto *) currentPhotoView.photo;
    id <BMVideoContainer> video = (id <BMVideoContainer>) mcp.media;

    NSString *filePath = video.filePath;
    NSURL *theUrl = (filePath ? [NSURL fileURLWithPath:filePath] : nil);
    if (!theUrl) {
        NSString *videoId = [BMMediaHelper extractedYouTubeVideoIdFromUrl:video.url];
        if (videoId) {
            [BMMediaHelper retrieveDirectYouTubeUrlForVideoId:videoId withSuccess:^(NSString *youtubeUrl) {
                [self playVideoFromUrl:[BMStringHelper urlFromString:youtubeUrl]];
            } failure:^(NSError *theError) {
                LogWarn(@"Could not retrieve direct YouTube stream URL: %@", theError);
            }];
        } else {
            [self playVideoFromUrl:[BMStringHelper urlFromString:video.url]];
        }
    } else {
        [self playVideoFromUrl:theUrl];
    }
}

- (void)updateZoomEnabledState {
    BMTTPhotoView *currentPhotoView = [self centerPhotoView];

    BMMediaContainerPhoto *currentPhoto = (BMMediaContainerPhoto *) currentPhotoView.photo;
    _scrollView.zoomEnabled = (currentPhoto.media.mediaKind != BMMediaKindVideo);
}

- (void)onEmbeddedVideoViewTap:(UIGestureRecognizer *)gr {
    if (!gr.view.isHidden) {
        _playingSlideShow = NO;
        [self pause];
    }
}

- (BOOL)loadMore {
    [self.photoSource load:BMTTURLRequestCachePolicyDefault more:YES];
    return self.photoSource.isLoadingMore;
}

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [super updateToolbarWithOrientation:interfaceOrientation];
    UIButton *b = (UIButton *)_deleteButton.customView;
    NSString *imageName;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        imageName = @"BMMedia.bundle/UIButtonBarGarbageCloseSmall16.png";
    } else {
        imageName = @"BMMedia.bundle/UIButtonBarGarbageClose16.png";
        transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    [b setImage:image forState:UIControlStateNormal];
    b.imageView.transform = transform;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        imageName = @"BMMedia.bundle/UIButtonBarComposeLandscape.png";
    } else {
        imageName = @"BMMedia.bundle/UIButtonBarCompose.png";
    }
    
    b = (UIButton *)_captionButton.customView;
    
    image = [UIImage imageNamed:imageName];
    [b setImage:image forState:UIControlStateNormal];
}

- (void)animateTrashcan:(BOOL)open withCompletionBlock:(void(^)(void))completion {
    UIInterfaceOrientation orientation = BMInterfaceOrientation();
    
    NSString *imageNameFormat = nil;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        imageNameFormat = [NSString stringWithFormat:@"BMMedia.bundle/UIButtonBarGarbage%@Small%%d.png", open ? @"Open" : @"Close"];
    } else {
        imageNameFormat = [NSString stringWithFormat:@"BMMedia.bundle/UIButtonBarGarbage%@%%d.png", open ? @"Open" : @"Close"];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"imageNameFormat"] = imageNameFormat;
    dict[@"counter"] = @0;
    dict[@"completionBlock"] = [completion copy];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(setNextTrashcanImage:) userInfo:dict repeats:YES];
}

- (void)setNextTrashcanImage:(NSTimer *)timer {
    NSMutableDictionary *dict = timer.userInfo;
    
    NSString *imageNameFormat = dict[@"imageNameFormat"];
    int count = [dict[@"counter"] intValue] + 1;
    void (^completionBlock)(void) = dict[@"completionBlock"];
    
    NSString *imageName = [NSString stringWithFormat:imageNameFormat, count];
    UIImage *image = [UIImage imageNamed:imageName];
    
    if (image) {
        UIButton *b = (UIButton *)_deleteButton.customView;
        [b setImage:image forState:UIControlStateNormal];
        dict[@"counter"] = @(count);
    } else {
        [timer invalidate];
        completionBlock();
    }
}

- (BOOL)autoHideBars {
    return self.autoHideBarsInterval > 0.0;
}

@end
