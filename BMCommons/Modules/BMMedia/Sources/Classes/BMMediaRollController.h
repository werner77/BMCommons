//
//  BMMediaRollController.h
//  BMCommons
//
//  Created by Werner Altewischer on 17/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMMediaContainerThumbnailCell.h>

@class BMViewFactory;
@class BMMediaRollController;

/**
 Delegate for a BMMediaRollController.
 */
@protocol BMMediaRollControllerDelegate<NSObject>

@optional

/**
 Called when a media item is selected.
 */
- (void)mediaRollController:(BMMediaRollController *)controller didSelectMedia:(id <BMMediaContainer>)media atIndex:(NSUInteger)index;

/**
 Called when a media item is centered in multi-click mode.
 @see [BMMediaRollController multiClick]
 */
- (void)mediaRollController:(BMMediaRollController *)controller didCenterMedia:(id <BMMediaContainer>)media atIndex:(NSUInteger)index;

/**
 Used to customize the cell at the specified index.
 
 Default is UIViewContentModeScaleAspectFill.
 */
- (void)mediaRollController:(BMMediaRollController *)controller customizeCell:(BMMediaContainerThumbnailCell *)cell atIndex:(NSUInteger)index;

@end

/**
 A controller to display a table view with asynchronously loading media thumbnails.
 */
@interface BMMediaRollController : NSObject<UITableViewDataSource, UITableViewDelegate, BMMediaContainerDelegate>

@property(nonatomic, readonly) UITableView *tableView;
@property(nonatomic, weak) id <BMMediaRollControllerDelegate> delegate;

/**
 The identifier of the cell to load from the view factory. 
 
 Defaults to @"BMMediaRollThumbnailCell". The view factory should return an instance of BMMediaContainerThumbnailCell for the specified identifier.
 */
@property(nonatomic, copy) NSString *cellReuseIdentifier;

/**
 The array of data used as datasource for the media roll.
 
 The array should contain instances of BMMediaContainer. Set a new array of data to automatically reload the roll.
 */
@property(nonatomic, copy) NSArray *data;

/**
 Whether or not to snap to the nearest center cell.
 
 If true, the roll scrolls always automatically such that a cell is exactly centered.
 */
@property(nonatomic, assign) BOOL snap;

/**
 Whether one or two touches are necessary to select a cell.
 
 If set to true, first touch centers the item, next touch selects it. If false the item is selected directly.
 
 @see [BMMediaControllerDelegate mediaRollController:didSelectMedia:atIndex:]
 @see [BMMediaControllerDelegate mediaRollController:didCenterMedia:atIndex:]
 */
@property(nonatomic, assign) BOOL multiClick;

/**
 Whether or not to keep repeating the same images to create an infinitely scrolling roll.
 */
@property(nonatomic, assign) BOOL repeating;

/**
 If set to true the height of the cells is adjusted so that it matches their width.
 
 Set to YES to keep thumbnails square automatically, set to NO to let the tableview rowheight govern the height of the cells.
 Default is YES.
 */
@property(nonatomic, assign) BOOL squareThumbnails;

/**
 Initializes with the specified table view, factory and delegate. 
 
 If no factory is set, a default one is created using the [BMMedia bundle].
 
 @param tableView The tableview to use
 @param cellFactory The cell factory to use to instantiate new cells
 @param delegate Delegate for this controller
 */
- (id)initWithTableView:(UITableView *)tableView 
			cellFactory:(BMViewFactory *)cellFactory
			   delegate:(id <BMMediaRollControllerDelegate>)delegate;

/**
 Reloads the cell at the specified index.
 */
- (void)reloadCellAtIndex:(NSUInteger)index;

/**
 Reloads the entire roll.
 
 Reload is done automatically when the property data is set with a new data array.
 */
- (void)reload;

@end
