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
#import <UIKit/UIKit.h>
#import <BMThree20/Three20UI/BMTTThumbsTableViewCellDelegate.h>

@protocol BMTTPhotoSource;
@protocol BMTTTableViewDataSource;
@class BMTTPhotoViewController;
@protocol BMTTPhoto;
@class BMTTThumbsViewController;

@protocol BMTTThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController: (BMTTThumbsViewController*)controller
              didSelectPhoto: (id<BMTTPhoto>)photo;

- (void)thumbsViewControllerWasDismissed: (BMTTThumbsViewController*)controller;

@optional

- (BOOL)thumbsViewController: (BMTTThumbsViewController*)controller
       shouldNavigateToPhoto: (id<BMTTPhoto>)photo;

@end


@interface BMTTThumbsViewController : UITableViewController <BMTTThumbsTableViewCellDelegate> {
    id<BMTTPhotoSource>                   _photoSource;
    id<BMTTThumbsViewControllerDelegate>  _delegate;
    UISegmentedControl *_selectionControl;
}

@property (nonatomic, retain) id<BMTTPhotoSource>                   photoSource;
@property (nonatomic, assign) id<BMTTThumbsViewControllerDelegate>  delegate;

- (id)initWithDelegate:(id<BMTTThumbsViewControllerDelegate>)delegate;
- (id)initWithQuery:(NSDictionary*)query;

- (BMTTPhotoViewController*)createPhotoViewController;
- (BMTTThumbsTableViewCell *)createThumbsCellWithReuseIdentifier:(NSString *)identifier;

- (void)viewDidUnload;

@end
