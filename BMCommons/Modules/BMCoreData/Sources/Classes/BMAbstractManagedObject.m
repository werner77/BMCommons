//
//  BMAbstractManagedObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/10/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractManagedObject.h>
#import <BMCommons/BMCoreDataHelper.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMDateHelper.h>
#import "NSArray+BMCommons.h"
#import "NSString+BMCommons.h"
#import <BMCommons/BMCore.h>

#define MERGE_BATCH_SIZE NSUIntegerMax

@interface BMAbstractManagedObject(Private)

- (NSRelationshipDescription *)relationShipDescriptorForName:(NSString *)relationShipName;

+ (void)mergeModelObjects:(NSArray *)modelObjects
          withDataObjects:(NSArray *)dataObjects
  modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
   dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
           handledObjects:(NSMutableArray *)handledObjects
            mergeSelector:(SEL)mergeSelector
        parentModelObject:(id)parentModelObject
                 addBlock:(void (^)(id parentModelObject, id modelObject))addBlock
              removeBlock:(void (^)(id parentModelObject, id modelObject))removeBlock
             relationship:(NSRelationshipDescription *)relationshipDescription
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
                inContext:(NSManagedObjectContext *)context;

- (SEL)addSelectorForRelationship:(NSRelationshipDescription *)relationShipDescription;
- (SEL)removeSelectorForRelationship:(NSRelationshipDescription *)relationShipDescription;

@end

@implementation BMAbstractManagedObjectID : NSManagedObjectID

@end

@implementation BMAbstractManagedObject

/**
 * Inserts a new object in the specified context and ensures that it is properly initialized (should give no validation errors on subsequent save)
 */
+ (id)insertObjectInContext:(NSManagedObjectContext *)context {
	return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (id)insertObjectInContext:(NSManagedObjectContext *)context withReference:(NSManagedObject *)object {
    return [self insertObjectInContext:context];
}

+ (NSString *)entityName {
	return NSStringFromClass(self);
}

+ (NSString *)primaryKeyProperty {
    return nil;
}

+ (NSString *)secundaryKeyProperty {
    return nil;
}

- (NSArray *)relationshipsToMerge {
    return nil;
}

- (NSArray *)attributesToMerge {
    NSDictionary *attributes = [[self entity] attributesByName];
    return [attributes allKeys];
}

+ (NSEntityDescription *)entityInContext:(NSManagedObjectContext *)context {
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSArray *)allInstancesOrderedBy:(NSString *)sortField ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
	return [BMCoreDataHelper allEntitiesOfName:[self entityName]
                                   withSortKey:sortField
                                     ascending:ascending
                                     inContext:context];
}

+ (void)removeAllInstancesFromContext:(NSManagedObjectContext *)context {
    [BMCoreDataHelper removeAllEntitiesOfName:[self entityName] fromContext:context];
}

+ (NSUInteger)numberOfInstancesInContext:(NSManagedObjectContext *)context {
	return [BMCoreDataHelper numEntitiesOfName:[self entityName] inContext:context];
}

+ (id)fetchByPrimaryKey:(id)primaryKey inContext:(NSManagedObjectContext *)context {
    
    NSString *primaryKeyProperty = [self primaryKeyProperty];
    id result = nil;
    if (primaryKeyProperty && primaryKey) {
        NSFetchRequest *fr = [[NSFetchRequest alloc] init];
        [fr setIncludesPendingChanges:YES];
        [fr setEntity:[self entityInContext:context]];
        
        NSString *format = [NSString stringWithFormat:@"%@ == %%@", primaryKeyProperty];
        [fr setPredicate:[NSPredicate predicateWithFormat:format, primaryKey]];
        result = [BMCoreDataHelper executeFetchRequestForSingleEntity:fr inContext:context];
    }
    return result;
}

