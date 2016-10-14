//
//  BMTableViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/09/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTableViewController.h>
#import <BMCommons/BMClickable.h>
#import "UIResponder+BMCommons.h"
#import "UIView+BMCommons.h"
#import <BMCommons/BMTableHeaderDragRefreshView.h>
#import <BMCommons/BMTableFooterDragLoadMoreView.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMCommons/BMCache.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMApplicationHelper.h>
#import <BMCommons/BMTableView.h>
#import <BMCommons/UIScreen+BMCommons.h>
#import <BMCommons/UITableViewCell+BMCommons.h>

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat kRefreshDeltaY = -65.0f;
static const CGFloat kLoadMoreDeltaY = -kRefreshDeltaY;

// The height of the refresh header when it is in its "loading" state.
static const CGFloat kHeaderVisibleHeight = 60.0f;

static const float kAnimationDuration = 0.3f;

@interface BMTableViewController (Private)

- (UIView *)firstResponderView;

- (void)responderDidBecomeFirst:(NSNotification *)notification;

- (void)scrollToActiveCell;

- (void)addOverlayView:(UIView *)view;

- (void)resetOverlayView;

- (void)showErrorView:(BOOL)show;

- (void)showEmptyView:(BOOL)show;

- (float)dragLoadMoreOffset;

- (void)repositionDragLoadMoreView;

- (void)adjustContentInsets;

- (CGFloat)contentOffsetY;

@end


@implementation BMTableViewController {
	IBOutlet UITableView *_tableView;
	IBOutlet UIImageView *_backgroundImageView;
	UITableViewStyle _tableViewStyle;
	BOOL _shouldScrollToActiveInputCell;
	BOOL _clearsSelectionOnViewWillAppear;
	CGFloat _keyboardHeight;
	CGFloat _resizeHeight;
	BOOL _shouldScrollForKeyboard;
    BOOL _reloadDataOnEveryAppear;
    NSDate *_lastLoadDate;
    BOOL _loading;
    BOOL _reloading;
    BMTableHeaderDragRefreshView *_dragRefreshView;
    BMTableFooterDragLoadMoreView *_dragLoadMoreView;
    BMCache *_cellCache;
    UIView *_errorView;
    UIView *_emptyView;
    UIView *_tableOverlayView;
    id <UITableViewDataSource> _dataSource;
    BOOL _loadOnNextAppear;
    NSURL *_dragRefreshSoundFileURL;
    BOOL _reloadingByDragging;
    
    BOOL _loadingMore;
    BOOL _showingEmpty;
    BOOL _showingError;
    BOOL _adjustContentInsetsForTranslucentBars;
    
    CGFloat _contentInsetTop;
    CGFloat _contentInsetBottom;
    
@private
    BOOL _dragToLoadMoreEnabled;
    BOOL _dragToRefreshEnabled;
}

@synthesize errorView = _errorView, emptyView = _emptyView;
@synthesize tableView = _tableView, backgroundImageView = _backgroundImageView, shouldScrollToActiveInputCell = _shouldScrollToActiveInputCell, clearsSelectionOnViewWillAppear = _clearsSelectionOnViewWillAppear, shouldScrollForKeyboard = _shouldScrollForKeyboard, reloadDataOnEveryAppear = _reloadDataOnEveryAppear, loadOnNextAppear = _loadOnNextAppear;
@synthesize dragRefreshSoundFileURL = _dragRefreshSoundFileURL;
@synthesize cellCache = _cellCache;
@synthesize dragRefreshView = _dragRefreshView, dragLoadMoreView = _dragLoadMoreView;
@synthesize adjustContentInsetsForTranslucentBars = _adjustContentInsetsForTranslucentBars;

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        _tableViewStyle = style;
    }
    return self;
}

