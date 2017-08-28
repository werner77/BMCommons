//
//  BMCoreDataHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BMCoreDataSaveCompletionBlock)(id _Nullable result, NSError * _Nullable error);
typedef id _Nullable (^BMCoreDataBlock)(NSManagedObjectContext * _Nonnull context);

typedef NS_ENUM(NSUInteger, BMCoreDataSaveMode) {
    BMCoreDataSaveModeNone = 0,
    BMCoreDataSaveModeSingle = 1,
    BMCoreDataSaveModeRecursive = 2
};

#define PREFETCH_PATHS_ALL [NSArray arrayWithObject:[NSNull null]]

@interface BMCoreDataHelper : NSObject

#pragma mark -
#pragma mark Fetching

/**
 * Fetches an object with the specified entity name and objectURI. Returns nil if it doesn't exist.
 */
+ (nullable id)fetchObjectWithObjectURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)context;

/**
 * Fetches an object with the specified object URI. Returns nil if it doesn't exist.
 */
+ (nullable id)fetchObjectWithEntityName:(NSString *)name objectURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)context;

/**
 * Executes the supplied fetch request and returns the first entity if a result is found or nil if none was found or in case of an error (error is logged)
 */
+ (nullable id)executeFetchRequestForSingleEntity:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

/**
 * Executes the supplied fetch request by sorting on the supplied key and order and returns the first entity if a result is found or nil if none was found or in
 case of an error (error is logged)
 */
+ (nullable id)executeFetchRequestForSingleEntity:(NSFetchRequest *)request withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending
                               inContext:(NSManagedObjectContext *)context;

/**
 * Executes a fetch request while optionally sorting on the specified key and order.
 */
+ (nullable NSArray *)executeFetchRequest:(NSFetchRequest *)request withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

/**
 Executes a fetch request for a single entity from the specified template using the specified substition variables.
 The optional array of prefetchPaths is for performance tuning. It will prefetch the relationships specified by the keypaths.
 */
+ (nullable id)executeFetchRequestForSingleEntityFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                         withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending prefetchPaths:(nullable NSArray *)prefetchPaths
                                           inContext:(NSManagedObjectContext *)context;

/**
 * Convenience method, bypassing the need to do the NSFetchRequest lookup yourself.
 */
+ (nullable id)executeFetchRequestForSingleEntityFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                           inContext:(NSManagedObjectContext *)context;

/**
 * Enumerates objects using the fetch request from the specified template name and subsitution variables and sorting based on the supplied sortKey and order.
 * The enumeration ensures that memory usage is efficient (only keeping a small amount of objects in memory at the same time)
 */
+ (NSEnumerator *)enumerateObjectsInObjectContext:(NSManagedObjectContext *)context withRequestTemplateName:(NSString *)requestTemplateName
                        withSubstitutionVariables:(NSDictionary *)substitutionVariables withSortKey:(NSString *)sortKey ascending:(BOOL)ascending;

/**
 Adds prefetchpaths for performance tuning.
 */
+ (nullable NSEnumerator *)enumerateObjectsInObjectContext:(NSManagedObjectContext *)context withRequestTemplateName:(NSString *)requestTemplateName
                        withSubstitutionVariables:(NSDictionary *)substitutionVariables withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending
                                    prefetchPaths:(nullable NSArray *)prefetchPaths;

+ (nullable NSFetchRequest *)fetchRequestFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                 withSortKey:(nullable NSString *)sortKey
                                   ascending:(BOOL)ascending
                               prefetchPaths:(nullable NSArray *)prefetchPaths
                                   inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countForFetchRequest:(NSFetchRequest *)fr inContext:(NSManagedObjectContext *)context;

/**
 Executes a fetch request for multiple entities from a template.
 */
+ (nullable NSArray *)executeFetchRequestFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                 withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending prefetchPaths:(nullable NSArray *)prefetchPaths
                                   inContext:(NSManagedObjectContext *)context;

+ (nullable NSArray *)executeFetchRequestFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                   inContext:(NSManagedObjectContext *)context;


#if TARGET_OS_IPHONE

/**
 Returns a fetch results controller for which the performFetch method has already been called. It loads the fetch request from the specified template name by
 substituting the supplied substitution variables.
 */
+ (NSFetchedResultsController *) fetchedResultsControllerFromTemplate:(NSString *)templateName
                                            withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                                  withSortDescriptors:(nullable NSArray *)sortDescriptors
                                               withSectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                                                        withCacheName:(nullable NSString *)cacheName
                                                            inContext:(NSManagedObjectContext *)context;
#endif



/**
 * Returns all objects of the specified type, optionally sorting them with the supplied parameters.
 * Be careful when using this method if there is a large number of the specified entity in the database since it may be heavy on mem usage.
 */
+ (nullable NSArray *)allEntitiesOfName:(NSString *)name withSortKey:(nullable NSString *)sortKey ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

/**
 Prefetches the specified relationship for the entity with the specified name. If the objects array is supplied, only those objects are prefetched (they should be
 instances of the entity supplied).
 */
+ (void)prefetchRelationship:(NSString *)relationshipName forEntityName:(NSString *)entityName forObjects:(NSArray *)objects inContext:(NSManagedObjectContext *)context;


/**
 Prefetches the supplied entities (should al be instances of the entity with the supplied entityName)
 */
