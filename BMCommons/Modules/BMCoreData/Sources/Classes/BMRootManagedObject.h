/*
 *  BMRootManagedObject.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 13/08/09.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */

#import <CoreData/CoreData.h>

@protocol BMRootManagedObject<NSObject>

/**
 The name of this entity class
 */
+ (NSString *)entityName;

/**
 The property that returns the primary key for this class. Can be nil if no application key is required or applicable for this class.
 */
+ (NSString *)primaryKeyProperty;

/**
 The property that returns the secundary key for this class. This key acts as a unique identifier within a to-many contains relationship (defined as cascade delete).
 */
+ (NSString *)secundaryKeyProperty;

/**
 Returns the entity description for the specified context.
 */
+ (NSEntityDescription *)entityInContext:(NSManagedObjectContext *)context;

/**
 * Inserts a new object in the specified context and ensures that it is properly initialized (should give no validation errors on subsequent save)
 */
+ (id)insertObjectInContext:(NSManagedObjectContext *)context;

/**
 * Inserts an object using the specified object as reference. Implementations may not actually insert a new object but return an already existing
 * object as suitable for the reference.
 */
+ (id)insertObjectInContext:(NSManagedObjectContext *)context withReference:(NSManagedObject *)object;

/**
 * Releases the memory by faulting the object graph recursively
 */
- (void)releaseMemory;

/**
 * Removes/deletes the object from the context it is part of
 */
- (void)remove;

/**
 * Saves the object returning YES if successful, NO otherwise
 */
- (BOOL)save;

/**
 * Saves the context the object is part of. Returns true if succeful, false otherwise.
 */
- (BOOL)saveWithError:(NSError **)error;

/**
 * Checks whether the object is internally consistent (TRUE if valid, FALSE otherwise)
 */
- (BOOL)confirmObjectValidity;

/**
 * Call this if the object fails to save. Returns YES if the object was repaired, NO otherwise. If YES is returned a subsequent save may be tried, but it is not fully
 * guaranteed that it will indeed succeed.
 */
- (BOOL)tryRepair;

/**
 * Iff true, the object is mergeable.
 */
- (BOOL)isMergeable;

/**
 * Does a rollback of the underlying object context.
 */
- (void)rollback;

- (id)primaryKey;

@optional

/**
 optional method which returns all the objects that have been enumerated. Can be used to release memory for the underlying enumerated objects.
 */
- (NSArray *)enumeratedObjects;

@end