- (void)commonInit {
    [super commonInit];
    _clearsSelectionOnViewWillAppear = YES;
    _shouldScrollToActiveInputCell = NO;
    _shouldScrollForKeyboard = YES;
    _adjustContentInsetsForTranslucentBars = NO;
    self.dragRefreshSoundFileURL = BMSTYLEVAR(dragRefreshSoundFileURL);
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    if ((self = [super initWithNibName:nibName bundle:bundle])) {
        _tableViewStyle = UITableViewStylePlain;
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(_dragRefreshSoundFileURL);
}

- (void)setView:(UIView *)v {
    [super setView:v];
    if ([v isKindOfClass:[UITableView class]] && self.tableView == nil) {
        self.tableView = (UITableView *) v;
    }
}

- (void)setTableView:(UITableView *)tableView {
    if (tableView != _tableView) {
        [_tableView removeFromSuperview];
        BM_RELEASE_SAFELY(_tableView);
        if (tableView != nil) {
            _tableView = tableView;
            if ([self isViewLoaded]) {
                if (_tableView != self.view) {
                    if (_tableView.superview != self.view) {
                        if (_tableView.superview != nil) {
                            [_tableView removeFromSuperview];
                        }
                        [self.view addSubview:_tableView];
                    }
                }
            }
        }
    }
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showingEmpty = NO;
    _showingError = NO;
    
    _cellCache = [BMCache new];
    
    if (!self.view) {
        //Create a table view and set it as the view
        self.view = [[BMTableView alloc] initWithFrame:[[UIScreen mainScreen] bmPortraitApplicationFrame] style:_tableViewStyle];
    } else if (!self.tableView) {
        self.tableView = [[BMTableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
        self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        UIColor *c = nil;
        if (self.tableView.style == UITableViewStylePlain) {
            c = BMSTYLEVAR(tableViewPlainBackgroundColor);
        } else {
            c = BMSTYLEVAR(tableViewGroupedBackgroundColor);
        }
        if (c) {
            self.tableView.backgroundColor = c;
        }
        
        c = BMSTYLEVAR(tableViewSeparatorColor);
        if (c) {
            self.tableView.separatorColor = c;
        }
        
        self.tableView.separatorStyle = BMSTYLEVAR(tableViewSeparatorStyle);
        self.tableView.rowHeight = BMSTYLEVAR(tableViewRowHeight);
    }
    
    if (!self.backgroundImageView) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    }
    
    if (!self.backgroundImageView.superview) {
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundImageView.frame = self.view.bounds;
        [self.view insertSubview:self.backgroundImageView atIndex:0];
    }
    
    if (!self.backgroundImageView.image) {
        UIImage *defaultBackgroundImage = BMSTYLEVAR(tableViewBackgroundImage);
        self.backgroundImageView.image = defaultBackgroundImage;
    }
    
    if (self.backgroundImageView.image && self.tableView.style == UITableViewStylePlain) {
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    
    if (self.tableView.delegate == nil) {
        self.tableView.delegate = self;
    }
    
    if (self.tableView.dataSource == nil) {
        self.tableView.dataSource = self;
    }
    
    if (self.tableView) {
        _tableViewStyle = self.tableView.style;
    }
    
    if (self.isDragToRefreshEnabled) {
        _dragRefreshView = [[BMTableHeaderDragRefreshView alloc]
                            initWithFrame:CGRectMake(0,
                                                     -self.tableView.bounds.size.height,
                                                     self.tableView.bounds.size.width,
                                                     self.tableView.bounds.size.height)];
        _dragRefreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_dragRefreshView setStatus:BMTableHeaderDragRefreshPullToReload];
        
        [self.tableView addSubview:_dragRefreshView];
    }
    
    if (self.isDragToLoadMoreEnabled) {
        _dragLoadMoreView = [[BMTableFooterDragLoadMoreView alloc]
                             initWithFrame:CGRectMake(0,
                                                      0,
                                                      self.tableView.bounds.size.width,
                                                      65.0f)];
        
        _dragLoadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (self.itemName) {
            _dragLoadMoreView.itemName = self.itemName;
        }
        [_dragLoadMoreView setStatus:BMTableFooterDragLoadMorePullToLoad];
        [self.tableView addSubview:_dragLoadMoreView];
        [_dragLoadMoreView setLoadedCount:0 withTotalCount:0];
    }
    
    _resizeHeight = 0.0f;
    _dataSource = self.tableView.dataSource;
    
    
    if (_tableViewStyle == UITableViewStyleGrouped) {
        //Hack needed for iOS 6 to display the dragLoadMoreView at the proper position, see:
        //http://stackoverflow.com/questions/12613336/extra-space-under-grouped-uitableview-in-popovers-on-ios-6
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,1.0f,1.0f)];
    }
    
    if (self.removeInsetsAndMargins) {
        [self.tableView bmRemoveMarginsAndInsets];
    }
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([@"contentSize" isEqual:keyPath]) {
        [self repositionDragLoadMoreView];
    }
}

