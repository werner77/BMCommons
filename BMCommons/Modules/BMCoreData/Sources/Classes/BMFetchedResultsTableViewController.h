//
//  BMFetchedResultsTableViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/13/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <BMCommons/BMTableViewController.h>

NS_ASSUME_NONNULL_BEGIN

/**
 TableViewController with support for showing core data objects and reloading automatically upon changes.
 */
@interface BMFetchedResultsTableViewController : BMTableViewController<NSFetchedResultsControllerDelegate> {
}

//Protected methods
 
/**
 Return true to show the section index on the right side of the specified table view
 */
- (BOOL)showSectionIndexForTableView:(UITableView *)theTableView; 

/**
 Returns the table view wired to the specified fetchedResultsController
 */
- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 Returns the animation to use when the specified fetchedResultsController signals a change in the underlying data
 */
- (UITableViewRowAnimation)animationForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController changeType:(NSFetchedResultsChangeType)type;

/**
 Returns the fetched results controller for the specified tableview. If no fetchedResultsController exists yet the method constructFetchedResultsControllerForTableView is called.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)theTableView;

/**
 Sub classes should override this method and return an initialized NSFetchedResultsController with a proper fetch request and sort parameters.
 */
- (NSFetchedResultsController *)constructFetchedResultsControllerForTableView:(UITableView *)theTableView;

//Methods that map UITableView indexpaths to the fetched results indexpaths. Default they do no conversion (return the same as input variable).

- (nullable id)objectAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView;

- (nullable NSIndexPath *)indexPathForObject:(id)object forTableView:(UITableView *)theTableView;

/**
 Converts the tableview indexpath to an indexpath suitable for the fetched results controller.
 */
- (NSIndexPath *)fetchedResultsIndexPathFromTableViewIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView;

/**
 Converts the tableview section to the section for the fetched results controller.
 */
- (NSUInteger)fetchedResultsSectionFromTableViewSection:(NSUInteger)section forTableView:(UITableView *)theTableView;

/**
 Converts the fetched results controller indexpath to an indexpath for the tableview.
 */
- (NSIndexPath *)tableViewIndexPathFromFetchedResultsIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView;

/**
 Converts the fetched results section to the tableview section.
 */
- (NSUInteger)tableViewSectionFromFetchedResultsSection:(NSUInteger)section forTableView:(UITableView *)theTableView;

/**
 Return true if the fetch request has changed in such a way that results have to be retrieved again and the cache should be purged.
 */
- (BOOL)shouldInvalidatedResultsForTableView:(UITableView *)theTableView;

@end

NS_ASSUME_NONNULL_END
