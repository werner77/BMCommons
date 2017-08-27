//
// Created by Werner Altewischer on 27/08/2017.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMAbstractMappableObject.h>
#import <CoreData/CoreData.h>

@interface BMAbstractMappableObject(BMCoreData)

/**
 Method for merging data objects with model objects: the primary keys of the model and data objects are compared.

 All Model objects
 for which no corresponding data object exists are removed. If no model object exists for a corresponding data object it is inserted
 in the context.
 The merge selector is called on each data object with argument the corresponding model object.
 */
+ (void)mergeDataObjects:(NSArray *)dataObjects
        withModelObjects:(NSArray *)modelObjects
                 ofClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector
               inContext:(NSManagedObjectContext *)context;

/**
 Merges the toManyRelationship of the specified model object.

 For all objects in the toManyRelationship the merge method above is called.
 */
+ (void)mergeDataObjects:(NSArray *)dataObjects
         withModelObject:(NSManagedObject *)modelObject
 usingToManyRelationship:(NSString *)relationShip
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector;


@end