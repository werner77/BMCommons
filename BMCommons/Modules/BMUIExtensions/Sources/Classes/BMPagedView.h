//
//  BMPagedView.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMReusableObject.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BMPagedView;
@class BMPageControl;

/**
 Delegate protocol for BMPagedView.
 */
@protocol BMPagedViewDelegate<NSObject>

/**
 The number of pages to display in the paged view.
 */
- (NSUInteger)numberOfPagesInPagedView:(BMPagedView *)view;

/**
 The view to display on the page with the specified index.
 
 To reuse views use [BMPagedView dequeueReusableViewWithIdentifier:] just like you would when using a UITableView.
 
 @see [UITableView dequeueReusableCellWithIdentifier:]
 */
- (UIView*)pagedView:(BMPagedView *)view viewForPageAtIndex:(NSUInteger)page;

@optional

/**
 Called just before the paged view will change its selection index (changes selected page).
 
 @param oldIndex The selected page index before the change
 @param newIndex The selected page index after the change
 */
- (void)pagedView:(BMPagedView *)view willChangeSelectionFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;

/**
 Called just after the paged view did change its selection index (changes selected page).
 
 @param oldIndex The selected page index before the change
 @param newIndex The selected page index after the change
 */
- (void)pagedView:(BMPagedView *)view didChangeSelectionFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;

/**
 Should return the frame to display the page at the specified index.
 
 Defaults to [BMPagedView pageFrame].
 */
- (CGRect)pagedView:(BMPagedView *)view frameForPageAtIndex:(NSUInteger)index; 

@end

/**
 Class which mirrors UITableView but for horizontal scrollviews containing pages instead of cells.
 
 The home screen of an iOS device (springboard) is an example of a paged view.
 */
@interface BMPagedView : UIView<BMReusableObjectContainer> 

/**
 The delegate for this paged view.
 
 @see BMPagedViewDelegate.
 */
@property (nullable, nonatomic, weak) IBOutlet id <BMPagedViewDelegate> delegate;

/**
 Underlying scrollview.
 
 If not set explicitly it is initialized implicitly by this class and added as subview which has the same dimensions and scales with this view.
 */
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

/**
 Optional page control to use for displaying dots showing the selected index and total number of pages.
 */
@property (nullable, nonatomic, strong) IBOutlet BMPageControl *pageControl;

/**
 The frame to position the pages relative to the scrollview. 
 
 Defaults to CGRect(0,0,scrollView.size.width, scrollView.size.height) which scales the page over
 the scroll view.
 If the delegate implements frameForPageAtIndex that method takes precedence over this property.
 */
@property (nonatomic, assign) CGRect pageFrame;

/**
 The spacing in pixels to use between pages. 
 
 Default is 0.0.
 */
@property (nonatomic, assign) CGFloat pageSpacing;

/**
 Dequeues a reusable view with the specified identifier.
 
 Returns nil if none is available. Compare this method with [UITableView dequeueReusableCellWithIdentifier:]
 */
- (nullable UIView<BMReusableObject> *)dequeueReusableViewWithIdentifier:(NSString *)identifier;

/**
 Returns The view for the page at the specified index.
 */
- (nullable UIView *)viewForPageAtIndex:(NSUInteger)pageIndex;

/**
 Returns The view for the selected page.
 */
- (nullable UIView *)viewForSelectedPage;

/**
 Scrolls to the page at the specified index, optionally animating the scroll.
 */
- (void)scrollToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;

/**
 Gets the index for the selected page.
 */
- (NSInteger)indexForSelectedPage;

/**
 Reloads the data for this view.
 
 Compare with [UITableView reloadData].
 */
- (void)reloadData;

/**
 Reloads the data only for the selected page.
 
 @see reloadData
 */
- (void)reloadDataForSelectedPage;

@end

NS_ASSUME_NONNULL_END
