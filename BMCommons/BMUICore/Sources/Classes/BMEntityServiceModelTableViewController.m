//
//  BMEntityServiceModelTableViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEntityServiceModelTableViewController.h>
#import <BMCommons/UIViewController+BMCommons.h>
#import <BMCommons/BMUICore.h>

@interface BMEntityServiceModelTableViewController (Private)

- (void)reloadMoreResultsCell;

@end

@implementation BMEntityServiceModelTableViewController {
    NSUInteger _batchSize;
    NSMutableArray *_entities;
    NSUInteger _totalCount;
}

@synthesize batchSize = _batchSize, entities = _entities;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _entities = [NSMutableArray new];
    
    //Set the data source when loading has completed
    self.tableView.dataSource = nil;
}

- (void)viewDidUnload {
    BM_RELEASE_SAFELY(_entities);
    [super viewDidUnload];
}


#pragma mark - Abstract methods

- (NSArray *)loadEntitiesWithFirstResult:(NSUInteger)firstResult maxResults:(NSUInteger)maxResults {
    return nil;
}

- (NSArray *)entitiesFromServiceResult:(id)result {
    return nil;
}

- (NSUInteger)totalCountFromServiceResult:(id)result {
    return 0;
}

- (BOOL)isEntityService:(id <BMService>)service {
    return YES;
}

- (NSIndexPath *)indexPathForMoreResultsCell {
    return nil;
}

#pragma mark - BMServiceDelegate

- (void)serviceDidStart:(id <BMService>)service {
    [super serviceDidStart:service];
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    [self showError:error];
    [super service:service failedWithError:error];
}

- (void)serviceWasCancelled:(id <BMService>)service {
    if (![self isShowingError]) {
        [self showApplicableView];    
    }
    [super serviceWasCancelled:service];
}

#pragma mark - Overridden methods

- (void)handleResult:(id)result forService:(id<BMService>)service {
    if ([self isEntityService:service]) {
        NSArray *entityArray = [self entitiesFromServiceResult:result];
        NSUInteger theCount = [self totalCountFromServiceResult:result];
        [self updateEntitiesWithArray:entityArray totalCount:theCount];
    }
    [self showApplicableView];
}

#pragma mark - BMTableViewController(ModelLoading)

- (void)load:(BOOL)more {
    [super load:more];
    NSArray *serviceResult = nil;
    if (more) {
        serviceResult = [self loadEntitiesWithFirstResult:self.entityCount maxResults:self.batchSize];
        [self reloadMoreResultsCell];
    } else {
        serviceResult = [self loadEntitiesWithFirstResult:0 maxResults:MAX(self.batchSize, self.entityCount)];
    }
    if (serviceResult) {
        [self updateEntitiesWithArray:serviceResult totalCount:serviceResult.count];
        [self showApplicableView];
    }
}

- (IBAction)reset {
    self.tableView.dataSource = nil;
    [_entities removeAllObjects];
    [self.tableView reloadData];
    [super reset];
}

- (void)updateEntitiesWithArray:(NSArray *)entityArray totalCount:(NSUInteger)theTotalCount {
    if (!self.isLoadingMore) {
        [_entities removeAllObjects];
    }
    [_entities addObjectsFromArray:entityArray];
    _totalCount = MAX(theTotalCount, self.entityCount);
}

- (void)insertEntity:(id)entity atIndex:(NSUInteger)index {
    [_entities insertObject:entity atIndex:index];
}

/**
 Removes an entity from the internal entity array.
 */
- (void)removeEntity:(id)entity {
    [_entities removeObject:entity];
}

- (void)removeEntityAtIndex:(NSUInteger)index {
    if (index < _entities.count) {
        [_entities removeObjectAtIndex:index];
    }
}

- (id)entityAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < _entities.count ? [_entities objectAtIndex:indexPath.row] : nil;
}

/**
 Updates the total entity count.
 */
- (void)setTotalCount:(NSUInteger)totalCount {
    _totalCount = totalCount;
}

- (void)showApplicableView {
    if (self.entityCount == 0 && self.emptyView) {
        [self showEmpty];
    } else {
        [self showModel];
    }
}

- (NSUInteger)entityCount {
    return _entities.count;
}

- (NSUInteger)shownCount {
    return self.entityCount;
}

- (NSUInteger)totalCount {
    return _totalCount;
}

#pragma mark - Overridden methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.entityCount;
    } else {
        return [super tableView:theTableView numberOfRowsInSection:section];
    }
    
}

@end

@implementation BMEntityServiceModelTableViewController (Private)

- (void)reloadMoreResultsCell {
    NSIndexPath *indexPath = [self indexPathForMoreResultsCell];
    
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
