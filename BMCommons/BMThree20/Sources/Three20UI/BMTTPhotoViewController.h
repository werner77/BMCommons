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

// UI
#import <BMThree20/Three20UI/BMTTModelViewController.h>
#import <BMThree20/Three20UI/BMTTScrollViewDelegate.h>
#import <BMThree20/Three20UI/BMTTScrollViewDataSource.h>
#import <BMThree20/Three20UI/BMTTPhoto.h>
#import <BMThree20/Three20UI/BMTTThumbsViewController.h>

@protocol BMTTPhotoSource;
@class BMTTScrollView;
@class BMTTPhotoView;
@class BMTTStyle;

@interface BMTTPhotoViewController : BMTTModelViewController <
  BMTTScrollViewDelegate,
  BMTTScrollViewDataSource,
  BMTTThumbsViewControllerDelegate
> {
  id<BMTTPhoto>       _centerPhoto;
  NSInteger         _centerPhotoIndex;

  UIView*           _innerView;
  BMTTScrollView*     _scrollView;
  BMTTPhotoView*      _photoStatusView;

  UIToolbar*        _toolbar;
  UIBarButtonItem*  _nextButton;
  UIBarButtonItem*  _previousButton;

  UIImage*          _defaultImage;

  NSString*         _statusText;

  NSTimer*          _slideshowTimer;
  NSTimer*          _loadTimer;

  BOOL              _delayLoad;

  BMTTThumbsViewController* _thumbsController;

  id<BMTTPhotoSource> _photoSource;
        
    BMTTStyle* _captionStyle;
}

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property (nonatomic, retain) id<BMTTPhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property (nonatomic, retain) id<BMTTPhoto> centerPhoto;

/**
 * The index of the currently visible photo.
 *
 * Because centerPhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though centerPhoto has its own index property.
 */
@property (nonatomic, readonly) NSInteger centerPhotoIndex;

/**
 * The default image to show before a photo has been loaded.
 */
@property (nonatomic, retain) UIImage* defaultImage;

/**
 * The style to use for the caption label.
 */
@property (nonatomic, retain) BMTTStyle* captionStyle;

- (id)initWithPhoto:(id<BMTTPhoto>)photo;
- (id)initWithPhotoSource:(id<BMTTPhotoSource>)photoSource;

/**
 * Creates a photo view for a new page.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (BMTTPhotoView*)createPhotoView;

/**
 * Creates the thumbnail controller used by the "See All" button.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (BMTTThumbsViewController*)createThumbsViewController;

/**
 * Sent to the controller after it moves from one photo to another.
 */
- (void)didMoveToPhoto:(id<BMTTPhoto>)photo fromPhoto:(id<BMTTPhoto>)fromPhoto;

/**
 * Shows or hides an activity label on top of the photo.
 */
- (void)showActivity:(NSString*)title;

/**
 Updates the toolbar items for the specified orientation.
 */
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