+ (id)fetchOrInsertByPrimaryKey:(id)primaryKey inContext:(NSManagedObjectContext *)context {

    if (!primaryKey || ![self primaryKeyProperty]) {
        return nil;
    }

    id object = [self fetchByPrimaryKey:primaryKey inContext:context];

    if (!object) {
        object = [self insertObjectInContext:context];
        [object setValue:primaryKey forKey:[self primaryKeyProperty]];
    }

    return object;
}

- (id)primaryKey {
    NSString *primaryKeyProperty = [[self class] primaryKeyProperty];
    id ret = nil;
    if (primaryKeyProperty) {
        ret = [self valueForKey:primaryKeyProperty];
    }
    return ret;
}

/**
 * Releases the memory by faulting the object graph recursively
 */
- (void)releaseMemory {
	//First do a save to avoid throwing away any unsaved changes:
	[self save];
	[BMCoreDataHelper faultObjectGraphForObject:self keepChanges:YES];
}

- (void)copyTo:(NSManagedObject *)otherObject {
	[BMCoreDataHelper copyObject:self toObject:otherObject];
}

- (NSDictionary *)dictionary {
    __block NSMutableDictionary *properties = nil;
    __block NSMutableDictionary *lookupDict = [NSMutableDictionary dictionary];
    
    NSDateFormatter *dateFormatter = [BMDateHelper rfc3339TimestampFractionalFormatter];
    
    [BMCoreDataHelper traverseObjectGraphForEntity:self
                                handledObjects:nil
                                     withBlock:^BOOL(NSManagedObject *entity, NSManagedObject *parentEntity, NSRelationshipDescription *parentRelationship) {
                                         if ([entity isKindOfClass:[BMAbstractManagedObject class]]) {
                                             BMAbstractManagedObject *mutableEntity = (BMAbstractManagedObject *)entity;
                                             if (parentEntity == nil || [(BMAbstractManagedObject *)parentEntity shouldMergeRelationship:[parentRelationship name] fromObject:nil]) {
                                                 NSEntityDescription *entityDescription = [entity entity];
                                                 NSDictionary *attributeDict = [entityDescription attributesByName];
                                                 NSMutableDictionary *objectDict = [NSMutableDictionary dictionary];
                                                 
                                                 lookupDict[[entity objectID]] = objectDict;
                                                 
                                                 NSMutableDictionary *parentDict = parentEntity ? lookupDict[[parentEntity objectID]] : nil;
                                                 if (!parentEntity) {
                                                     properties = objectDict;
                                                 }
                                                 
                                                 for (NSString *attributeName in attributeDict) {
                                                     if ([mutableEntity shouldMergeAttribute:attributeName fromObject:nil]) {
                                                         id attributeValue = [BMObjectHelper filterNullObject:[mutableEntity valueForKey:attributeName]];
                                                         
                                                         if ([attributeValue isKindOfClass:[NSDate class]]) {
                                                             attributeValue = [dateFormatter stringFromDate:attributeValue];
                                                         }
                                                         
                                                         objectDict[attributeName] = attributeValue;
                                                     }
                                                 }
                                                 
                                                 if ([parentRelationship isToMany]) {
                                                     NSMutableArray *array = parentDict[parentRelationship.name];
                                                     if (!array) {
                                                         array = [NSMutableArray array];
                                                         parentDict[parentRelationship.name] = array;
                                                     }
                                                     [array addObject:objectDict];
                                                 } else {
                                                     parentDict[parentRelationship.name] = objectDict;
                                                 }
                                                 return YES;
                                             }
                                         }
                                         return NO;
                                     }
     ];
    return properties;
}

