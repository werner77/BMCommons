//
//  BMTableViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/09/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMViewController.h>

@class BMTableHeaderDragRefreshView;
@class BMTableFooterDragLoadMoreView;
@class BMCache;

/**
 Base class for table view controllers that replaces UITableViewController. 
 
 Adds behavior for resizing the view when a keyboard appears, support for a custom background image view, drag to refresh/drag to load more, 
 automatic adjusting of content inset when a translucent navigation bar is present and model loading support amongst other things.
 */
@interface BMTableViewController : BMViewController<UITableViewDelegate, UITableViewDataSource>

/**
 The table view.
 */
@property(nonatomic, strong) IBOutlet UITableView *tableView;

/**
 Background image view to display.
 */
@property(nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

/**
 Whether the table view should scroll to the active table view cell when it becomes active. Default = NO.
 */
@property(nonatomic, assign) BOOL shouldScrollToActiveInputCell;

/**
 Whether the selected cell should be deselected when the view is shown. 
 
 Default = YES. If reloadDataOnEveryAppear == YES this has no effect.
 */
@property(nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;

/**
 Whether to call [tableView reloadData] everytime the view appears or only the first time. 
 
 Default is NO.
 */
@property(nonatomic, assign) BOOL reloadDataOnEveryAppear;

/**
 Whether [self load] should be called on the next appearance of the view. 
 
 This boolean is reset everytime viewWillAppear is called.
 */
@property (nonatomic, assign) BOOL loadOnNextAppear;

/**
 Whether the table view should automatically scroll when the keyboard appears. 
 
 Default is YES.
 */
@property(nonatomic, assign) BOOL shouldScrollForKeyboard;

/**
 Whether the content insets should be automatically adjusted such that content is not overlapped by the translucent navigation bar/tool bar if present.
 
 Default is NO.
 */
@property(nonatomic, assign) BOOL adjustContentInsetsForTranslucentBars;

/**
 Set to true to get rid of any margins or insets that are inserted by iOS7/8 by default for cells.
 */
@property(nonatomic, assign) BOOL removeInsetsAndMargins;

/**
 View to show when there is an error loading the model for the table view.
 */
@property(nonatomic, strong) IBOutlet UIView *errorView;

/**
 View to show when there are no rows to display currently.
 */
@property(nonatomic, strong) IBOutlet UIView *emptyView;

/**
 Sound file to use for playing a sound when the user drags to refresh the view.
 */
@property(nonatomic, strong) NSURL *dragRefreshSoundFileURL;

/**
 Cache to use for static cells, e.g. in form-like tableviews.
 */
@property(nonatomic, readonly) BMCache *cellCache;

/**
 Reference to the dragRefreshView.
 */
@property (nonatomic, readonly) BMTableHeaderDragRefreshView *dragRefreshView;

/**
 Reference to the dragLoadMoreView.
 */
@property (nonatomic, readonly) BMTableFooterDragLoadMoreView *dragLoadMoreView;

/**
 Returns the tableview cell that is or contains the current first responder view or nil if none is selected.
 */
@property (nonatomic, readonly) UITableViewCell *firstResponderCell;


- (id)initWithStyle:(UITableViewStyle)style;

/**
  Return the scrollview to resize when the keyboard appears. 
 
 By default returns self.tableView
  */
- (UIScrollView *)scrollView;

/**
 Reloads the table view from the data.
 
 Default just calls [UITableView reloadData]
 */
- (void)reloadData;

/**
 If shouldScrollToActiveInputCell==YES this method is invoked to scroll to the active cell
 */
- (void)scrollToCell:(UITableViewCell *)cell;

/**
 Override with anything other than CGRectNull, to use a custom target rectangle to scroll to when the specified
 cell is selected if shouldScrollToActiveInputCell is enabled.
 */
- (CGRect)scrollTargetRectForCell:(UITableViewCell *)cell;


#pragma mark - Error/Empty view

/**
 The frame to display the overlay empty/error view.
 
 Defaults to self.view.bounds
 */
- (CGRect)rectForOverlayView;

/**
 Shows the model, which is the tableview displaying cells depicting the model.
 */
- (void)showModel;

/**
 Shows the error overlay view, displaying the supplied error.
 */
- (void)showError:(NSError *)error;

/**
 Shows the empty overlay view.
 */
- (void)showEmpty;

/**
 Tests whether the error view is currently shown.
 */
- (BOOL)isShowingError;

/**
 Tests whether the empty view is currently shown.
 */
- (BOOL)isShowingEmpty;

/**
 Override this method to populate the errorView (self.errorView) with the specified error.
 
 This method is only called if self.errorView is not nil.
 */
- (void)constructErrorView:(UIView *)theErrorView withError:(NSError *)error;

/**
 Override this method to populate the empty view. 
 
 This method is only called if self.emptyView is not nil.
 */
- (void)constructEmptyView:(UIView *)theEmptyView;

@end

@interface BMTableViewController(ModelLoading)

/**
 Whether drag to refresh mode is enabled or not.
 */
@property (nonatomic, assign, getter = isDragToRefreshEnabled) BOOL dragToRefreshEnabled;

/**
 Whether drag to load more mode is enabled or not.
 */
@property (nonatomic, assign, getter = isDragToLoadMoreEnabled) BOOL dragToLoadMoreEnabled;

/**
 @name Model loading support, for drag to refresh/load more functionality. 
 
 These methods should be implemented by sub classes as appropriate.
 */

/**
* Should return YES when the model is loading (or refreshing)
*/
- (BOOL)isLoading;

/**
 Returns YES if the model is loading more results.
 */
- (BOOL)isLoadingMore;

/**
 Returns YES if the model is refreshing/reloading.
 */
- (BOOL)isReloading;

/**
* Should load the model
 
 Calls load: with argument NO.
*/
- (IBAction)load;

/**
 Loads the model
 
 @param more If set to true it loads more results otherwise it reloads from the start.
 */
- (void)load:(BOOL)more;

/**
 * Reloads the model, by default just calls load.
 */
- (IBAction)reload;

/**
 Resets the view such that it will reload upon the next appear or call load when it is already visible. 
 The lastLoadedDate is set to nil.
 It will also hide the empty and error views.
 */
- (IBAction)reset;

/**
 Returns true if finishedLoading was called at least once, i.e. lastLoadDate returns a non nil value.
 */
- (BOOL)isLoaded;

/**
* Return the date the model was last loaded successfully (the last time finishedLoading was called).
*/
- (NSDate *)lastLoadDate;

/**
* Should be called by subclasses to signal that loading began. This will show the dragToRefresh view in a proper state
*/
- (void)startedLoading;

/**
* Should be called by subclasses to signal that loading has ended. This will show the dragToRefresh view in a proper state.
*/
- (void)finishedLoadingWithSuccess:(BOOL)success;

/**
 The number of items shown.
 */
- (NSUInteger)shownCount;

/**
 The total number of items.
 */
- (NSUInteger)totalCount;

/**
 Name of an item.
 */
- (NSString *)itemName;

@end

@interface BMTableViewController(Protected)

- (void)firstResponderDidChange:(UIView *)firstResponderView;

@end
