//
//  BMFetchedResultsTableViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/13/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCoreData/BMFetchedResultsTableViewController.h>
#import <BMCore/BMCore.h>

@interface BMFetchedResultsTableViewController()
{
    NSMutableDictionary *_fetchedResultsControllers;
}

@end


@implementation BMFetchedResultsTableViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidUnload {
    for (id key in _fetchedResultsControllers) {
        NSFetchedResultsController *frc = _fetchedResultsControllers[key];
        frc.delegate = nil;
    }
    BM_RELEASE_SAFELY(_fetchedResultsControllers);
    [super viewDidUnload];
}

#pragma mark - 
#pragma mark UITableViewDelegate/DataSource default implementation

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0) 
    {
        section = [self fetchedResultsSectionFromTableViewSection:section forTableView:theTableView];
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
	return fetchController.sections.count;
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
    section = [self fetchedResultsSectionFromTableViewSection:section forTableView:theTableView];
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
    id <NSFetchedResultsSectionInfo> sectionInfo = [fetchController sections][section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)theTableView {
	if ([self showSectionIndexForTableView:theTableView]) {
		NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
		return [fetchController sectionIndexTitles];
	} else {
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)theTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
    NSInteger section = [fetchController sectionForSectionIndexTitle:title atIndex:index];
    return [self tableViewSectionFromFetchedResultsSection:section forTableView:theTableView];
}

#pragma mark -
#pragma mark Protected methods

//Should be overridden
- (NSFetchedResultsController *)constructFetchedResultsControllerForTableView:(UITableView *)theTableView {
    return nil;
}

- (BOOL)shouldInvalidatedResultsForTableView:(UITableView *)theTableView {
    return NO;
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)theTableView {
    if (!_fetchedResultsControllers) {
        _fetchedResultsControllers = [NSMutableDictionary new];
    }
    id <NSCopying> key = [self keyForTableView:theTableView];
    NSFetchedResultsController *frc = _fetchedResultsControllers[key];
    if (!frc || [self shouldInvalidatedResultsForTableView:theTableView]) {
        frc = [self constructFetchedResultsControllerForTableView:theTableView];
        frc.delegate = self;
        if (frc) {
            if ([frc cacheName]) {
                [NSFetchedResultsController deleteCacheWithName:[frc cacheName]];
            }
            NSError *error;
            if (![frc performFetch:&error]) {
                LogWarn(@"Could not perform fetch on CoreData: %@", error);
            }
            _fetchedResultsControllers[key] = frc;
        }
    }
    return frc;
}

- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	return self.tableView;
}

- (BOOL)showSectionIndexForTableView:(UITableView *)theTableView {
	return NO;
}

- (UITableViewRowAnimation)animationForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController changeType:(NSFetchedResultsChangeType)type {
    return self.viewState == BMViewStateVisible ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView {
    indexPath = [self fetchedResultsIndexPathFromTableViewIndexPath:indexPath forTableView:theTableView];
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
    id <NSFetchedResultsSectionInfo> sectionInfo = [fetchController sections][[indexPath section]];
    return [sectionInfo objects][indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object forTableView:(UITableView *)theTableView {
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:theTableView];
	NSUInteger section = 0;
	NSIndexPath *indexPath = nil;
	for (id <NSFetchedResultsSectionInfo> sectionInfo in [fetchController sections]) {		
        if (object) {
            NSUInteger rowIndex = [sectionInfo.objects indexOfObject:object];
            if (rowIndex != NSNotFound) {
                indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:section];
                break;
            }
        }
		section++;
	}
    return [self tableViewIndexPathFromFetchedResultsIndexPath:indexPath forTableView:theTableView];
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate implementation

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	UITableView *theTableView = [self tableViewForFetchedResultsController:controller];
    [theTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {   
	UITableView *theTableView = [self tableViewForFetchedResultsController:controller];
    indexPath = [self tableViewIndexPathFromFetchedResultsIndexPath:indexPath forTableView:[self tableViewForFetchedResultsController:controller]];
    newIndexPath = [self tableViewIndexPathFromFetchedResultsIndexPath:newIndexPath forTableView:[self tableViewForFetchedResultsController:controller]];
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [theTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:[self animationForFetchedResultsController:controller changeType:type]];
            break;
		} 
        case NSFetchedResultsChangeDelete: {
            [theTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self animationForFetchedResultsController:controller changeType:type]];
            break;
		}          
        case NSFetchedResultsChangeUpdate: {
			[theTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:[self animationForFetchedResultsController:controller changeType:type]];
            break;
		}
        case NSFetchedResultsChangeMove: {
            [theTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self animationForFetchedResultsController:controller changeType:type]];
            [theTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:[self animationForFetchedResultsController:controller changeType:type]];
            break;
		}
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableView *theTableView = [self tableViewForFetchedResultsController:controller];
    sectionIndex = [self tableViewSectionFromFetchedResultsSection:sectionIndex forTableView:theTableView];
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        case NSFetchedResultsChangeDelete: {
            [theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	UITableView *theTableView = [self tableViewForFetchedResultsController:controller];
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [theTableView endUpdates];
} 

#pragma mark - Methods to be overridden if there are conversions necessary for the index paths/sections

- (NSIndexPath *)fetchedResultsIndexPathFromTableViewIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView {
    return indexPath;
}

- (NSUInteger)fetchedResultsSectionFromTableViewSection:(NSUInteger)section forTableView:(UITableView *)theTableView {
    return section;
}

- (NSIndexPath *)tableViewIndexPathFromFetchedResultsIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)theTableView {
    return indexPath;
}

- (NSUInteger)tableViewSectionFromFetchedResultsSection:(NSUInteger)section forTableView:(UITableView *)theTableView {
    return section;
}

#pragma mark - Private

- (id <NSCopying>)keyForTableView:(UITableView *)theTableView {
    return @((NSInteger)theTableView);
}

@end