+ (BMAbstractManagedObject *)importFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context handledObjects:(NSMutableSet *)handledObjects {
    
    if (!handledObjects) {
        handledObjects = [NSMutableSet set];
    }
    
    NSDateFormatter *dateFormatter = [BMDateHelper rfc3339TimestampFractionalFormatter];
    NSString *primaryKeyProperty = [self primaryKeyProperty];
    
    id primaryKey = dictionary[primaryKeyProperty];
    
    BMAbstractManagedObject *managedObject = nil;
    if (primaryKey) {
        managedObject = [self fetchOrInsertByPrimaryKey:primaryKey inContext:context];
    } else {
        managedObject = [self insertObjectInContext:context];
    }
    
    if (managedObject && ![handledObjects containsObject:managedObject]) {
        
        [handledObjects addObject:managedObject];
        
        NSDictionary *attributes = [[managedObject entity] attributesByName];
        
        for (id attributeName in attributes) {
            if ([managedObject shouldMergeAttribute:attributeName fromObject:nil]) {
                NSAttributeDescription *attributeDescription = attributes[attributeName];
                id attributeValue = dictionary[attributeName];
                
                if ([[attributeDescription attributeValueClassName] isEqualToString:@"NSDate"]) {
                    attributeValue = [dateFormatter dateFromString:attributeValue];
                }
                [managedObject setValue:attributeValue forKey:attributeName];
            }
        }
        
        NSDictionary *relationships = [[managedObject entity] relationshipsByName];
        
        for (id relationshipName in relationships) {
            if ([managedObject shouldMergeRelationship:relationshipName fromObject:nil]) {
                NSRelationshipDescription *relationshipDescription = relationships[relationshipName];
                Class subEntityClass = NSClassFromString([[relationshipDescription destinationEntity] managedObjectClassName]);
                if ([subEntityClass isSubclassOfClass:[BMAbstractManagedObject class]]) {
                    if ([relationshipDescription isToMany]) {
                        id subArray = dictionary[relationshipName];
                        if (![subArray isKindOfClass:[NSArray class]]) {
                            subArray = subArray ? @[subArray] : nil;
                        }
                        NSMutableSet *currentSubEntities = [managedObject valueForKey:relationshipName];
                        NSString *relationshipNameWithSupercase = [relationshipName bmStringWithUppercaseFirstChar];
                        NSString *addSelectorName = [NSString stringWithFormat:@"add%@Object:", relationshipNameWithSupercase];
                        NSString *removeSelectorName = [NSString stringWithFormat:@"remove%@Object:", relationshipNameWithSupercase];
                        for (id subDictionary in subArray) {
                            if ([subDictionary isKindOfClass:[NSDictionary class]]) {
                                id subEntity = [subEntityClass importFromDictionary:subDictionary inContext:context handledObjects:handledObjects];
                                if (subEntity) {
                                    if ([currentSubEntities containsObject:subEntity]) {
                                        [currentSubEntities removeObject:subEntity];
                                    } else {
                                        //Add the object
                                        BM_IGNORE_SELECTOR_LEAK_WARNING(
                                        [managedObject performSelector:NSSelectorFromString(addSelectorName) withObject:subEntity];
                                        )
                                    }
                                }
                            }
                        }
                        
                        for (id superfluousSubEntity in [NSSet setWithSet:currentSubEntities]) {
                            BM_IGNORE_SELECTOR_LEAK_WARNING(
                            [managedObject performSelector:NSSelectorFromString(removeSelectorName) withObject:superfluousSubEntity];
                            )
                            if (relationshipDescription.deleteRule == NSCascadeDeleteRule) {
                                [BMCoreDataHelper removeObject:superfluousSubEntity];
                            }
                        }
                        
                    } else {
                        BMAbstractManagedObject *subEntity = nil;
                        id subDictionary = dictionary[relationshipName];
                        if (subDictionary != nil) {
                            if ([subDictionary isKindOfClass:[NSArray class]]) {
                                subDictionary = [(NSArray *) subDictionary firstObject];
                            }
                            if ([subDictionary isKindOfClass:[NSDictionary class]]) {
                                subEntity = [subEntityClass importFromDictionary:subDictionary inContext:context handledObjects:handledObjects];
                            }
                            
                            id currentSubEntity = [managedObject valueForKey:relationshipName];
                            if (currentSubEntity != subEntity) {
                                if ([relationshipDescription deleteRule] == NSCascadeDeleteRule) {
                                    [managedObject setValue:nil forKey:relationshipName];
                                    [BMCoreDataHelper removeObject:currentSubEntity];
                                }
                                [managedObject setValue:subEntity forKey:relationshipName];
                            }
                        }
                    }
                } else {
                    LogWarn(@"Object for relationship with name %@ will be ignored because it is no sub class of BMAbstractManagedObject", relationshipName);
                }
            }
        }
    }
    return managedObject;
    
}

