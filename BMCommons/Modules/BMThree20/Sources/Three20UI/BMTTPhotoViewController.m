//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/BMTTPhotoViewController.h"

// UI
#import "Three20UI/BMTTThumbsViewController.h"
#import "Three20UI/BMTTPhotoSource.h"
#import "Three20UI/BMTTPhoto.h"
#import "Three20UI/BMTTPhotoView.h"
#import "Three20UI/BMTTActivityLabel.h"
#import "Three20UI/BMTTScrollView.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UINavigationControllerAdditions.h"
#import "Three20UI/UIToolbarAdditions.h"

// UICommon
#import "Three20UICommon/BMTTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

//Style
#import "Three20Style/BMTTGlobalStyle.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"
#import "Three20Core/BMTTGlobalCoreLocale.h"

#import <BMCommons/BMCore.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/UIButton+BMCommons.h>
#import <BMCommons/BMNavigationController.h>
#import <BMCommons/UIScreen+BMCommons.h>

static const NSTimeInterval kPhotoLoadLongDelay   = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay  = 0.25;
static const NSTimeInterval kSlideshowInterval    = 2;
static const NSInteger kActivityLabelTag          = 96;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTPhotoViewController

@synthesize centerPhoto       = _centerPhoto;
@synthesize centerPhotoIndex  = _centerPhotoIndex;
@synthesize defaultImage      = _defaultImage;
@synthesize photoSource       = _photoSource;
@synthesize captionStyle      = _captionStyle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.navigationItem.backBarButtonItem =
      [[[UIBarButtonItem alloc]
        initWithTitle:
        BMTTLocalizedString(@"Photo",
                          @"Title for back button that returns to photo browser")
        style: UIBarButtonItemStylePlain
        target: nil
        action: nil] autorelease];

    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.hidesBottomBarWhenPushed = YES;

    self.defaultImage = BMIMAGE(@"bundle://BMThree20.bundle/photoDefault.png");
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPhoto:(id<BMTTPhoto>)photo {
  if (self = [self initWithNibName:nil bundle:nil]) {
    self.centerPhoto = photo;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPhotoSource:(id<BMTTPhotoSource>)photoSource {
  if (self = [self initWithNibName:nil bundle:nil]) {
    self.photoSource = photoSource;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _thumbsController.delegate = nil;
  BMTT_INVALIDATE_TIMER(_slideshowTimer);
  BMTT_INVALIDATE_TIMER(_loadTimer);
    
  BMTT_RELEASE_SAFELY(_thumbsController);
  BMTT_RELEASE_SAFELY(_centerPhoto);
  BMTT_RELEASE_SAFELY(_photoSource);
  BMTT_RELEASE_SAFELY(_statusText);
  BMTT_RELEASE_SAFELY(_defaultImage);
    BMTT_RELEASE_SAFELY(_captionStyle);

  [super dealloc];
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

#ifdef __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTPhotoView*)centerPhotoView {
  return (BMTTPhotoView*)_scrollView.centerPage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImageDelayed {
  _loadTimer = nil;
  [self.centerPhotoView loadImage];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startImageLoadTimer:(NSTimeInterval)delay {
  [_loadTimer invalidate];
  _loadTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                target:self
                                              selector:@selector(loadImageDelayed)
                                              userInfo:nil
                                               repeats:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelImageLoadTimer {
  [_loadTimer invalidate];
  _loadTimer = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImages {
  BMTTPhotoView* centerPhotoView = self.centerPhotoView;
  for (BMTTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    if (photoView == centerPhotoView) {
      [photoView loadPreview:NO];

    } else {
      [photoView loadPreview:YES];
    }
  }

  if (_delayLoad) {
    _delayLoad = NO;
    [self startImageLoadTimer:kPhotoLoadLongDelay];

  } else {
    [centerPhotoView loadImage];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateChrome {
  if (_photoSource.numberOfPhotos < 2) {
    self.title = _photoSource.title;

  } else {
    self.title = [NSString stringWithFormat:
                  BMTTLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"),
                  _centerPhotoIndex+1, _photoSource.numberOfPhotos];
  }

  if (![self.ttPreviousViewController isKindOfClass:[BMTTThumbsViewController class]]) {
    if (_photoSource.numberOfPhotos > 1) {
      self.navigationItem.rightBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle:BMTTLocalizedString(@"See All",
                                                                @"See all photo thumbnails")
                                        style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(showThumbnails)]
       autorelease];

    } else {
      self.navigationItem.rightBarButtonItem = nil;
    }

  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }

  UIBarButtonItem* playButton = [_toolbar itemWithTag:1];
  playButton.enabled = _photoSource.numberOfPhotos > 1;
  _previousButton.enabled = _centerPhotoIndex > 0;
  _nextButton.enabled = _centerPhotoIndex >= 0 && _centerPhotoIndex < _photoSource.numberOfPhotos-1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    _toolbar.height = BMTT_TOOLBAR_HEIGHT;

  } else {
    _toolbar.height = BMTT_LANDSCAPE_TOOLBAR_HEIGHT+1;
  }
  _toolbar.top = self.view.height - _toolbar.height;
    
    NSString *imageName;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        imageName = @"BMThree20.bundle/nextIconLandscape.png";
    } else {
        imageName = @"BMThree20.bundle/nextIcon.png";
    }
    
    UIButton *b = (UIButton *)_nextButton.customView;
    [b setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        imageName = @"BMThree20.bundle/previousIconLandscape.png";
    } else {
        imageName = @"BMThree20.bundle/previousIcon.png";
    }
    
    b = (UIButton *)_previousButton.customView;
    [b setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePhotoView {
  _scrollView.centerPageIndex = _centerPhotoIndex;
  [self loadImages];
  [self updateChrome];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPhoto:(id<BMTTPhoto>)photo {
  id<BMTTPhoto> previousPhoto = [_centerPhoto autorelease];
  _centerPhoto = [photo retain];
  [self didMoveToPhoto:_centerPhoto fromPhoto:previousPhoto];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
  _centerPhotoIndex = photoIndex == BMTT_NULL_PHOTO_INDEX ? 0 : photoIndex;
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];
  _delayLoad = withDelay;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPhoto:(id<BMTTPhoto>)photo inView:(BMTTPhotoView*)photoView {
  photoView.photo = photo;
  if (!photoView.photo && _statusText) {
    [photoView showStatus:_statusText];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateVisiblePhotoViews {
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];

  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    BMTTPhotoView* photoView = [photoViews objectForKey:key];
    [photoView showProgress:-1];

    id<BMTTPhoto> photo = [_photoSource photoAtIndex:key.intValue];
    [self showPhoto:photo inView:photoView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (BMTTPhotoView* photoView in photoViews.objectEnumerator) {
    if (!photoView.isLoading) {
      [photoView showProgress:-1];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? !bar.hidden : YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTPhotoView*)statusView {
  if (!_photoStatusView) {
    _photoStatusView = [[BMTTPhotoView alloc] initWithFrame:_scrollView.frame];
    _photoStatusView.defaultImage = _defaultImage;
    _photoStatusView.photo = nil;
    [_innerView addSubview:_photoStatusView];
  }

  return _photoStatusView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
  if ((self.hasViewAppeared || self.isViewAppearing) && progress >= 0 && !self.centerPhotoView) {
    [self.statusView showProgress:progress];
    self.statusView.hidden = NO;

  } else {
    _photoStatusView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)status {
  [_statusText release];
  _statusText = [status retain];

  if ((self.hasViewAppeared || self.isViewAppearing) && status && !self.centerPhotoView) {
    [self.statusView showStatus:status];
    self.statusView.hidden = NO;

  } else {
    _photoStatusView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCaptions:(BOOL)show {
  for (BMTTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    photoView.hidesCaption = !show;
  }
}

BM_PUSH_IGNORE_UNDECLARED_SELECTOR_WARNING

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForThumbnails {
  if ([self.photoSource respondsToSelector:@selector(URLValueWithName:)]) {
    return [self.photoSource performSelector:@selector(URLValueWithName:)
                                  withObject:@"BMTTThumbsViewController"];

  } else {
    return nil;
  }
}

BM_POP_IGNORE_WARNING

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showThumbnails {
    if (!_thumbsController) {
        // The photo source had no URL mapping in BMTTURLMap, so we let the subclass show the thumbs
        _thumbsController = [[self createThumbsViewController] retain];
        _thumbsController.photoSource = _photoSource;
    }
    
    BMNavigationController *navController = [[BMNavigationController alloc] initWithRootViewController:_thumbsController];
    navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    navController.navigationBar.translucent = self.navigationController.navigationBar.translucent;
    navController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    [navController release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)slideshowTimer {
  if (_centerPhotoIndex == _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = 0;

  } else {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)playAction {
  if (!_slideshowTimer) {
    UIBarButtonItem* pauseButton =
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause
                                                     target: self
                                                     action: @selector(pauseAction)]
       autorelease];
    pauseButton.tag = 1;

    [_toolbar replaceItemWithTag:1 withItem:pauseButton];

    _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:kSlideshowInterval
                                                       target:self
                                                     selector:@selector(slideshowTimer)
                                                     userInfo:nil
                                                      repeats:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pauseAction {
  if (_slideshowTimer) {
    UIBarButtonItem* playButton =
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                     target:self
                                                     action:@selector(playAction)]
       autorelease];
    playButton.tag = 1;

    [_toolbar replaceItemWithTag:1 withItem:playButton];

    [_slideshowTimer invalidate];
    _slideshowTimer = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nextAction {
  [self pauseAction];
  if (_centerPhotoIndex < _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)previousAction {
  [self pauseAction];
  if (_centerPhotoIndex > 0) {
    _scrollView.centerPageIndex = _centerPhotoIndex-1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = NO;
  [self setNeedsStatusBarAppearanceUpdate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = YES;
  [self setNeedsStatusBarAppearanceUpdate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bmPortraitBounds;
  self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height);
  _innerView = [[UIView alloc] initWithFrame:innerFrame];
  _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_innerView];

  _scrollView = [[BMTTScrollView alloc] initWithFrame:screenFrame];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.rotateEnabled = NO;
  _scrollView.backgroundColor = [UIColor blackColor];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [_innerView addSubview:_scrollView];

    UIButton *button = [UIButton bmButtonForBarButtonItemWithTarget:self action:@selector(nextAction)];
    _nextButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    button = [UIButton bmButtonForBarButtonItemWithTarget:self action:@selector(previousAction)];
    _previousButton = [[UIBarButtonItem alloc] initWithCustomView:button];

  UIBarButtonItem* playButton =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                   target:self
                                                   action:@selector(playAction)]
     autorelease];
  playButton.tag = 1;

  UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                       UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  _toolbar = [[UIToolbar alloc] initWithFrame:
              CGRectMake(0, screenFrame.size.height - BMTT_ROW_HEIGHT,
                         screenFrame.size.width, BMTT_ROW_HEIGHT)];
  if (self.navigationBarStyle == UIBarStyleDefault) {
    _toolbar.tintColor = BMTTSTYLEVAR(toolbarTintColor);
  }

  _toolbar.barStyle = self.navigationBarStyle;
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
  _toolbar.items = [NSArray arrayWithObjects:
                    space, _previousButton, space, _nextButton, space, nil];
  [_innerView addSubview:_toolbar];
    
    self.navigationController.navigationBar.translucent = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  BMTT_RELEASE_SAFELY(_innerView);
  BMTT_RELEASE_SAFELY(_scrollView);
  BMTT_RELEASE_SAFELY(_photoStatusView);
  BMTT_RELEASE_SAFELY(_nextButton);
  BMTT_RELEASE_SAFELY(_previousButton);
  BMTT_RELEASE_SAFELY(_toolbar);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
    BM_PUSH_IGNORE_DEPRECATION_WARNING
  [self updateToolbarWithOrientation:self.interfaceOrientation];
    BM_POP_IGNORE_WARNING
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [_scrollView cancelTouches];
  [self pauseAction];
  if (self.nextViewController) {
    [self showBars:YES animated:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return BMTTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)rotatingFooterView {
  return _toolbar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BMTTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {
    
    [super showBars:show animated:animated];
    
    CGFloat alpha = show ? 1 : 0;
    if (alpha == _toolbar.alpha)
        return;
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:BMTT_TRANSITION_DURATION];
        [UIView setAnimationDelegate:self];
        if (show) {
            [UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];
            
        } else {
            [UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
        }
        
    } else {
        if (show) {
            [self showBarsAnimationDidStop];
            
        } else {
            [self hideBarsAnimationDidStop];
        }
    }
    
    [self showCaptions:show];
    
    _toolbar.alpha = alpha;
    
    self.navigationController.navigationBarHidden = !show;
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (animated) {
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoad {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoadMore {
  return !_centerPhoto;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
  return _photoSource.numberOfPhotos > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
  [super didRefreshModel];
  [self updatePhotoView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
  [super didLoadModel:firstTime];
  if (firstTime) {
    [self updatePhotoView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
  [self showProgress:show ? 0 : -1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
  if (show) {
    [_scrollView reloadData];
    [self showStatus:BMTTLocalizedString(@"This photo set contains no photos.", @"")];

  } else {
    [self showStatus:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
  if (show) {
    [self showStatus:BMTTDescriptionForError(_modelError)];

  } else {
    [self showStatus:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToNextValidPhoto {
  if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
    // We were positioned at an index that is past the end, so move to the last photo
    [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];

  } else {
    [self moveToPhotoAtIndex:_centerPhotoIndex withDelay:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<BMTTModel>)model {
  if (model == _model) {
    if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
      [self moveToNextValidPhoto];
      [_scrollView reloadData];
      [self resetVisiblePhotoViews];

    } else {
      [self updateVisiblePhotoViews];
    }
  }
  [super modelDidFinishLoad:model];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BMTTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super model:model didFailLoadWithError:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<BMTTModel>)model {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super modelDidCancelLoad:model];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BMTTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BMTTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BMTTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if (object == self.centerPhoto) {
    [self showActivity:nil];
    [self moveToNextValidPhoto];
    [_scrollView reloadData];
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollView:(BMTTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(BMTTScrollView *)scrollView {
  [self cancelImageLoadTimer];
  [self showCaptions:NO];
  [self showBars:NO animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(BMTTScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillRotate:(BMTTScrollView*)scrollView
               toOrientation:(UIInterfaceOrientation)orientation {
  self.centerPhotoView.hidesExtras = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidRotate:(BMTTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldZoom:(BMTTScrollView*)scrollView {
  return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidBeginZooming:(BMTTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndZooming:(BMTTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollView:(BMTTScrollView*)scrollView tapped:(UITouch*)touch {
  if ([self isShowingChrome]) {
    [self showBars:NO animated:YES];

  } else {
    [self showBars:YES animated:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInScrollView:(BMTTScrollView*)scrollView {
  return _photoSource.numberOfPhotos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)scrollView:(BMTTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  BMTTPhotoView* photoView = (BMTTPhotoView*)[_scrollView dequeueReusablePage];
  if (!photoView) {
    photoView = [self createPhotoView];
      photoView.captionStyle = _captionStyle;
    photoView.defaultImage = _defaultImage;
    photoView.hidesCaption = _toolbar.alpha == 0;
  }

  id<BMTTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  [self showPhoto:photo inView:photoView];

  return photoView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)scrollView:(BMTTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  id<BMTTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  return photo ? photo.size : CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTThumbsViewControllerDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsViewController:(BMTTThumbsViewController*)controller didSelectPhoto:(id<BMTTPhoto>)photo {
  self.centerPhoto = photo;
    
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  BMTT_RELEASE_SAFELY(_thumbsController);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)thumbsViewController:(BMTTThumbsViewController*)controller
       shouldNavigateToPhoto:(id<BMTTPhoto>)photo {
  return NO;
}

- (void)thumbsViewControllerWasDismissed: (BMTTThumbsViewController*)controller {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  BMTT_RELEASE_SAFELY(_thumbsController);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoSource:(id<BMTTPhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    [self moveToPhotoAtIndex:0 withDelay:NO];
    self.model = _photoSource;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPhoto:(id<BMTTPhoto>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource release];
      _photoSource = [photo.photoSource retain];

      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      self.model = _photoSource;

    } else {
      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      [self refresh];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTPhotoView*)createPhotoView {
  return [[[BMTTPhotoView alloc] init] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTThumbsViewController*)createThumbsViewController {
  return [[[BMTTThumbsViewController alloc] initWithDelegate:self] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToPhoto:(id<BMTTPhoto>)photo fromPhoto:(id<BMTTPhoto>)fromPhoto {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(NSString*)title {
  if (title) {
    BMTTActivityLabel* label = [[[BMTTActivityLabel alloc]
                               initWithStyle:BMTTActivityLabelStyleBlackBezel] autorelease];
    label.tag = kActivityLabelTag;
    label.text = title;
    label.frame = _scrollView.frame;
    [_innerView addSubview:label];

    _scrollView.scrollEnabled = NO;

  } else {
    UIView* label = [_innerView viewWithTag:kActivityLabelTag];
    if (label) {
      [label removeFromSuperview];
    }

    _scrollView.scrollEnabled = YES;
  }
}

@end
