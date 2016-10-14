//
//  BMCoreDataStack.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/7/09.
//  Copyright 2010 BehindMedia All rights reserved.
//

#import <BMCommons/BMCoreDataStoreCollectionDescriptor.h>
#import <BMCommons/BMCoreDataStack.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMCoreDataHelper.h>
#import <BMCommons/BMCoreDataStoreDescriptor.h>
#import <BMCommons/BMCoreDataModelDescriptor.h>
#import <BMCommons/BMCoreDataStoreDescriptor.h>
#import <BMCommons/BMCoreDataModelDescriptor.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSManagedObjectContext+BMCommons.h>

@interface BMCoreDataStack (Private)

- (BMManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForStoreType:(NSString *)theStoreType;
- (BOOL)addPersistentStoreWithConfiguration:(NSString*)theConfiguration storeURL:(NSURL*)theUrl storeType:(NSString *)theStoreType;
- (BOOL)migrateStoreWithOldDescriptor:(BMCoreDataStoreDescriptor *)oldDescriptor toNewDescriptor:(BMCoreDataStoreDescriptor *)newDescriptor automatic:(BOOL)automatic;

@end

@implementation BMCoreDataStack {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    BMCoreDataStoreCollectionDescriptor *_storeCollectionDescriptor;
    BMManagedObjectContext *_persistentObjectContext;
    BMManagedObjectContext *_mainObjectContext;
    BMManagedObjectContext *_backgroundObjectContext;
}

@synthesize storeCollectionDescriptor = _storeCollectionDescriptor;

#pragma mark -
#pragma mark Initialization and Deallocation

- (id)initWithModelName:(NSString *)theModelName modelVersion:(NSInteger)theModelVersion {
    BMCoreDataStoreDescriptor *storeDescriptor = [BMCoreDataStoreDescriptor storeDescriptorWithModelName:theModelName version:theModelVersion configuration:nil];
    BMCoreDataStoreCollectionDescriptor *collectionDescriptor = [BMCoreDataStoreCollectionDescriptor storeCollectionDescriptorWithStoreDescriptors:@[storeDescriptor]];
    return [self initWithStoreCollectionDescriptor:collectionDescriptor];
}

- (id)initWithStoreCollectionDescriptor:(BMCoreDataStoreCollectionDescriptor *)theStoreCollectionDescriptor {
    if ((self = [super init])) {
        _storeCollectionDescriptor = theStoreCollectionDescriptor;
        self.defaultMergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    }
    return self;
}

- (void)dealloc {
}

- (void)resetByRemovingStore:(BOOL)removeStore {
    _managedObjectModel = nil;
    _persistentObjectContext = nil;
    _persistentStoreCoordinator = nil;
    _mainObjectContext = nil;
    _backgroundObjectContext = nil;
    
    if (removeStore) {
        for (BMCoreDataStoreDescriptor *storeDescriptor in self.storeCollectionDescriptor.storeDescriptors) {
            NSError *error = nil;
            
            NSString *storeFilePath = [storeDescriptor.storeURL path];
            NSString *storeFileName = [storeFilePath lastPathComponent];
            NSString *directory = [storeFilePath stringByDeletingLastPathComponent];
            
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
            
            for (NSString *fileName in files) {
                if ([fileName hasPrefix:storeFileName]) {
                    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
                    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                        LogWarn(@"Could not remove store: %@", error);
                    }
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Core Data stack

- (BMManagedObjectContext *)memoryObjectContext {
    BMManagedObjectContext *managedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorForStoreType:NSInMemoryStoreType];
    
    if (coordinator != nil) {
        managedObjectContext = [[BMManagedObjectContext alloc] init];
        [managedObjectContext setUndoManager:nil];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


- (BMManagedObjectContext *)persistentObjectContext {
    @synchronized(self) {
        if (_persistentObjectContext == nil) {
            _persistentObjectContext = [self managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
        }
        return _persistentObjectContext;
    }
}

- (BMManagedObjectContext *)mainObjectContext {
    @synchronized(self) {
        if (_mainObjectContext == nil) {
            _mainObjectContext = [[BMManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _mainObjectContext.parentContext = self.persistentObjectContext;
        }
        return _mainObjectContext;
    }
}

- (BMManagedObjectContext *)temporaryObjectContextOfConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    BMManagedObjectContext* tempObjectContext = [[BMManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    tempObjectContext.parentContext = self.mainObjectContext;
    return tempObjectContext;
}

- (BMManagedObjectContext *)temporaryObjectContext {
    return [self temporaryObjectContextOfConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (BMManagedObjectContext *)backgroundObjectContext {
    @synchronized(self) {
        if (_backgroundObjectContext == nil) {
            _backgroundObjectContext = [self temporaryObjectContext];
        }
        return _backgroundObjectContext;
    }
}

- (void)flushWithCompletion:(BMCoreDataSaveCompletionBlock)completion {
    [BMCoreDataHelper saveContext:self.persistentObjectContext recursively:NO completionContext:nil completion:completion];
}

- (void)performCoreDataBlock:(BMCoreDataBlock)block inBackground:(BOOL)background saveMode:(BMCoreDataSaveMode)saveMode completion:(BMCoreDataSaveCompletionBlock)completion {
    NSManagedObjectContext *context;
    if (background) {
        context = self.backgroundObjectContext;
    } else {
        context = self.mainObjectContext;
    }
    [context bmPerformCoreDataBlock:block saveMode:saveMode completionContext:self.mainObjectContext completion:completion];
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    @synchronized(self) {
        if (_managedObjectModel != nil) {
            return _managedObjectModel;
        }
        
        NSMutableArray *models = [NSMutableArray new];
        
        NSMutableArray *handledModelURLs = [NSMutableArray new];
        
        for (BMCoreDataStoreDescriptor *storeDescriptor in self.storeCollectionDescriptor.storeDescriptors) {
            for (BMCoreDataModelDescriptor *modelDescriptor in storeDescriptor.modelDescriptors) {
                NSURL *modelURL = modelDescriptor.modelURL;
                if (modelURL && ![handledModelURLs containsObject:modelURL]) {
                    LogInfo(@"Loading object model from URL: %@", modelURL);
                    NSManagedObjectModel *theModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
                    if (theModel) {
                        [models addObject:theModel];
                    } else {
                        LogError(@"Could not load core data model from URL: %@", modelURL);
                    }
                    [handledModelURLs addObject:modelURL];
                }
            }
        }
        
        if (models.count > 1) {
            _managedObjectModel = [NSManagedObjectModel modelByMergingModels:models];
        } else if (models.count == 1) {
            _managedObjectModel = models[0];
        }
        
        
        return _managedObjectModel;
    }
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 
 If an error occured during the initialization (if the store could not be created) nil is returned and the error is logged.
 Callers of this method should check for nil return value and act accordingly.
 If configurations are provided, a store is created for each configuration, else only 1 store will be created for the default configuration
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return [self persistentStoreCoordinatorForStoreType:NSSQLiteStoreType];
}

- (BOOL)migrateModel:(BOOL)automatic withStoreCollectionDescriptor:(BMCoreDataStoreCollectionDescriptor *)oldStoreCollectionDescriptor {
    BOOL successful = YES;
    for (BMCoreDataStoreDescriptor *oldDescriptor in oldStoreCollectionDescriptor.storeDescriptors) {
        
        BMCoreDataStoreDescriptor *newDescriptor = [_storeCollectionDescriptor storeDescriptorByName:oldDescriptor.storeName];
        
        if (!newDescriptor) {
            //Remove store
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:oldDescriptor.storeURL error:&error]) {
                LogWarn(@"Could not remove old store: %@", error);
            }
        } else {
            //Migrate store
            successful = [self migrateStoreWithOldDescriptor:oldDescriptor toNewDescriptor:newDescriptor automatic:automatic] && successful;
        }
    }
    
    return successful;
}

@end

@implementation BMCoreDataStack (Private)

- (BMManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    BMManagedObjectContext *managedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[BMManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
        [managedObjectContext setMergePolicy:self.defaultMergePolicy];
        [managedObjectContext setUndoManager:nil];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForStoreType:(NSString *)theStoreType {
    @synchronized(self) {
        //For NSInMemoryStoreType always return a new persistentStoreCoordinator
        if (_persistentStoreCoordinator != nil && ![theStoreType isEqualToString:NSInMemoryStoreType]) {
            return _persistentStoreCoordinator;
        }
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        for (BMCoreDataStoreDescriptor *storeDescriptor in self.storeCollectionDescriptor.storeDescriptors) {
            if (![self addPersistentStoreWithConfiguration:storeDescriptor.modelConfiguration storeURL:storeDescriptor.storeURL storeType:theStoreType]) {
                break;
            }
        }
        
        return _persistentStoreCoordinator;
    }
}

- (BOOL)addPersistentStoreWithConfiguration:(NSString*)theConfiguration storeURL:(NSURL*)theUrl storeType:(NSString *)theStoreType{
    BOOL result = YES;
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:theStoreType configuration:theConfiguration URL:theUrl options:nil error:&error]) {
        _persistentStoreCoordinator = nil;
        result = NO;
        
#if 1
        NSString *message = [NSString stringWithFormat:@"Could not create persistent store for url %@ and configuration %@: %@", [theUrl absoluteString], theConfiguration, error];
        NSException *exception = [NSException exceptionWithName:@"BMPersistentStoreCreationException" reason:message userInfo:nil];
        
        @throw exception;
#else
        LogError(@"Could not create persistent store for url %@ and configuration %@: %@", [theUrl absoluteString], theConfiguration, error);
#endif
    }
    return result;
}

- (BOOL)migrateStoreWithOldDescriptor:(BMCoreDataStoreDescriptor *)oldDescriptor toNewDescriptor:(BMCoreDataStoreDescriptor *)newDescriptor automatic:(BOOL)automatic {
    NSError *error = nil;
    NSString *currentVersion = oldDescriptor.versionString;
    NSString *newVersion = newDescriptor.versionString;
    
    if (currentVersion != nil && ![currentVersion isEqual:newVersion]) {
        LogInfo(@"Migrating store %@", oldDescriptor.storeName);
        
        NSManagedObjectModel *srcModel = oldDescriptor.managedObjectModel;
        NSManagedObjectModel *dstModel = newDescriptor.managedObjectModel;
        
        NSURL *srcStoreURL = oldDescriptor.storeURL;
        NSURL *dstStoreURL = newDescriptor.storeURL;
        
        LogInfo(@"Source store URL=%@", srcStoreURL);
        LogInfo(@"Target store URL=%@", dstStoreURL);
        
        NSMappingModel *mappingModel = nil;
        if (automatic) {
            mappingModel = [NSMappingModel inferredMappingModelForSourceModel:srcModel
                                                             destinationModel:dstModel
                                                                        error:&error];
            if (!mappingModel) {
                LogError(@"Inferring failed: %@ [%@]",
                         [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info"));
            }
        } else {
            mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                    forSourceModel:srcModel
                                                  destinationModel:dstModel];
        }
        
        if (!mappingModel) {
            LogError(@"Could not migrate data: No mapping model");
            return NO;
        }
        
        NSValue *classValue = [NSPersistentStoreCoordinator registeredStoreTypes][NSSQLiteStoreType];
        Class sqliteStoreClass = (Class)[classValue pointerValue];
        Class sqliteStoreMigrationManagerClass = [sqliteStoreClass migrationManagerClass];
        
        NSMigrationManager *manager = [[sqliteStoreMigrationManagerClass alloc]
                                       initWithSourceModel:srcModel destinationModel:dstModel];
        
        if (![manager migrateStoreFromURL:srcStoreURL type:NSSQLiteStoreType
                                  options:nil withMappingModel:mappingModel toDestinationURL:dstStoreURL
                          destinationType:NSSQLiteStoreType destinationOptions:nil error:&error]) {
            LogError(@"Migration failed %@ [%@]",
                     [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info"));
            
            //Delete the new file, migration failed
            if (![[NSFileManager defaultManager] removeItemAtPath:[dstStoreURL path] error:&error]) {
                LogDebug(@"Could not delete the new database: %@", error);
            }
            
            return NO;
        }
        
        //Delete the old version database
        if (![[NSFileManager defaultManager] removeItemAtPath:[srcStoreURL path] error:&error]) {
            LogWarn(@"Could not delete the old database: %@", error);
        }
        
        LogInfo(@"Migration succeeded");
        
    } else {
        LogInfo(@"No need to migrate: No current version exists or version is already up to date");
    }
    
    return YES;
}

@end