/**
 * Removes/deletes the object from the context it is part of
 */
- (void)remove {
	[BMCoreDataHelper removeObject:self];
}

- (BOOL)confirmObjectValidity {
	return [BMCoreDataHelper confirmObjectValidity:self excludeEntities:nil];
}

- (BOOL)tryRepair {
	//Default don't do any repairing
	return NO;
}

- (BOOL)isMergeable {
    return YES;
}

/**
 * Saves the object returning YES if successful, NO otherwise
 */
- (BOOL)save {
	NSError *error;
	BOOL success = [self saveWithError:&error];
	if(!success) {
		LogError(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				LogError(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			LogError(@"  %@", [error userInfo]);
		}
	}
	return success;
}

- (void)rollback {
    [self.managedObjectContext rollback];
}

- (BOOL)isKindOfEntityForClass:(Class)c {
    NSString *entityName = nil;
    if ([c isSubclassOfClass:[BMAbstractManagedObject class]]) {
        entityName = [c entityName];
    }
    return entityName != nil && [BMCoreDataHelper isObject:self kindOfEntity:entityName];
}

/**
 * Saves the context the object is part of. Returns true if succeful, false otherwise.
 */
- (BOOL)saveWithError:(NSError **)error {
	return [BMCoreDataHelper saveObject:self withError:error];
}

- (BOOL)shouldMergeAttribute:(NSString *)attributeName fromObject:(BMAbstractManagedObject *)other {
    return YES;
}

- (BOOL)shouldMergeRelationship:(NSString *)relationshipName fromObject:(BMAbstractManagedObject *)other {
    return YES;
}

- (void)mergeWith:(BMAbstractManagedObject *)other handledObjects:(NSMutableArray *)handledObjects {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    if (![handledObjects containsObject:self]) {
        [handledObjects addObject:self];
        
        //Copy attributes
        NSArray *attributeNames = [self attributesToMerge];
        for (NSString *attributeName in attributeNames) {
            if ([self shouldMergeAttribute:attributeName fromObject:other]) {
                id sourceValue = [other valueForKey:attributeName];
                id destValue = [self valueForKey:attributeName];
                
                if (sourceValue != destValue && ![sourceValue isEqual:destValue]) {
                    [self setValue:sourceValue forKey:attributeName];
                }
            }
        }
        
        //Merge all relationships
        NSArray *relationships = [self relationshipsToMerge];
        for (NSString *relationshipName in relationships) {
            if ([self shouldMergeRelationship:relationshipName fromObject:other]) {
                [self mergeRelationship:relationshipName withObject:other handledObjects:handledObjects];
            }
        }
        
        if ((handledObjects.count % MERGE_BATCH_SIZE) == 0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
    }
}

- (void)mergeRelationship:(NSString *)relationShip withObject:(BMAbstractManagedObject *)other handledObjects:(NSMutableArray *)handledObjects {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    NSRelationshipDescription *relationShipDescription = [self relationShipDescriptorForName:relationShip];
    NSEntityDescription *destinationEntity = [relationShipDescription destinationEntity];
    Class destinationClass = NSClassFromString(destinationEntity.managedObjectClassName);
    NSString *primaryKeyProperty = [destinationClass primaryKeyProperty];
    
    BOOL isContainsRelationship = relationShipDescription != nil && [relationShipDescription deleteRule] == NSCascadeDeleteRule;
    
    if (!primaryKeyProperty && isContainsRelationship) {
        primaryKeyProperty = [destinationClass secundaryKeyProperty];
    }
    
    id theDataObjects = [other valueForKey:relationShip];
    
    NSArray *dataObjects = nil;
    
    if ([relationShipDescription isToMany] && [theDataObjects isKindOfClass:[NSSet class]]) {
        dataObjects= [theDataObjects allObjects];
    } else if (theDataObjects) {
        dataObjects = @[theDataObjects];
    }
    [self mergeWithDataObjects:dataObjects
             usingRelationship:relationShip
       modelPrimaryKeyProperty:primaryKeyProperty
        dataPrimaryKeyProperty:primaryKeyProperty
                handledObjects:handledObjects
                 mergeSelector:@selector(mergeWith:handledObjects:)];
}

- (void)mergeWithDataObjects:(NSArray *)dataObjects
           usingRelationship:(NSString *)relationShip
     modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
      dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
              handledObjects:(NSMutableArray *)handledObjects
               mergeSelector:(SEL)mergeSelector {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    __block NSRelationshipDescription *relationShipDescription = [self relationShipDescriptorForName:relationShip];
    __block NSRelationshipDescription *inverseRelationShipDescription = [relationShipDescription inverseRelationship];
    if (relationShipDescription) {
        BOOL deleteNonExistent = [relationShipDescription deleteRule] == NSCascadeDeleteRule;
        Class modelClass = NSClassFromString([[relationShipDescription destinationEntity] managedObjectClassName]);
        
        __block SEL addSelector = [self addSelectorForRelationship:relationShipDescription];
        __block SEL removeSelector = [self removeSelectorForRelationship:relationShipDescription];
        __block SEL inverseAddSelector = [self addSelectorForRelationship:inverseRelationShipDescription];
        __block SEL inverseRemoveSelector = [self removeSelectorForRelationship:inverseRelationShipDescription];
        
        NSArray *modelObjects = nil;
        
        if ([relationShipDescription isToMany]) {
            //To many
            modelObjects = [[self valueForKey:relationShip] allObjects];
        } else {
            //To one
            id modelObject = [self valueForKey:relationShip];
            modelObjects = modelObject ? @[modelObject] : @[];
        }
        [modelClass mergeModelObjects:modelObjects
                      withDataObjects:dataObjects
              modelPrimaryKeyProperty:modelPrimaryKeyProperty
               dataPrimaryKeyProperty:dataPrimaryKeyProperty
                       handledObjects:handledObjects
                        mergeSelector:mergeSelector
                    parentModelObject:self
                             addBlock:^(id parentObject, id modelObject) {
                                 BM_IGNORE_SELECTOR_LEAK_WARNING(
                                 [parentObject performSelector:addSelector withObject:modelObject];
                                 [modelObject performSelector:inverseAddSelector withObject:parentObject];
                                 )
                             }
                          removeBlock:^(id parentObject, id modelObject) {
                              BM_IGNORE_SELECTOR_LEAK_WARNING(
                              [parentObject performSelector:removeSelector withObject:([relationShipDescription isToMany] ? modelObject : nil)];
                              [modelObject performSelector:inverseRemoveSelector withObject:([inverseRelationShipDescription isToMany] ? parentObject : nil)];
                              )
                          }
                         relationship:relationShipDescription
             removeNonExistentObjects:deleteNonExistent
                            inContext:context];
    } else {
        LogWarn(@"Relationship with name '%@' does not exist", relationShip);
    }
}


+ (void)mergeModelObjects:(NSArray *)modelObjects
          withDataObjects:(NSArray *)dataObjects
  modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
   dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
           handledObjects:(NSMutableArray *)handledObjects
            mergeSelector:(SEL)mergeSelector
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
                inContext:(NSManagedObjectContext *)context {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    [self mergeModelObjects:modelObjects
            withDataObjects:dataObjects
    modelPrimaryKeyProperty:modelPrimaryKeyProperty
     dataPrimaryKeyProperty:dataPrimaryKeyProperty
             handledObjects:handledObjects
              mergeSelector:mergeSelector
          parentModelObject:nil
                   addBlock:^(id parentModelObject, id modelObject){}
                removeBlock:^(id parentModelObject, id modelObject){}
               relationship:nil
   removeNonExistentObjects:removeNonExistentObjects
                  inContext:context];
}

+ (void)mergeModelObjects:(NSArray *)modelObjects withDataObjects:(NSArray *)dataObjects handledObjects:(NSMutableArray *)handledObjects removeNonExistentObjects:(BOOL)removeNonExistentObjects inContext:(NSManagedObjectContext *)context {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    NSString *primaryKeyProperty = [self primaryKeyProperty];
    [self mergeModelObjects:modelObjects
            withDataObjects:dataObjects
    modelPrimaryKeyProperty:primaryKeyProperty
     dataPrimaryKeyProperty:primaryKeyProperty
             handledObjects:handledObjects
              mergeSelector:@selector(mergeWith:handledObjects:)
   removeNonExistentObjects:removeNonExistentObjects
                  inContext:context];
}

@end

@implementation BMAbstractManagedObject(Private)
         
- (NSRelationshipDescription *)relationShipDescriptorForName:(NSString *)relationShipName {
    NSEntityDescription *entity = [self entity];
    NSDictionary *relationShips = [entity relationshipsByName];
    NSRelationshipDescription *relationShipDescription = relationShips[relationShipName];
    return relationShipDescription;
}

+ (void)mergeModelObjects:(NSArray *)modelObjects
          withDataObjects:(NSArray *)dataObjects
  modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
   dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
           handledObjects:(NSMutableArray *)handledObjects
            mergeSelector:(SEL)mergeSelector
        parentModelObject:(id)parentModelObject
                 addBlock:(void (^)(id parentModelObject, id modelObject))addBlock
              removeBlock:(void (^)(id parentModelObject, id modelObject))removeBlock
             relationship:(NSRelationshipDescription *)relationshipDescription
 removeNonExistentObjects:(BOOL)removeNonExistentObjects
                inContext:(NSManagedObjectContext *)context {
    
	BMPropertyDescriptor *pdData = dataPrimaryKeyProperty ? [BMPropertyDescriptor propertyDescriptorFromKeyPath:dataPrimaryKeyProperty
                                                                                                     withTarget:nil] : nil;
    
	BMPropertyDescriptor *pdModel = modelPrimaryKeyProperty ? [BMPropertyDescriptor propertyDescriptorFromKeyPath:modelPrimaryKeyProperty
                                                                                                       withTarget:nil] : nil;
    
	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:dataObjects.count];
    
    BOOL isContainsRelationship = relationshipDescription != nil && [relationshipDescription deleteRule] == NSCascadeDeleteRule;
    BOOL isOneToOneContainsRelationship = isContainsRelationship && ![relationshipDescription isToMany];
    
	for (id data in dataObjects) {
		id key = [pdData callGetterOnTarget:data];
        
		if (key == nil) {
			//Create a random key
			key = [BMStringHelper stringWithUUID];
		} else if (dataDictionary[key] != nil) {
			LogWarn(@"Found duplicate key!");
		}
		dataDictionary[key] = data;
	}
    
	NSMutableArray *objectsToRemove = [NSMutableArray array];
    
	for (id modelObject in modelObjects) {
        
		id key = [pdModel callGetterOnTarget:modelObject];
		id correspondingData = key ? dataDictionary[key] : nil;
        
        if (![modelObject isMergeable]) {
            //Leave the object: it is locked we cannot merge
            [dataDictionary removeObjectForKey:key];
        } else if (correspondingData) {
			//Existing object which should remain
			if (mergeSelector) {
                BM_IGNORE_SELECTOR_LEAK_WARNING(
				[modelObject performSelector:mergeSelector withObject:correspondingData withObject:handledObjects];
                )
			}
			[dataDictionary removeObjectForKey:key];
		} else {
            BOOL shouldRemove = YES;
            if (isOneToOneContainsRelationship) {
                shouldRemove = (dataDictionary.count == 0);
            }
            if (shouldRemove) {
                //Object should be removed
                [objectsToRemove addObject:modelObject];
            }
		}
	}
    
    NSMutableArray *objectsToAdd = [NSMutableArray arrayWithArray:[dataDictionary allValues]];
    
	//Objects to remove
    for (id modelObject in objectsToRemove) {
        if (parentModelObject && removeBlock) {
            removeBlock(parentModelObject, modelObject);
        }
        if (removeNonExistentObjects) {
            [modelObject remove];
        }
    }
    
	//Objects to add
	for (id dataObject in objectsToAdd) {
        Class modelClass = self;
        if ([dataObject isKindOfClass:modelClass]) {
            modelClass = [dataObject class];
        }
        
        BOOL callAddBlock = YES;
        id primaryKey = pdData ? [pdData callGetterOnTarget:dataObject] : nil;
        id newObject = nil;
        if (primaryKey) {
            if (isContainsRelationship) {
                //Primary key is actually a secundary key
                id target = [parentModelObject valueForKey:relationshipDescription.name];
                if ([relationshipDescription isToMany]) {
                    for (id targetObj in target) {
                        id modelKey = [pdModel callGetterOnTarget:targetObj];
                        if ([modelKey isEqual:primaryKey]) {
                            newObject = targetObj;
                            break;
                        }
                    }
                } else {
                    id modelKey = [pdModel callGetterOnTarget:target];
                    if ([modelKey isEqual:primaryKey]) {
                        newObject = target;
                    }
                }
            }
            if (!newObject && [modelPrimaryKeyProperty isEqual:[modelClass primaryKeyProperty]]) {
                //Try to fetch the object by primary key
                newObject = [modelClass fetchByPrimaryKey:primaryKey inContext:context];
            }
        } else {
            //No primary key
            if (isOneToOneContainsRelationship) {
                //One to one contains relationship: we can just overwrite the object
                newObject = [parentModelObject valueForKey:relationshipDescription.name];
                if (newObject) {
                    //We don't have to add the object, it's already there
                    callAddBlock = NO;
                }
            }
        }
        if (!newObject) {
           newObject = [modelClass insertObjectInContext:context];
        }
		if (parentModelObject && addBlock && callAddBlock) {
            addBlock(parentModelObject, newObject);
		}
		if (mergeSelector) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
			[newObject performSelector:mergeSelector withObject:dataObject withObject:handledObjects];
            )
		}
	}
}

