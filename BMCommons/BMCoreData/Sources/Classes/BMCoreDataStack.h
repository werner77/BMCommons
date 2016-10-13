//
//  BMCoreDataStack.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/7/09.
//  Copyright 2010 BehindMedia All rights reserved.
//

#import <CoreData/CoreData.h>
#import <BMCoreData/BMCoreDataHelper.h>
#import <BMCoreData/BMManagedObjectContext.h>
#import <BMCoreData/BMCoreDataStoreCollectionDescriptor.h>

@interface BMCoreDataStack : NSObject 

/**
 Initializes with a model name and version. The store URL is deducted from these two as "$ModelName$ModelVersion.sqlite". The file resides in the
 documents directory.
 */
- (id)initWithModelName:(NSString *)modelName modelVersion:(NSInteger)version;

/**
 Initializes with an array of BMCoreDataStoreDescriptor (one for each separate store, a store may contain multiple models/configurations).
 
 This is the designated initializer.
 */
- (id)initWithStoreCollectionDescriptor:(BMCoreDataStoreCollectionDescriptor *)theStoreCollectionDescriptor;

/**
 Gets the existing coredata managed object context for the main thread.
 This context has main concurrency type.
 
 Only use this context within the main thread or use performBlock: or performBlockAndWait: to perform changes on it.
 
 This context is not tied directly to the persistent store. Use flushWithCompletion: to save changes to the persistent store or recursively save the parents.
 
 @see [BMCoreDataHelper saveContext:recursively:withCompletion:]
 */
- (BMManagedObjectContext *)mainObjectContext;

/**
 * An autoreleased in-memory object context. Changes are not persisted. Has containment concurrency type.
 */
- (BMManagedObjectContext *)memoryObjectContext;

/**
 An object context for background processing. Has private queue concurrency type.
 */
- (BMManagedObjectContext *)backgroundObjectContext;

/**
 Object context that actually writes to the persistent store. Has private queue concurrency type.
 */
- (BMManagedObjectContext *)persistentObjectContext;

/**
 An autorelease temporary object context. Has private queue concurrency type.
 */
- (BMManagedObjectContext *)temporaryObjectContext;

/**
 An autoreleased temporary object context of the specified concurrency type.
 */
- (BMManagedObjectContext *)temporaryObjectContextOfConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

/**
 Flushes changes to the datastore with the specified completion block.
 */
- (void)flushWithCompletion:(BMCoreDataSaveCompletionBlock)completion;

/**
 Looks in the documents directory for an existing version of the store. The version number is deducted from the filename.
 If found the store is upgraded to the most recent version by doing a coredata migration.
 If automatic is YES the migration uses the inferred mapping model (automatic Core data migration, see documentation) otherwise the bundle is searched for a core data mapping model to use for the upgrade.
 */
- (BOOL)migrateModel:(BOOL)automatic withStoreCollectionDescriptor:(BMCoreDataStoreCollectionDescriptor *)oldStoreCollectionDescriptor;


/**
 The managed object model
 */
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/**
 The persistent store coordinator
 */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 The descriptor for the datastores managed by this stack.
 */
@property (nonatomic, strong, readonly) BMCoreDataStoreCollectionDescriptor *storeCollectionDescriptor;

/**
 The merge policy used when the contexts are constructed.
 
 Defaults to NSMergeByPropertyStoreTrumpMergePolicy
 */
@property (nonatomic, strong) id defaultMergePolicy;

/**
 Convenience method to perform a core data block with optional background processing and save upon completion.
 */
- (void)performCoreDataBlock:(BMCoreDataBlock)block inBackground:(BOOL)background saveMode:(BMCoreDataSaveMode)saveMode completion:(BMCoreDataSaveCompletionBlock)completion;

/**
 Resets the entire internal state, optionally also removing the underlying store.
 */
- (void)resetByRemovingStore:(BOOL)removeStore;

@end
