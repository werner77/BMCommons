//
//  BMAbstractManagedObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/10/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <BMCommons/BMRootManagedObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAbstractManagedObjectID : NSManagedObjectID

@end

@interface BMAbstractManagedObject : NSManagedObject<BMRootManagedObject>

+ (NSArray *)allInstancesOrderedBy:(nullable NSString *)sortField ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)numberOfInstancesInContext:(NSManagedObjectContext *)context;
+ (void)removeAllInstancesFromContext:(NSManagedObjectContext *)context;


/**
 Merges the supplied array of model objects with the supplied array of data objects in the following manner:
 - For each object the primary key property is read for both the data and model object
 - For matching primarykey values the mergeSelector is called on the model object with as argument the data object
 - For primary keys that exist in the dataObjects array but not in the modelObjects array a new model entity is inserted of the class on which this method is called in the supplied object context. Subsequently the mergeSelector is called on this new model object with as argument the data object
 - For primary keys that exist in the modelObjects array but not in the dataObjects array, the remove method is called on the model object (removing it from the context) if the removeNonExistentObjects is set to YES.
 */
+ (void)mergeModelObjects:(NSArray *)modelObjects
          withDataObjects:(NSArray *)dataObjects
  modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
   dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
           handledObjects:(nullable NSMutableArray *)handledObjects
            mergeSelector:(SEL)mergeSelector
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
                inContext:(NSManagedObjectContext *)context;


/**
 Merges the model objects with the data objects in the manner specified above with modelPrimaryKeyProperty=dataPrimaryKeyProperty=[self primaryKeyProperty] and mergeSelector=@selector(mergeWith:).
 This method assumes that the dataObjects are of the same class as the model objects.
 */
+ (void)mergeModelObjects:(NSArray *)modelObjects
          withDataObjects:(NSArray *)dataObjects
           handledObjects:(nullable NSMutableArray *)handledObjects
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
                inContext:(NSManagedObjectContext *)context;


+ (id)fetchByPrimaryKey:(id)primaryKey inContext:(NSManagedObjectContext *)context;
+ (id)fetchOrInsertByPrimaryKey:(id)primaryKey inContext:(NSManagedObjectContext *)context;

//TODO: Implementation contains bugs in some cases
- (void)copyTo:(NSManagedObject *)otherObject;

/**
 Merges this object with the supplied object in the following manner (assumes other is the same class as this object):
 - Copies all similar attributes from other to self
 - For relationships the method mergeRelationShip:withObject:handledObjects: is called.
 */
- (void)mergeWith:(BMAbstractManagedObject *)other handledObjects:(nullable NSMutableArray *)handledObjects;

- (nullable NSArray *)relationshipsToMerge;
- (nullable NSArray *)attributesToMerge;

- (BOOL)shouldMergeAttribute:(NSString *)attributeName fromObject:(BMAbstractManagedObject *)other;
- (BOOL)shouldMergeRelationship:(NSString *)relationshipName fromObject:(BMAbstractManagedObject *)other;

/**
 Merges the specified relationship. Calls 
 
 mergeWithDataObjects:(NSArray *)dataObjects
 usingRelationship:(NSString *)relationShip
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
 dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 mergeSelector:(SEL)mergeSelector;
 
 with 
 
 dataObjects=the result of calling the relationship getter on other
 modelPrimaryKeyProperty=dataPrimaryKeyProperty=primary key property of the destination class for the relation ship (result of + (NSString)primaryKeyProperty)
 mergeSelector=@selector(mergeWith:)
 
 */
- (void)mergeRelationship:(NSString *)relationShip withObject:(BMAbstractManagedObject *)other handledObjects:(nullable NSMutableArray *)handledObjects;

/**
 Calls the class method:
 
 + (void)mergeModelObjects:(NSArray *)modelObjects
 withDataObjects:(NSArray *)dataObjects
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
 dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 mergeSelector:(SEL)mergeSelector
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
 inContext:(NSManagedObjectContext *)context;
 
 For the modelObjects parameter the relationship on this object is used which returns a NSSet of objects in case of a to-many relationship and a single object in case of a to-one relationship. 
 This set or object is converted to a NSArray and handed to the method above. The class on which the method is called is the destination class of this relationship.
 removeNonExistent is implied by the cascade delete rule of the relationship (cascading implies removeNonExistent).
 */
- (void)mergeWithDataObjects:(NSArray *)dataObjects
           usingRelationship:(NSString *)relationShip
     modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
      dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
              handledObjects:(nullable NSMutableArray *)handledObjects
               mergeSelector:(SEL)mergeSelector;

/**
 Use this method instead of isKindOfClass to test for inheritance.
 */
- (BOOL)isKindOfEntityForClass:(Class)c;

/**
 Returns the contents of this object as a dictionary by recursing through the relationshipsToMerge and attributesToMerge.
 
 Dates are formatted as string using the date formatter returned by [BMDateHelper rfc3339TimestampFractionalFormatter].
 */
- (NSDictionary *)dictionary;

/**
 Imports objects from the specified dictionary in the specified context.
 */
+ (BMAbstractManagedObject *)importFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context handledObjects:(nullable NSMutableSet *)handledObjects;

@end

NS_ASSUME_NONNULL_END