- (void)viewDidUnload {
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    self.tableView = nil;
    BM_RELEASE_SAFELY(_backgroundImageView);
    BM_RELEASE_SAFELY(_lastLoadDate);
    BM_RELEASE_SAFELY(_dragRefreshView);
    BM_RELEASE_SAFELY(_dragLoadMoreView);
    BM_RELEASE_SAFELY(_cellCache);
    BM_RELEASE_SAFELY(_tableOverlayView);
    BM_RELEASE_SAFELY(_errorView);
    BM_RELEASE_SAFELY(_emptyView);
    if (_dataSource != self) {
        BM_RELEASE_SAFELY(_dataSource);
    }
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    BMViewState theViewState = self.viewState;
    [super viewWillAppear:animated];
    [self adjustContentInsets];
    if (theViewState == BMViewStateInvisible) {
        [_dragLoadMoreView setLoadedCount:self.shownCount withTotalCount:self.totalCount];
        if ((![self isLoaded] && ![self isShowingEmpty] && ![self isShowingError]) || self.loadOnNextAppear) {
            [self reload];
            self.loadOnNextAppear = NO;
        }
        if (self.firstAppearAfterLoad || self.reloadDataOnEveryAppear) {
            [self reloadData];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            if (indexPath && self.clearsSelectionOnViewWillAppear) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responderDidBecomeFirst:) name:BMResponderDidBecomeFirstNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BMResponderDidBecomeFirstNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ((self.isDragToRefreshEnabled || self.isDragToLoadMoreEnabled) && [self isLoading]) {
        //Do nothing
    } else {
        [self adjustContentInsets];
    }
}

- (void)localize {
    [super localize];
    if (self.viewState == BMViewStateVisible) {
        //Only reload if view visible, because otherwise viewWillAppear reloads the data
        [self reloadData];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *c = BMSTYLEVAR(tableViewCellBackgroundColor);
    if (c) {
        cell.backgroundColor = c;
    }
    
    if (self.removeInsetsAndMargins) {
        [cell bmRemoveMarginsAndInsets];
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCell = [theTableView cellForRowAtIndexPath:indexPath];
    if ([theCell conformsToProtocol:@protocol(BMClickable)]) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        [(id <BMClickable>) theCell onClick];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self.tableView setEditing:editing animated:animated];
    [super setEditing:editing animated:animated];
}

#pragma mark - UIScrollViewDelegate implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isDragToRefreshEnabled) {
        if (scrollView.dragging && ![self isLoading]) {
            if (self.contentOffsetY > kRefreshDeltaY
                && self.contentOffsetY < 0.0f) {
                [_dragRefreshView setStatus:
                 BMTableHeaderDragRefreshPullToReload];
                
            } else if (self.contentOffsetY < kRefreshDeltaY) {
                [_dragRefreshView setStatus:
                 BMTableHeaderDragRefreshReleaseToReload];
            }
        }
        
        // This is to prevent odd behavior with plain table section headers. They are affected by the
        // content inset, so if the table is scrolled such that there might be a section header abutting
        // the top, we need to clear the content inset.
        if ([self isLoading] && !_loadingMore) {
            if (self.contentOffsetY >= 0) {
                self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0, _contentInsetBottom, 0);
                
            } else if (self.contentOffsetY < 0) {
                self.tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight + _contentInsetTop, 0, _contentInsetBottom, 0);
            }
        }
    }
    
    if (self.isDragToLoadMoreEnabled && _dragLoadMoreView.status != BMTableFooterDragLoadMoreNothingMoreToLoad) {
        
        float dragLoadMoreOffset = self.dragLoadMoreOffset;
        
        if (scrollView.dragging && ![self isLoading]) {
            if (dragLoadMoreOffset > 0 && dragLoadMoreOffset < kLoadMoreDeltaY) {
                [_dragLoadMoreView setStatus:
                 BMTableFooterDragLoadMorePullToLoad];
            } else if (dragLoadMoreOffset > kLoadMoreDeltaY) {
                [_dragLoadMoreView setStatus:
                 BMTableFooterDragLoadMoreReleaseToLoad];
            }
        }
        
        if ([self isLoading] && _loadingMore) {
            if (dragLoadMoreOffset < 0) {
                self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0, _contentInsetBottom, 0);
            } else if (dragLoadMoreOffset > 0) {
                self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0, kHeaderVisibleHeight + _contentInsetBottom, 0);
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isDragToRefreshEnabled) {
        // If dragging ends and we are far enough to be fully showing the header view trigger a
        // load as long as we arent loading already
        if (self.contentOffsetY <= kRefreshDeltaY && ![self isLoading]) {
            _reloadingByDragging = YES;
            [self reload];
        }
    }
    
    if (self.isDragToLoadMoreEnabled && _dragLoadMoreView.status != BMTableFooterDragLoadMoreNothingMoreToLoad) {
        if (self.dragLoadMoreOffset >= kLoadMoreDeltaY && ![self isLoading]) {
            _reloadingByDragging = YES;
            [self load:YES];
        }
    }
}