+ (void)prefetchEntities:(NSArray *)entities withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;

#pragma mark -
#pragma mark Methods for managing object context

/**
 * Turns the specified object into a fault thereby releasing its memory
 */
+ (void)faultObject:(NSManagedObject *)managedObject keepChanges:(BOOL)keepChanges;

/**
 Refreshes the state of an object from the database.
 */
+ (void)refreshObject:(NSManagedObject *)managedObject;

/**
 * Turns the entire object graph reachable from the supplied object into a fault
 */
+ (void)faultObjectGraphForObject:(NSManagedObject *)managedObject keepChanges:(BOOL)keepChanges;

/**
 Refreshses the entire object graph reachable from the supplied object.
 */
+ (void)refreshObjectGraphForObject:(NSManagedObject *)managedObject;


/**
 * Convenience method to retrieve the managed object model from a context
 */
+ (nullable NSManagedObjectModel *)managedObjectModelFromContext:(NSManagedObjectContext *)context;

/**
 * Removes (deletes) the specified object from its managed object context
 */
+ (void)removeObject:(NSManagedObject *)object;

/**
 Removes all entities of the specified name from the context.
 */
+ (void)removeAllEntitiesOfName:(NSString *)entityName fromContext:(NSManagedObjectContext *)context;

+ (BOOL)saveContext:(NSManagedObjectContext *)context;

+ (BOOL)saveContext:(NSManagedObjectContext *)context withError:(NSError * _Nullable * _Nullable)error;

/**
 Saves the specified object context using it's own queue with performBlock: and optionally recurses into it's parent contexts also saving those.
 
 The completion block is performed on the main thread when done. If there was an error it is available as a parameter to the completion block.
 */
+ (void)saveContext:(NSManagedObjectContext *)context recursively:(BOOL)recursively completionContext:(nullable NSManagedObjectContext *)completionContext completion:(nullable BMCoreDataSaveCompletionBlock)completion;

/**
 Performs the specified core data block using performBlock: on the specified managed object context.
 
 If the save mode is single the specified context is saved afterwards.
 If the save mode is recursive the specified context and all parent contexts are saved afterwards.
 
 If the completion context is specified the completion block will be triggered as soon as the completion context has been processed. If nil, the completion block will be triggered after there are no more parents to process.
 
 The completion block is called after save has completed or if an error occured during saving. The error is specified as argument to the completion block.
 */
+ (void)performCoreDataBlock:(BMCoreDataBlock)block onContext:(NSManagedObjectContext *)context saveMode:(BMCoreDataSaveMode)saveMode completionContext:(nullable NSManagedObjectContext *)completionContext completion:(nullable BMCoreDataSaveCompletionBlock)completion;

+ (BOOL)saveObject:(NSManagedObject *)object;

+ (BOOL)saveObject:(NSManagedObject *)object withError:(NSError *_Nullable *_Nullable)error;

+ (BOOL)isObject:(id)object kindOfEntity:(NSString *)entityName;

#pragma mark -
#pragma mark Object context querying

/**
 * Gets the object count of entities with the specified name
 */
+ (NSUInteger)numEntitiesOfName:(NSString *)name inContext:(NSManagedObjectContext *)managedObjectContext;

/**
 * Gets the total number of objects in the specified context while optionally printing the numbers in the console per entity name.
 */
+ (NSUInteger)numEntitiesWithPrinting:(BOOL)printing inContext:(NSManagedObjectContext *)managedObjectContext;

/**
 * Gets the total number of objects in the specified context
 */
+ (NSUInteger)numEntitiesInContext:(NSManagedObjectContext *)managedObjectContext;

/**
 Checks for validation errors in the supplied object. Returns true upon success. Optionally specific entities may be excluded from the check.
 */
+ (BOOL)confirmObjectValidity:(NSManagedObject *)managedObject excludeEntities:(nullable NSArray *)excludeEntities;

/**
 * Copies the attributes and relationships of the source object to the destination object. This method works recursively and makes a deep copy,
 * which means that for any objects part of a relationship in the source object new objects are created in the destination context.
 * This means that the managed object contexts of source and destination can be different as long as they have the same entity model.
 * The method returns true upon success and false upon failure (e.g. if sourceObject and destinationObject are not of the same class)
 * TODO: method doesn't work as expected, should be debugged
 */
+ (BOOL)copyObject:(NSManagedObject *)sourceObject toObject:(NSManagedObject *)destinationObject;

/**
 Compares the attributes between the two specified objects. Returns true if and only if the objects are of the same class and all the attributes are either the same (==) or equal (isEqual:)
 */
+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2;

/**
 The same as isAttributesEqualForObject:andObject: but performs a recursive check, also including child objects.
 */
+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2 recursive:(BOOL)recursive;

/**
 Traverses the entire reachable object graph starting from the specified entity and performs the block on it.
 It will visit each entity only once using the handledObjects set.
 If the block returns NO the entity is not handled and skipped from recursion.
 */
+ (void)traverseObjectGraphForEntity:(NSManagedObject *)theEntity
                    handledObjects:(nullable NSMutableSet *)handledObjects
                        withBlock:(BOOL (^)(NSManagedObject *entity, NSManagedObject * _Nullable parentEntity, NSRelationshipDescription * _Nullable parentRelationship))block;

@end

NS_ASSUME_NONNULL_END
