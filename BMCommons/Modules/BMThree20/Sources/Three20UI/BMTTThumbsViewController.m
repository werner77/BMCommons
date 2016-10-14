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

#import "Three20UI/BMTTThumbsViewController.h"

// UI
#import "Three20UI/BMTTThumbsTableViewCell.h"
#import "Three20UI/BMTTPhoto.h"
#import "Three20UI/BMTTPhotoSource.h"
#import "Three20UI/BMTTPhotoViewController.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/BMTTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/BMTTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Style
#import "Three20Style/BMTTGlobalStyle.h"
#import "Three20Style/BMTTStyleSheet.h"

// Core
#import "Three20Core/BMTTGlobalCoreLocale.h"
#import "Three20Core/BMTTGlobalCoreRects.h"
#import "Three20Core/BMTTCorePreprocessorMacros.h"

#import "Three20UI/BMTTLoadMoreTableViewCell.h"

#import <BMCommons/BMUICore.h>

static CGFloat kThumbnailRowHeight = 79;
static CGFloat kThumbSize = 75;
static CGFloat kThumbSpacing = 4;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTThumbsViewController {
    BMTTPhotoKind oriKind;
}

@synthesize delegate    = _delegate;
@synthesize photoSource = _photoSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<BMTTThumbsViewControllerDelegate>)delegate {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.delegate = delegate;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithQuery:(NSDictionary*)query {
    id<BMTTThumbsViewControllerDelegate> delegate = [query objectForKey:@"delegate"];
    if (nil != delegate) {
        self = [self initWithDelegate:delegate];
        
    } else {
        self = [self initWithNibName:nil bundle:nil];
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
    if ([self isViewLoaded]) {
        [self viewDidUnload];
    }
    [_photoSource.delegates removeObject:self];
    BMTT_RELEASE_SAFELY(_photoSource);
    
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoadingThumbnails:(BOOL)suspended {
    if (_photoSource.maxPhotoIndex >= 0) {
        NSArray* cells = self.tableView.visibleCells;
        for (int i = 0; i < cells.count; ++i) {
            BMTTThumbsTableViewCell* cell = [cells objectAtIndex:i];
            if ([cell isKindOfClass:[BMTTThumbsTableViewCell class]]) {
                [cell suspendLoading:suspended];
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForPhoto:(id<BMTTPhoto>)photo {
    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasMoreToLoad {
    return _photoSource.maxPhotoIndex+1 < _photoSource.numberOfPhotos && [_photoSource canLoad:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)columnCountForView:(UIView *)view {
    CGFloat width = view.bounds.size.width;
    return floorf((width - kThumbSpacing*2) / (kThumbSize+kThumbSpacing) + 0.1);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    self.tableView.rowHeight = kThumbnailRowHeight;
    self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = (UIColor *)BMTTSTYLEVAR(backgroundColor);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    
    self.tableView.sectionHeaderHeight = 4;
    
    _selectionControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:BMTTLocalizedString(@"All", nil),
                                                                  BMTTLocalizedString(@"Photos", nil),
                                                                  BMTTLocalizedString(@"Videos", nil), nil]];
    _selectionControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    int index = 0;
    
    oriKind = _photoSource.filteredPhotoKinds;
    
    if (_photoSource.filteredPhotoKinds == BMTTPhotoKindAll) {
        index = 0;
    } else if (_photoSource.filteredPhotoKinds == BMTTPhotoKindPicture) {
        index = 1;
    } else if (_photoSource.filteredPhotoKinds == BMTTPhotoKindVideo) {
        index = 2;
    }
    
    _selectionControl.selectedSegmentIndex = index;
    [_selectionControl addTarget:self action:@selector(onSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = _selectionControl;
}

- (void)viewDidUnload {
    BM_RELEASE_SAFELY(_selectionControl);
    _photoSource.filteredPhotoKinds = oriKind;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self suspendLoadingThumbnails:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated {
    [self suspendLoadingThumbnails:YES];
    [super viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return BMTTIsSupportedOrientation(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BMTTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<BMTTThumbsViewControllerDelegate>)delegate {
    _delegate = delegate;
    
    if (_delegate) {
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init]
                                                      autorelease]]
         autorelease];
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:BMTTLocalizedString(@"Done", @"")
                                          style:UIBarButtonItemStyleDone
                                         target:self
                                         action:@selector(removeFromSupercontroller)] autorelease];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTThumbsTableViewCellDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsTableViewCell:(BMTTThumbsTableViewCell*)cell didSelectPhoto:(id<BMTTPhoto>)photo {
    _photoSource.filteredPhotoKinds = oriKind;
    [_delegate thumbsViewController:self didSelectPhoto:photo];
    
    BOOL shouldNavigate = YES;
    if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
        shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
    }
    
    if (shouldNavigate) {
        BMTTPhotoViewController* controller = [self createPhotoViewController];
        controller.centerPhoto = photo;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
    [super removeFromSupercontrollerAnimated:animated];
    [_delegate thumbsViewControllerWasDismissed:self];
}

#pragma mark -
#pragma mark Actions

- (BMTTPhotoKind)selectedPhotoKind {
    BMTTPhotoKind ret = BMTTPhotoKindAll;
    if (_selectionControl.selectedSegmentIndex == 0) {
        ret = BMTTPhotoKindAll;
    } else if (_selectionControl.selectedSegmentIndex == 1) {
        ret = BMTTPhotoKindPicture;
    } else if (_selectionControl.selectedSegmentIndex == 2) {
        ret = BMTTPhotoKindVideo;
    }
    return ret;
}

- (void)onSelectionChanged:(id)sender {
    _photoSource.filteredPhotoKinds = [self selectedPhotoKind];
    [self.tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoSource:(id<BMTTPhotoSource>)photoSource {
    if (photoSource != _photoSource) {
        [_photoSource.delegates removeObject:self];
        
        [_photoSource release];
        _photoSource = [photoSource retain];
        [_photoSource.delegates addObject:self];
        
        self.title = _photoSource.title;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTPhotoViewController*)createPhotoViewController {
    return [[[BMTTPhotoViewController alloc] init] autorelease];
}

- (BMTTThumbsTableViewCell *)createThumbsCellWithReuseIdentifier:(NSString *)identifier {
    return [[[BMTTThumbsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
}

#pragma mark - UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger maxIndex = _photoSource.maxPhotoIndex;
    NSInteger columnCount = [self columnCountForView:tableView];
    if (maxIndex >= 0) {
        maxIndex += 1;
        NSInteger count =  ceil((maxIndex / columnCount) + (maxIndex % columnCount ? 1 : 0));
        return count + 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] -1) {
        return 44.0f;
    } else {
        return kThumbnailRowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] -1) {
        
        static NSString *kCellIdentifier = @"MoreCell";
        
        BMTTLoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (!cell) {
            cell = [[[BMTTLoadMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
        }
        
        [cell constructWithShownCount:_photoSource.maxPhotoIndex+1 totalCount:_photoSource.numberOfPhotos];
        [cell setAnimating:[self.photoSource isLoadingMore]];
        
        return cell;
    
    } else {
        static NSString *kCellIdentifier = @"ThumbsCell";
        
        BMTTThumbsTableViewCell* thumbsCell = (BMTTThumbsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        
        if (!thumbsCell) {
            thumbsCell = [self createThumbsCellWithReuseIdentifier:kCellIdentifier];
        }
        
        NSInteger columnCount = [self columnCountForView:tableView];
        id<BMTTPhoto> photo = [_photoSource photoAtIndex:indexPath.row * columnCount];
        
        [thumbsCell setPhoto:photo];
        thumbsCell.delegate = self;
        thumbsCell.columnCount = columnCount;
        
        return thumbsCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] -1) {
        
        if ([_photoSource canLoad:YES]) {
            BMTTLoadMoreTableViewCell *cell = (BMTTLoadMoreTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell setAnimating:YES];
            
            [_photoSource load:BMTTURLRequestCachePolicyDefault more:YES];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

#pragma mark - BMTTModelDelegate

- (void)modelDidStartLoad:(id<BMTTModel>)model {
    
}

- (void)modelDidFinishLoad:(id<BMTTModel>)model {
    [self.tableView reloadData];
}

- (void)model:(id<BMTTModel>)model didFailLoadWithError:(NSError*)error {
    
}

- (void)modelDidCancelLoad:(id<BMTTModel>)model {
    [self.tableView reloadData];
}

@end