#pragma mark -
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = info[UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        _keyboardHeight = keyboardSize.width;
    } else {
        _keyboardHeight = keyboardSize.height;
    }
    
    if (self.shouldScrollForKeyboard) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        //Convert the window frame to the local coordinate system
        CGRect visibleRect = [self.scrollView convertRect:window.bounds fromView:window];
        visibleRect.size.height -= _keyboardHeight;
        
        _resizeHeight = CGRectGetMaxY(self.scrollView.bounds) - CGRectGetMaxY(visibleRect);
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + _resizeHeight);
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0.0;
    if (self.shouldScrollForKeyboard) {
        [UIView beginAnimations:@"RestoreContentSize" context:nil];
        [UIView setAnimationDuration:0.3];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - _resizeHeight);
        _resizeHeight = 0.0f;
        [UIView commitAnimations];
    }
}


#pragma mark - Protected methods

- (UIScrollView *)scrollView {
    return self.tableView;
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - Scrolling

- (void)scrollToRect:(CGRect)rect inView:(UIView *)view {
    
    //Default behavior
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIScrollView *scrollView = self.scrollView;
    
    //Convert the window frame to the local coordinate system
    CGRect visibleRect = [scrollView convertRect:window.bounds fromView:window];
    visibleRect.size.height -= _keyboardHeight;
    
    visibleRect = CGRectOffset(visibleRect, - scrollView.contentOffset.x, - scrollView.contentOffset.y);
    
    CGFloat yOrigin = MAX(0, -visibleRect.origin.y);
    CGFloat xOrigin = MAX(0, -visibleRect.origin.x);
    
    visibleRect = CGRectMake(0, 0, visibleRect.size.width - xOrigin, visibleRect.size.height - yOrigin);
    
    CGRect cellRect = [scrollView convertRect:rect fromView:view];
    
    cellRect = CGRectOffset(cellRect, - scrollView.contentOffset.x, - scrollView.contentOffset.y);
    
    CGFloat margin = 20.0;
    CGFloat yOffsetMax = CGRectGetMaxY(visibleRect) - CGRectGetMaxY(cellRect) - margin;
    CGFloat yOffsetMin = CGRectGetMinY(cellRect) - CGRectGetMinY(visibleRect) - margin;
    
    if (yOffsetMax < 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - yOffsetMax) animated:YES];
    } else if (yOffsetMin < 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + yOffsetMin) animated:YES];
    }
}

- (void)scrollToCell:(UITableViewCell *)cell {
    
    CGRect theRect = [self scrollTargetRectForCell:cell];
    UIScrollView *scrollView = self.scrollView;
    CGRect cellRect = [scrollView convertRect:cell.bounds fromView:cell];
    
    if (CGRectIsNull(theRect)) {
        [self scrollToRect:cellRect inView:scrollView];
    } else {
        CGRect currentRect = CGRectOffset(cellRect, - scrollView.contentOffset.x, - scrollView.contentOffset.y);
        CGFloat diffY = CGRectGetMidY(currentRect) - CGRectGetMidY(theRect);
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + diffY) animated:YES];
    }
}

- (CGRect)scrollTargetRectForCell:(UITableViewCell *)cell {
    //If implemented the default scrolling behaviour can be overridden. The rect should be relative to self.view.
    return CGRectNull;
}

#pragma mark - Error/Empty view