- (SEL)addSelectorForRelationship:(NSRelationshipDescription *)relationShipDescription {
    if (relationShipDescription == nil) {
        return nil;
    }
    
    NSString *relationShip = [relationShipDescription name];
    NSString *firstChar = relationShip.length > 0 ? [[relationShip substringToIndex:1] uppercaseString] : @"";
    NSString *rest = relationShip.length > 1 ? [relationShip substringFromIndex:1] : @"";
    NSString *capitalizedRelationshipName = [firstChar stringByAppendingString:rest];
    
    if ([relationShipDescription isToMany]) {
        return NSSelectorFromString([NSString stringWithFormat:@"add%@Object:", capitalizedRelationshipName]);
    } else {
        return NSSelectorFromString([NSString stringWithFormat:@"set%@:", capitalizedRelationshipName]);
    }
}

- (SEL)removeSelectorForRelationship:(NSRelationshipDescription *)relationShipDescription {
    if (relationShipDescription == nil) {
        return nil;
    }
    
    NSString *relationShip = [relationShipDescription name];
    NSString *firstChar = relationShip.length > 0 ? [[relationShip substringToIndex:1] uppercaseString] : @"";
    NSString *rest = relationShip.length > 1 ? [relationShip substringFromIndex:1] : @"";
    NSString *capitalizedRelationshipName = [firstChar stringByAppendingString:rest];
    
    if ([relationShipDescription isToMany]) {
        return NSSelectorFromString([NSString stringWithFormat:@"remove%@Object:", capitalizedRelationshipName]);
    } else {
        return NSSelectorFromString([NSString stringWithFormat:@"set%@:", capitalizedRelationshipName]);
    }
}

@end
