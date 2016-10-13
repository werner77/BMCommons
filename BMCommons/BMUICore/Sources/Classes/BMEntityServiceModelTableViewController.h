//
//  BMEntityServiceModelTableViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMUICore/BMServiceModelTableViewController.h>
#import <BMCore/BMService.h>

/**
 BMTableViewController which loads entities using a BMService and represents the entities with a cell for each entity.
 
 Sub-classes should at least override the methods loadEntitiesWithFirstResult:maxResults: , entitiesFromServiceResult: and totalCountFromServiceResult: .
 
 By default this class overrides tableView:numberOfRowsInSection: to return self.entityCount rows for the first section.
 
 @see BMServiceModelTableViewController.
 */
@interface BMEntityServiceModelTableViewController : BMServiceModelTableViewController

/**
 The batch size for loading more results.
 */
@property (nonatomic, assign) NSUInteger batchSize;

/**
 The number of entities currently being displayed.
 */
@property(nonatomic, readonly) NSUInteger entityCount;

/**
 The array of currently loaded entities.
 */
@property(nonatomic, readonly) NSArray *entities;


@end

@interface BMEntityServiceModelTableViewController(Protected)

/**
 Method which adds the entities in the entityArray to the internal entities and updates the total count.
 
 This method is automatically called by the concrete implementation of [BMServiceModelTableViewController handleResult:forService:] which this class implements.
 */
- (void)updateEntitiesWithArray:(NSArray *)entityArray totalCount:(NSUInteger)theTotalCount;

/**
 Inserts an entity to the internal entities array.
 
 Set index to entities.count to append an entity to the array.
 */
- (void)insertEntity:(id)entity atIndex:(NSUInteger)index;

/**
 Removes an entity from the internal entity array.
 */
- (void)removeEntity:(id)entity;

- (void)removeEntityAtIndex:(NSUInteger)index;

/**
 Updates the total entity count.
 */
- (void)setTotalCount:(NSUInteger)totalCount;

/**
 Method which is called after loading to show the applicable view.
 
 It calls [BMTableViewController showEmpty] if entityCount == 0 and self.emptyView != nil, otherwise [BMTableViewController showModel] is called.
 */
- (void)showApplicableView;

/**
 Sub-classes should override this method to convert the result from the service to an NSArray containing entity objects which are represented by the tableview cells which this controller displays.
 */
- (NSArray *)entitiesFromServiceResult:(id)result;

/**
 Sub-classes should override this method to extract the total entity count (for all results over all batches, including the ones that are not yet loaded).
 */
- (NSUInteger)totalCountFromServiceResult:(id)result;

/**
 Sub-classes should override this method if there is more than one service executed by the class. 
 
 This method should only return YES for services that return a result that can be interpreted by entitiesFromServiceResult: and totalCountFromServiceResult:
 
 Default implementation is to always return YES.
 */
- (BOOL)isEntityService:(id <BMService>)service;

/**
 Should be overridden with a concrete implementation.
 
 Typically sub classes should instantiate a BMService implementation and call [BMServiceModelTableViewController performService:].
 The service should load an array of entities with the specified 0-based index for the first result to return and the specified batch size.
 */
- (NSArray *)loadEntitiesWithFirstResult:(NSUInteger)firstResult maxResults:(NSUInteger)maxResults;

/**
 If the table view contains a cell for the user to touch to load more results, this method should be implemented and return the indexpath for that cell. 
 
 The actual loading of more results is then automatically handled.
 */
- (NSIndexPath *)indexPathForMoreResultsCell;

/**
 Returns the entity at the specified indexpath which is by default the object at indexPath.row in the entities array.
 */
- (id)entityAtIndexPath:(NSIndexPath *)indexPath;

@end