- (CGRect)rectForOverlayView {
    return self.view.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showModel {
    [self showErrorView:NO];
    [self showEmptyView:NO];
    self.tableView.dataSource = _dataSource;
    self.tableView.hidden = NO;
    [self reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(NSError *)error {
    [self showEmptyView:NO];
    if (error && ![self isLoaded] && self.errorView) {
        [self constructErrorView:self.errorView withError:error];
        [self showErrorView:YES];
        self.tableView.dataSource = nil;
        self.tableView.hidden = YES;
        [self reloadData];
    } else {
        [self showErrorView:NO];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty {
    [self showErrorView:NO];
    if (self.emptyView) {
        [self constructEmptyView:self.emptyView];
        self.tableView.dataSource = nil;
        self.tableView.hidden = YES;
        [self showEmptyView:YES];
    } else {
        [self showEmptyView:NO];
    }
    [self reloadData];
}

- (BOOL)isShowingError {
    return _showingError;
}

- (BOOL)isShowingEmpty {
    return _showingEmpty;
}

- (void)constructErrorView:(UIView *)theErrorView withError:(NSError *)error {
}

- (void)constructEmptyView:(UIView *)theEmptyView {
}

#pragma mark - Other methods

- (UITableViewCell *)firstResponderCell {
    UIView *v = self.firstResponderView;
    while (v != nil) {
        if ([v isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)v;
        }
        v = v.superview;
    }
    return nil;
}

#pragma mark - Protected methods

- (void)firstResponderDidChange:(UIView *)firstResponderView {
    
}


@end

@implementation BMTableViewController (ModelLoading)

- (void)setDragToRefreshEnabled:(BOOL)aDragToRefreshEnabled {
    if (_dragToRefreshEnabled != aDragToRefreshEnabled) {
        _dragToRefreshEnabled = aDragToRefreshEnabled;
        if ([self isViewLoaded]) {
            if (_dragToRefreshEnabled) {
                [self.tableView addSubview:_dragRefreshView];
            } else {
                [_dragRefreshView removeFromSuperview];
            }
        }
    }
}

- (void)setDragToLoadMoreEnabled:(BOOL)b {
    if (_dragToLoadMoreEnabled != b) {
        _dragToLoadMoreEnabled = b;
        if ([self isViewLoaded]) {
            if (_dragToLoadMoreEnabled) {
                [_dragLoadMoreView setLoadedCount:self.shownCount withTotalCount:self.totalCount];
                [self.tableView addSubview:_dragLoadMoreView];
            } else {
                [_dragLoadMoreView removeFromSuperview];
            }
        }
    }
}

- (BOOL)isDragToLoadMoreEnabled {
    return _dragToLoadMoreEnabled;
}

- (BOOL)isDragToRefreshEnabled {
    return _dragToRefreshEnabled;
}

- (BOOL)isLoading {
    return _loading;
}

- (BOOL)isReloading {
    return _reloading;
}

- (BOOL)isLoadingMore {
    return _loadingMore;
}

- (BOOL)isLoaded {
    return _lastLoadDate != nil;
}

- (NSUInteger)shownCount {
    return 0;
}

- (NSUInteger)totalCount {
    return 0;
}

- (NSString *)itemName {
    return nil;
}

- (void)load:(BOOL)more {
    _loadingMore = more;
}

- (IBAction)load {
    [self load:NO];
}

- (IBAction)reload {
    _reloading = YES;
    [self load];
}

- (IBAction)reset {
    BM_RELEASE_SAFELY(_lastLoadDate);
    [self showEmptyView:NO];
    [self showErrorView:NO];
    if (self.viewState == BMViewStateVisible || self.viewState == BMViewStateToBecomeVisible) {
        [self load];
    }
}

- (NSDate *)lastLoadDate {
    return _lastLoadDate;
}

- (void)startedLoading {
    _loading = YES;
    
    if (self.isDragToRefreshEnabled) {
        [_dragRefreshView setStatus:BMTableHeaderDragRefreshLoading];
        
        if (self.contentOffsetY < 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kAnimationDuration];
            
            self.tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight + _contentInsetTop, 0.0f, _contentInsetBottom, 0.0f);
            [UIView commitAnimations];
        }
    }
    
    if (self.isDragToLoadMoreEnabled) {
        [_dragLoadMoreView setLoadedCount:self.shownCount withTotalCount:self.totalCount];
        [_dragLoadMoreView setStatus:BMTableFooterDragLoadMoreLoading];
        
        if (self.dragLoadMoreOffset > 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kAnimationDuration];
            self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0.0f, kHeaderVisibleHeight + _contentInsetBottom, 0.0f);
            [UIView commitAnimations];
        }
    }
}

- (void)finishedLoadingWithSuccess:(BOOL)success {
    if (self.isDragToRefreshEnabled || self.isDragToLoadMoreEnabled) {
        if (success && _reloadingByDragging && self.dragRefreshSoundFileURL != nil) {
            [BMApplicationHelper playSoundFromURL:self.dragRefreshSoundFileURL asAlert:NO];
        }
        
        [_dragRefreshView setStatus:BMTableHeaderDragRefreshPullToReload];
        [_dragLoadMoreView setStatus:BMTableFooterDragLoadMorePullToLoad];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kAnimationDuration];
        [self adjustContentInsets];
        self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0, _contentInsetBottom, 0);
        [UIView commitAnimations];
    }
    
    if (success) {
        if (!_lastLoadDate) {
            [self.tableView flashScrollIndicators];
        }
        _lastLoadDate = [NSDate date];
    }
    [_dragRefreshView setUpdateDate:[self lastLoadDate]];
    [_dragLoadMoreView setLoadedCount:self.shownCount withTotalCount:self.totalCount];
    _reloadingByDragging = NO;
    _loading = NO;
    _loadingMore = NO;
    _reloading = NO;
}

