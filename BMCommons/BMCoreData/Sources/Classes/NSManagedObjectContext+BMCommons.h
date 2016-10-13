//
//  NSManagedObjectContext+BMCoreData.h
//  BMCommons
//
//  Created by Werner Altewischer on 02/09/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <BMCoreData/BMCoreDataHelper.h>

@interface NSManagedObjectContext (BMCommons)

/**
 Saves this object context using it's own queue with performBlock: and optionally recurses into it's parent contexts also saving those.
 
 The completion block is performed on the main thread when done. If there was an error it is available as a parameter to the completion block.
 */
- (void)bmSaveRecursively:(BOOL)recursively completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion;

/**
 Performs the specified core data block using performBlock: on this managedObjectContext.
 
 If the save mode is single the specified context is saved afterwards.
 If the save mode is recursive the specified context and all parent contexts are saved afterwards.
 
 The completion block is called after all saves have completed or if an error occured during saving. The error is specified as argument to the completion block.
 */
- (void)bmPerformCoreDataBlock:(BMCoreDataBlock)block saveMode:(BMCoreDataSaveMode)saveMode completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion;

/**
 Returns array of NSManagedObjects that correspond to the specified NSManagedObjectIDs.
 
 If existing == YES the object is checked for existence.
 */
- (NSArray *)bmObjectsWithIDs:(NSArray *)objectIDs checkExistence:(BOOL)existing;

/**
 Returns array of NSManagedObjects that correspond to the specified NSManagedObjects from another contex.
 
 If existing == YES the object is checked for existence.
 */
- (NSArray *)bmObjectsFromObjects:(NSArray *)objects checkExistence:(BOOL)existing;

/**
 Returns the associated cached object for this context.
 */
- (id)bmCachedObjectForKey:(id <NSCopying>)key;

/**
 Attaches a cached object to this context.
 */
- (void)bmSetCachedObject:(id)object forKey:(id <NSCopying>)key;

/**
 Removes all cached objects.
 */
- (void)bmClearCache;

@end