@end

@implementation BMTableViewController (Private)

- (UIView *)firstResponderView {
    UIView *firstResponder = self.scrollView.bmFirstResponder;
    return firstResponder;
}

- (void)scrollToActiveCell {
    UITableViewCell *firstResponderCell = [self firstResponderCell];
    if (firstResponderCell && self.shouldScrollToActiveInputCell) {
        [self scrollToCell:firstResponderCell];
    }
}

- (void)responderDidBecomeFirst:(NSNotification *)notification {
    [self firstResponderDidChange:self.firstResponderView];
    if (self.viewState == BMViewStateVisible) {
        [self scrollToActiveCell];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addOverlayView:(UIView *)view {
    if (!_tableOverlayView) {
        CGRect frame = [self rectForOverlayView];
        _tableOverlayView = [[UIView alloc] initWithFrame:frame];
        _tableOverlayView.autoresizesSubviews = YES;
        _tableOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleBottomMargin;
        NSInteger tableIndex = [self.tableView.superview.subviews indexOfObject:self.tableView];
        if (tableIndex != NSNotFound) {
            [self.tableView.superview addSubview:_tableOverlayView];
        }
    }
    
    view.frame = _tableOverlayView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableOverlayView addSubview:view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetOverlayView {
    if (_tableOverlayView && !_tableOverlayView.subviews.count) {
        [_tableOverlayView removeFromSuperview];
        BM_RELEASE_SAFELY(_tableOverlayView);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showErrorView:(BOOL)show {
    [_errorView removeFromSuperview];
    if (show) {
        _showingError = YES;
        [self addOverlayView:_errorView];
    } else {
        _showingError = NO;
        [self resetOverlayView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmptyView:(BOOL)show {
    [_emptyView removeFromSuperview];
    if (show) {
        _showingEmpty = YES;
        [self addOverlayView:_emptyView];
    } else {
        _showingEmpty = NO;
        [self resetOverlayView];
    }
}

- (float)dragLoadMoreOffset {
    UIScrollView *scrollView = self.tableView;
    float y = self.contentOffsetY + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    float h = self.tableView.contentSize.height + _contentInsetTop;
    return y - h;
}

- (void)repositionDragLoadMoreView {
    if (_dragLoadMoreView) {
        NSInteger numberOfSections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
        CGFloat sectionFooterHeight = 0.0f;
        
        //TODO: maybe this code should be disabled even for grouped style views.
        if (numberOfSections > 0 && self.tableView.style == UITableViewStyleGrouped) {
            sectionFooterHeight = self.tableView.sectionFooterHeight;
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
                sectionFooterHeight = [self.tableView.delegate tableView:self.tableView heightForFooterInSection:(numberOfSections - 1)];
            }
        }
        CGFloat contentSizeHeight = self.tableView.contentSize.height;
        _dragLoadMoreView.frame = CGRectMake(0, contentSizeHeight - sectionFooterHeight, self.tableView.frame.size.width, _dragLoadMoreView.frame.size.height);
    }
}

- (void)adjustContentInsets {
    if (self.adjustContentInsetsForTranslucentBars) {
        if (self.navigationController && self.navigationController.navigationBar.translucent) {
            _contentInsetTop = self.navigationController.navigationBar.frame.size.height;
        } else {
            _contentInsetTop = 0.0f;
        }
        if (self.navigationController.toolbar && !self.navigationController.toolbarHidden && self.navigationController.toolbar.translucent) {
            _contentInsetBottom = self.navigationController.toolbar.frame.size.height;
        }
        self.tableView.contentInset = UIEdgeInsetsMake(_contentInsetTop, 0, _contentInsetBottom, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }
}

- (CGFloat)contentOffsetY {
    return self.tableView.contentOffset.y + _contentInsetTop;
}

@end
