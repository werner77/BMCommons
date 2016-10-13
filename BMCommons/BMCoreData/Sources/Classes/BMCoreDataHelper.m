//
//  BMCoreDataHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMCoreDataHelper.h"
#import "BMStringHelper.h"
#import "BMRootManagedObject.h"
#import "BMEnumeratorWrapper.h"
#import <BMCommons/BMCore.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/BMErrorHelper.h>

#define FETCH_BATCH_SIZE 1000

typedef enum FaultChangeBehaviour {
    FaultChangeBehaviourIgnore,
    FaultChangeBehaviourReapply,
    FaultChangeBehaviourMerge
} FaultChangeBehaviour;

@interface BMCoreDataHelper(Private)

+ (void)faultObjectGraphForObject:(NSManagedObject *)managedObject handledObjects:(NSMutableArray *)handledObjects mergeChanges:(FaultChangeBehaviour)mergeChanges;
+ (NSUInteger)numEntitiesForEntityDescription:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)confirmObjectValidity:(NSManagedObject *)managedObject handledObjects:(NSMutableArray *)handledObjects excludeEntities:(NSArray *)excludeEntities;
+ (void)faultObjectImpl:(NSManagedObject *)managedObject mergeChanges:(FaultChangeBehaviour)mergeChanges;
+ (BOOL)copyObject:(NSManagedObject *)sourceObject toObject:(NSManagedObject *)destinationObject handledSourceObjects:(NSMutableArray *)handledSourceObjects
handledDestinationObjects:(NSMutableArray *)handledDestinationObjects;
+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2 recursive:(BOOL)recursive handledObjects:(NSMutableArray *)handledObjects;
+ (void)traverseObjectGraphForEntity:(NSManagedObject *)theEntity
                fromRelationship:(NSRelationshipDescription *)parentRelationship
                fromParentEntity:(NSManagedObject *)parentEntity
                  handledObjects:(NSMutableSet *)handledObjects
                       withBlock:(BOOL (^)(NSManagedObject *theEntity, NSManagedObject *parentEntity, NSRelationshipDescription *parentRelationship))block;
@end

@interface BMObjectPair : NSObject {
    id <NSObject> _object1;
    id <NSObject> _object2;
}

@property (nonatomic, strong) id<NSObject> object1;
@property (nonatomic, strong) id<NSObject> object2;

@end

@implementation BMObjectPair

@synthesize object1=_object1, object2=_object2;

- (NSUInteger)hash {
    return 17 * (self.object1.hash + 17 * self.object2.hash);
}

- (BOOL)isEqual:(id)other {
    BOOL ret = [other isKindOfClass:[self class]];
    if (ret) {
        BMObjectPair *otherPair = (BMObjectPair *)other;
        ret = ret && [self.object1 isEqual:otherPair.object1];
        ret = ret && [self.object2 isEqual:otherPair.object2];
    }
    return ret;
}


@end


@implementation BMCoreDataHelper

#pragma mark -
#pragma mark Fetching

/**
 Returns the object of specified id from the store, nil if not present
 */
+ (id)fetchObjectWithObjectURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)context {
    NSManagedObjectID *objectID = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    if (objectID) {
        return [context objectWithID:objectID];
    } else {
        return nil;
    }
}

+ (id)fetchObjectWithEntityName:(NSString *)name objectURI:(NSURL *)objectURI inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:name
                                   inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@",
                              [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURI]];
    [request setPredicate:predicate];
    
    id object = [BMCoreDataHelper executeFetchRequestForSingleEntity:request inContext:context];
    return object;
}

+ (NSFetchRequest *)fetchRequestFromTemplate:(NSString *)templateName
                   withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                 withSortKey:(NSString *)sortKey
                                   ascending:(BOOL)ascending
                               prefetchPaths:(NSArray *)prefetchPaths
                                   inContext:(NSManagedObjectContext *)context {
    NSManagedObjectModel *model = [self managedObjectModelFromContext:context];
    
    if (!substitutionVariables) {
        substitutionVariables = @{};
    }
    
    NSFetchRequest *request = [model fetchRequestFromTemplateWithName:templateName substitutionVariables:substitutionVariables];
    if (sortKey) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        NSArray *sortDescriptors = @[sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
    }
    
    if (prefetchPaths.count == 1 && [prefetchPaths lastObject] == [NSNull null]) {
        [request setReturnsObjectsAsFaults:NO];
    } else if (prefetchPaths) {
        [request setRelationshipKeyPathsForPrefetching:prefetchPaths];
    }
    return request;
}

+ (id)executeFetchRequestForSingleEntityFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                         withSortKey:(NSString *)sortKey ascending:(BOOL)ascending prefetchPaths:(NSArray *)prefetchPaths
                                           inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self fetchRequestFromTemplate:templateName
                                   withSubstitutionVariables:substitutionVariables
                                                 withSortKey:sortKey
                                                   ascending:ascending
                                               prefetchPaths:prefetchPaths
                                                   inContext:context];
    return [BMCoreDataHelper executeFetchRequestForSingleEntity:request inContext:context];
}

+ (id)executeFetchRequestForSingleEntityFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                           inContext:(NSManagedObjectContext *)context {
    NSManagedObjectModel *model = [BMCoreDataHelper managedObjectModelFromContext:context];
    NSFetchRequest *request = [model fetchRequestFromTemplateWithName:templateName substitutionVariables:substitutionVariables];
    return [BMCoreDataHelper executeFetchRequestForSingleEntity:request inContext:context];
}

+ (id)executeFetchRequestForSingleEntity:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
    NSError *error;
    request.fetchLimit = 1;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array != nil) {
        NSUInteger count = [array count]; // may be 0 if the object has been deleted
        if (count > 0) {
            if (count > 1) {
                LogWarn(@"Warning more than 1 entity found!");
            }
            return array[0];
        } else {
            return nil;
        }
    } else {
        LogError(@"Fetch request '%@' failed. \n error: %@", request, error);
        return nil;
    }
}

+ (NSUInteger)countForFetchRequest:(NSFetchRequest *)fr inContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fr error:&error];
    if (count == NSNotFound) {
        LogWarn(@"Could not execute fetch request: %@", error);
        count = 0;
    }
    return count;
}

+ (void)prefetchEntities:(NSArray *)entities withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    if (entities.count > 0) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF in %@", entities];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity];
        [fetch setPredicate:predicate];
        [fetch setReturnsObjectsAsFaults:NO];
        [self executeFetchRequest:fetch withSortKey:nil ascending:NO inContext:context];
    }
}

+ (void)prefetchRelationship:(NSString *)relationshipName forEntityName:(NSString *)entityName forObjects:(NSArray *)objects inContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    
    NSString *keypath = [BMStringHelper isEmpty:relationshipName] ? @"objectID" : [NSString stringWithFormat:@"%@.objectID", relationshipName];
    NSArray *OIDs = [objects valueForKeyPath:keypath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF in %@", OIDs];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    [fetch setPredicate:predicate];
    [fetch setReturnsObjectsAsFaults:NO];
    [self executeFetchRequest:fetch withSortKey:nil ascending:NO inContext:context];
}

+ (id)executeFetchRequestForSingleEntity:(NSFetchRequest *)request withSortKey:(NSString *)sortKey ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    return [BMCoreDataHelper executeFetchRequestForSingleEntity:request inContext:context];
}

+ (NSArray *)executeFetchRequestFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                 withSortKey:(NSString *)sortKey ascending:(BOOL)ascending prefetchPaths:(NSArray *)prefetchPaths
                                   inContext:(NSManagedObjectContext *)context {
    NSManagedObjectModel *model = [BMCoreDataHelper managedObjectModelFromContext:context];
    NSFetchRequest *request = [model fetchRequestFromTemplateWithName:templateName substitutionVariables:substitutionVariables];
    if (prefetchPaths.count == 1 && [prefetchPaths lastObject] == [NSNull null]) {
        [request setReturnsObjectsAsFaults:NO];
    } else if (prefetchPaths) {
        [request setRelationshipKeyPathsForPrefetching:prefetchPaths];
    }
    return [BMCoreDataHelper executeFetchRequest:request withSortKey:sortKey ascending:ascending inContext:context];
}

+ (NSArray *)executeFetchRequestFromTemplate:(NSString *)templateName withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                   inContext:(NSManagedObjectContext *)context {
    return [self executeFetchRequestFromTemplate:templateName withSubstitutionVariables:substitutionVariables withSortKey:nil ascending:NO prefetchPaths:nil inContext:context];
}

#if TARGET_OS_IPHONE
+ (NSFetchedResultsController *) fetchedResultsControllerFromTemplate:(NSString *)templateName
                                            withSubstitutionVariables:(NSDictionary *)substitutionVariables
                                                  withSortDescriptors:(NSArray *)sortDescriptors
                                               withSectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                        withCacheName:(NSString *)cacheName
                                                            inContext:(NSManagedObjectContext *)context {
    
    NSManagedObjectModel *model = [BMCoreDataHelper managedObjectModelFromContext:context];
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:templateName substitutionVariables:substitutionVariables];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Initiate the fetch request controller
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:sectionNameKeyPath
                                                                                     cacheName:cacheName];
    return frc;
}
#endif


+ (void)faultObject:(NSManagedObject *)managedObject keepChanges:(BOOL)keepChanges {
    FaultChangeBehaviour mergeBehaviour = keepChanges ? FaultChangeBehaviourReapply : FaultChangeBehaviourIgnore;
    [BMCoreDataHelper faultObjectImpl:managedObject mergeChanges:mergeBehaviour];
}

+ (void)faultObjectGraphForObject:(NSManagedObject *)managedObject keepChanges:(BOOL)keepChanges {
    NSMutableArray *handledObjects = [NSMutableArray arrayWithCapacity:64];
    FaultChangeBehaviour mergeBehaviour = keepChanges ? FaultChangeBehaviourReapply : FaultChangeBehaviourIgnore;
    [self faultObjectGraphForObject:managedObject handledObjects:handledObjects mergeChanges:mergeBehaviour];
}

+ (void)refreshObject:(NSManagedObject *)managedObject {
    [BMCoreDataHelper faultObjectImpl:managedObject mergeChanges:FaultChangeBehaviourMerge];
}

+ (void)refreshObjectGraphForObject:(NSManagedObject *)managedObject {
    NSMutableArray *handledObjects = [NSMutableArray arrayWithCapacity:64];
    [self faultObjectGraphForObject:managedObject handledObjects:handledObjects mergeChanges:FaultChangeBehaviourMerge];
}

+ (BOOL)confirmObjectValidity:(NSManagedObject *)managedObject excludeEntities:(NSArray *)excludeEntities {
    NSMutableArray *handledObjects = [NSMutableArray arrayWithCapacity:64];
    
    NSMutableArray *excludedEntityDescriptions = [NSMutableArray array];
    NSManagedObjectModel *objectModel = [[managedObject entity] managedObjectModel];
    NSDictionary *entities = [objectModel entitiesByName];
    
    for (NSString *entityName in excludeEntities) {
        NSEntityDescription *entityDescription = entities[entityName];
        if (entityDescription) {
            [excludedEntityDescriptions addObject:entityDescription];
        }
    }
    return [self confirmObjectValidity:managedObject handledObjects:handledObjects excludeEntities:excludedEntityDescriptions];
}

+ (BOOL)isObject:(id)object kindOfEntity:(NSString *)entityName {
    BOOL ret = NO;
    
    if (![object isKindOfClass:[NSManagedObject class]]) {
        return NO;
    }
    
    NSManagedObjectContext *context = [object managedObjectContext];
    if (context && entityName) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        ret = entity != nil && [[object entity] isKindOfEntity:entity];
    }
    return ret;
}

+ (BOOL)copyObject:(NSManagedObject *)sourceObject toObject:(NSManagedObject *)destinationObject {
    return [self copyObject:sourceObject toObject:destinationObject handledSourceObjects:[NSMutableArray array] handledDestinationObjects:[NSMutableArray array]];
}

+ (NSEnumerator *)enumerateObjectsInObjectContext:(NSManagedObjectContext *)context withRequestTemplateName:(NSString *)requestTemplateName
                        withSubstitutionVariables:(NSDictionary *)substitutionVariables withSortKey:(NSString *)sortKey ascending:(BOOL)ascending {
    return [BMCoreDataHelper enumerateObjectsInObjectContext:context
                                     withRequestTemplateName:requestTemplateName
                                   withSubstitutionVariables:substitutionVariables
                                                 withSortKey:sortKey
                                                   ascending:ascending
                                               prefetchPaths:nil];
}

+ (NSEnumerator *)enumerateObjectsInObjectContext:(NSManagedObjectContext *)context withRequestTemplateName:(NSString *)requestTemplateName
                        withSubstitutionVariables:(NSDictionary *)substitutionVariables withSortKey:(NSString *)sortKey ascending:(BOOL)ascending
                                    prefetchPaths:(NSArray *)prefetchPaths {
    
    NSArray *result = [BMCoreDataHelper executeFetchRequestFromTemplate:requestTemplateName withSubstitutionVariables:substitutionVariables withSortKey:sortKey
                                                              ascending:ascending prefetchPaths:prefetchPaths inContext:context];
    return [result objectEnumerator];
}

+ (NSArray *)allEntitiesOfName:(NSString *)name withSortKey:(NSString *)sortKey ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:name
                                   inManagedObjectContext:context];
    [request setEntity:entity];
    return [BMCoreDataHelper executeFetchRequest:request withSortKey:sortKey ascending:ascending inContext:context];
}

+ (NSManagedObjectModel *)managedObjectModelFromContext:(NSManagedObjectContext *)context {
    return [[context persistentStoreCoordinator] managedObjectModel];
}

+ (void)removeObject:(NSManagedObject *)object {
    [[object managedObjectContext] deleteObject:object];
}

/*
+ (void)removeAllObjectsFromContext:(NSManagedObjectContext *)context {
    NSSet* objects = [context registeredObjects];
    for (NSManagedObject *object in objects) {
        [context deleteObject:object];
    }
}
*/

+ (BOOL)saveContext:(NSManagedObjectContext *)context {
    return [BMCoreDataHelper saveContext:context withError:nil];
}

+ (BOOL)saveContext:(NSManagedObjectContext *)context withError:(NSError **)error {
    BOOL ret = YES;
    NSError* theError = nil;
    if (context && [context hasChanges]) {
        
        @try {
            if (![context save:&theError]) {
                ret = NO;
                
                LogError(@"Failed to save to data store: %@", [theError localizedDescription]);
                NSArray* detailedErrors = [theError userInfo][NSDetailedErrorsKey];
                BOOL repaired = NO;
                if(detailedErrors != nil && [detailedErrors count] > 0) {
                    repaired = YES;
                    for(NSError* detailedError in detailedErrors) {
                        LogError(@"  DetailedError: %@", [detailedError userInfo]);
                        NSManagedObject *failedObject = [detailedError userInfo][NSValidationObjectErrorKey];
                        if (failedObject && [failedObject conformsToProtocol:@protocol(BMRootManagedObject)]) {
                            id <BMRootManagedObject> o = (id <BMRootManagedObject>)failedObject;
                            [BMCoreDataHelper faultObjectGraphForObject:failedObject keepChanges:YES];
                            repaired = repaired && [o tryRepair];
                        }
                    }
                } else {
                    LogError(@"  %@", [theError userInfo]);
                    NSManagedObject *failedObject = [theError userInfo][NSValidationObjectErrorKey];
                    if (failedObject && [failedObject conformsToProtocol:@protocol(BMRootManagedObject)]) {
                        id <BMRootManagedObject> o = (id <BMRootManagedObject>)failedObject;
                        [BMCoreDataHelper faultObjectGraphForObject:failedObject keepChanges:YES];
                        repaired = [o tryRepair];
                    }
                }
                
                if (repaired) {
                    theError = nil;
                    //Try to save again after repair
                    LogInfo(@"Trying to save again after repair");
                    if (![context save:&theError]) {
                        LogInfo(@"Repair was not successful!");
                    } else {
                        LogInfo(@"Repair was successful!");
                        ret = YES;
                    }
                }
            }
        }
        @catch (NSException *exception) {
            ret = NO;
            NSString *message = [NSString stringWithFormat:@"Exception occured while trying to save context: %@", exception];
            theError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:BM_ERROR_UNKNOWN_ERROR description:message];
        }
    }

    if (error) {
        *error = theError;
    }
    return ret;
}

+ (void)performCoreDataBlock:(BMCoreDataBlock)block onContext:(NSManagedObjectContext *)context saveMode:(BMCoreDataSaveMode)saveMode completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion result:(id)result {
    
    if (context) {
        [context performBlock:^{
            
            id effectiveResult = result;
            if (block) {
                effectiveResult = block(context);
            }
            
            BOOL done = YES;
            BOOL shouldRecurse = NO;
            NSError *error = nil;
            
            if (saveMode != BMCoreDataSaveModeNone && [context hasChanges]) {
                if ([self saveContext:context withError:&error]) {
                    if (context.parentContext != nil && saveMode == BMCoreDataSaveModeRecursive) {
                        done = (completionContext == context);
                        shouldRecurse = YES;
                    }
                }
            }
            if (done) {
                if (completion) {
                    [self bmPerformBlockOnMainThread:^{
                        completion(effectiveResult, error);
                    }];
                }
            }
            if (shouldRecurse) {
                if (done) {
                    [self performCoreDataBlock:nil onContext:context.parentContext saveMode:saveMode completionContext:nil completion:nil result:effectiveResult];
                } else {
                    [self performCoreDataBlock:nil onContext:context.parentContext saveMode:saveMode completionContext:completionContext completion:completion result:effectiveResult];
                }
            }
        }];
    }
    
}

+ (void)performCoreDataBlock:(BMCoreDataBlock)block onContext:(NSManagedObjectContext *)context saveMode:(BMCoreDataSaveMode)saveMode completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion {
    [self performCoreDataBlock:block onContext:context saveMode:saveMode completionContext:completionContext completion:completion result:nil];
}

+ (void)saveContext:(NSManagedObjectContext *)context recursively:(BOOL)recursively completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion {
    [self performCoreDataBlock:nil onContext:context saveMode:(recursively ? BMCoreDataSaveModeRecursive : BMCoreDataSaveModeSingle) completionContext:completionContext completion:completion];
}

+ (BOOL)saveObject:(NSManagedObject *)object {
    return [BMCoreDataHelper saveObject:object withError:nil];
}

+ (BOOL)saveObject:(NSManagedObject *)object withError:(NSError **)error {
    return [BMCoreDataHelper saveContext:[object managedObjectContext] withError:error];
}

# pragma mark -
# pragma mark Testing

+ (void)removeAllEntitiesOfName:(NSString *)entityName fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:context];
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    NSArray *allInstances = [self executeFetchRequest:request withSortKey:nil ascending:YES inContext:context];
    for (NSManagedObject *object in allInstances) {
        [self removeObject:object];
    }
}

+ (NSUInteger)numEntitiesOfName:(NSString *)name inContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) {
        return -1;
    }
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:name inManagedObjectContext:managedObjectContext];
    
    return [BMCoreDataHelper numEntitiesForEntityDescription:entityDescription inContext:managedObjectContext];
}

+ (NSUInteger)numEntitiesWithPrinting:(BOOL)printing inContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) {
        return -1;
    }
    if (printing) {
        LogInfo(@"***Number of Entities***");
    }
    NSArray *entities = [[BMCoreDataHelper managedObjectModelFromContext:managedObjectContext] entities];
    int numberOfEntities = 0;
    for (int i = 0; i < entities.count; ++i) {
        NSEntityDescription *entity = entities[i];
        NSUInteger numOfEntity = [self numEntitiesForEntityDescription:entity inContext:managedObjectContext];
        if (printing) {
            LogInfo(@"%@: %d", entity.name, numOfEntity);
        }
        numberOfEntities += numOfEntity;
    }
    return numberOfEntities;
}

+ (NSUInteger)numEntitiesInContext:(NSManagedObjectContext *)managedObjectContext {
    return [BMCoreDataHelper numEntitiesWithPrinting:NO inContext:managedObjectContext];
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request withSortKey:(NSString *)sortKey ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
    request.fetchBatchSize = FETCH_BATCH_SIZE;
    if (sortKey) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        NSArray *sortDescriptors = @[sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
    }
    NSError *error = nil;
    NSArray *ret = [context executeFetchRequest:request error:&error];
    if (!ret) {
        LogError(@"Fetch request failed with error: %@", error);
    }
    return ret;
}

+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2 {
    
    if (object1 == nil || object2 == nil) {
        return NO;
    }
    if (![object1 isKindOfClass:[object2 class]] || ![object2 isKindOfClass:[object1 class]]) {
        return NO;
    }
    
    NSEntityDescription *entity = [object1 entity];
    NSDictionary *attributes = [entity attributesByName];
    NSArray *attributeNames = [attributes allKeys];
    for (NSString *attributeName in attributeNames) {
        id value1 = [object1 valueForKey:attributeName];
        id value2 = [object2 valueForKey:attributeName];
        
        if (value1 != value2 && ![value1 isEqual:value2]) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2 recursive:(BOOL)recursive {
    return [self isAttributesEqualForObject:object1 andObject:object2 recursive:recursive handledObjects:nil];
}

+ (void)traverseObjectGraphForEntity:(NSManagedObject *)theEntity
                  handledObjects:(NSMutableSet *)handledObjects
                       withBlock:(BOOL (^)(NSManagedObject *theEntity, NSManagedObject *parentEntity, NSRelationshipDescription *parentRelationship))block {
    
    [self traverseObjectGraphForEntity:theEntity
                  fromRelationship:nil
                  fromParentEntity:nil
                    handledObjects:handledObjects
                         withBlock:block];
    
}

@end

@implementation BMCoreDataHelper(Private)

+ (void)traverseObjectGraphForEntity:(NSManagedObject *)theEntity
                fromRelationship:(NSRelationshipDescription *)parentRelationship
                fromParentEntity:(NSManagedObject *)parentEntity
                  handledObjects:(NSMutableSet *)handledObjects
                       withBlock:(BOOL (^)(NSManagedObject *theEntity, NSManagedObject *parentEntity, NSRelationshipDescription *parentRelationship))block {
    if (theEntity) {
        if (!handledObjects) {
            handledObjects = [NSMutableSet set];
        }
        if (![handledObjects containsObject:theEntity]) {
            [handledObjects addObject:theEntity];
            
            if (block(theEntity, parentEntity, parentRelationship)) {
                NSEntityDescription *entity = [theEntity entity];
                NSDictionary *relationships = [entity relationshipsByName];
                NSArray *relationshipNames = [relationships allKeys];
                
                for (int i = 0; i < relationshipNames.count; ++i) {
                    NSString *relationshipName = relationshipNames[i];
                    
                    id relationshipTarget = [theEntity valueForKey:relationshipName];
                    NSRelationshipDescription *relationshipDescription = relationships[relationshipName];
                    
                    if ([relationshipDescription isToMany]) {
                        NSSet *set = relationshipTarget;
                        for (id e in set) {
                            [self traverseObjectGraphForEntity:e fromRelationship:relationshipDescription fromParentEntity:theEntity handledObjects:handledObjects withBlock:block];
                        }
                    } else {
                        [self traverseObjectGraphForEntity:relationshipTarget fromRelationship:relationshipDescription fromParentEntity:theEntity handledObjects:handledObjects withBlock:block];
                    }
                    
                }
            }
        }
    }
}

+ (BOOL)isAttributesEqualForObject:(NSManagedObject *)object1 andObject:(NSManagedObject *)object2 recursive:(BOOL)recursive handledObjects:(NSMutableArray *)handledObjects {
    
    if (handledObjects == nil) {
        handledObjects = [NSMutableArray array];
    }
    
    BMObjectPair *oc = [BMObjectPair new];
    oc.object1 = object1;
    oc.object2 = object2;
    
    if ([handledObjects containsObject:oc]) {
        return YES;
    }
    
    [handledObjects addObject:oc];
    
    BOOL equal = [self isAttributesEqualForObject:object1 andObject:object2];
    
    if (equal && recursive) {
        NSDictionary *relationShips = [[object1 entity] relationshipsByName];
        NSArray *relationShipNames = [relationShips allKeys];
        
        for (int i = 0; i < relationShipNames.count; ++i) {
            NSString *relationShipName = relationShipNames[i];
            NSRelationshipDescription *relationShipDescription = relationShips[relationShipName];
            
            id value1 = [object1 valueForKey:relationShipName];
            id value2 = [object2 valueForKey:relationShipName];
            
            if ([value1 isKindOfClass:[value2 class]] && [value2 isKindOfClass:[value1 class]]) {
                if ([relationShipDescription isToMany]) {
                    BOOL foundMatchesForAll = YES;
                    for (id v1 in value1) {
                        BOOL foundMatch = NO;
                        for (id v2 in value2) {
                            foundMatch = [self isAttributesEqualForObject:v1 andObject:v2 recursive:recursive handledObjects:handledObjects];
                            if (foundMatch) {
                                break;
                            }
                        }
                        if (!foundMatch) {
                            foundMatchesForAll = NO;
                        }
                        if (!foundMatchesForAll) {
                            break;
                        }
                    }
                    equal = foundMatchesForAll;
                } else {
                    equal = [self isAttributesEqualForObject:value1 andObject:value2 recursive:recursive handledObjects:handledObjects];
                }
            } else {
                equal = NO;
            }
            if (!equal) {
                break;
            }
        }
    }
    
    return equal;
}

+ (void)faultObjectImpl:(NSManagedObject *)managedObject mergeChanges:(FaultChangeBehaviour)mergeChanges {
    //Only fault if the object is not a fault yet and is not in a modified state or newly inserted (not saved yet)
    BOOL isFault = [managedObject isFault];
    BOOL isTemporary = [[managedObject objectID] isTemporaryID];
    BOOL isUpdated = [managedObject isUpdated];
    BOOL isDeleted = [managedObject isDeleted];
    
    NSDictionary *changedValues = [managedObject changedValues];
    
    if (isUpdated && (mergeChanges == FaultChangeBehaviourIgnore)) {
        LogWarn(@"Warning, faulting object of class: %@ with changed values: %@. The changes will be lost!",
                NSStringFromClass([managedObject class]), changedValues);
    }
    
    if (!isFault && !isTemporary && !isDeleted) {
        [[managedObject managedObjectContext] refreshObject:managedObject mergeChanges:(mergeChanges == FaultChangeBehaviourMerge)];
        if (mergeChanges == FaultChangeBehaviourReapply) {
            for (NSString *key in changedValues) {
                id value = changedValues[key];
                @try {
                    [managedObject setValue:value forKey:key];
                } @catch (id exception) {
                    LogError(@"Could not reapply changed value: %@ for key: %@ on managedObject of class: %@", value, key, NSStringFromClass([managedObject class]));
                }
                
            }
        }
    }
}

+ (void)faultObjectGraphForObject:(NSManagedObject *)managedObject handledObjects:(NSMutableArray *)handledObjects mergeChanges:(FaultChangeBehaviour)mergeChanges {
    
    if (managedObject != nil && ![managedObject isFault] && ![handledObjects containsObject:[managedObject objectID]]) {
        [handledObjects addObject:[managedObject objectID]];
        NSEntityDescription *entity = [managedObject entity];
        
        NSDictionary *relationShips = [entity relationshipsByName];
        NSArray *relationShipNames = [relationShips allKeys];
        
        for (int i = 0; i < relationShipNames.count; ++i) {
            NSString *relationShipName = relationShipNames[i];
            if (![managedObject hasFaultForRelationshipNamed:relationShipName]) {
                id relationShipTarget = [managedObject valueForKey:relationShipName];
                NSRelationshipDescription *relationShipDescription = relationShips[relationShipName];
                
                if ([relationShipDescription isToMany]) {
                    NSSet *set = [NSSet setWithSet:relationShipTarget];
                    for (NSManagedObject* object in set) {
                        [BMCoreDataHelper faultObjectGraphForObject:object handledObjects:handledObjects mergeChanges:mergeChanges];
                    }
                } else {
                    NSManagedObject *object = relationShipTarget;
                    [BMCoreDataHelper faultObjectGraphForObject:object handledObjects:handledObjects mergeChanges:mergeChanges];
                }
            }
        }
        
        if ([managedObject respondsToSelector:@selector(enumeratedObjects)]) {
            NSArray *enumeratedObjects = [managedObject performSelector:@selector(enumeratedObjects)];
            for (NSManagedObject *object in enumeratedObjects) {
                [BMCoreDataHelper faultObjectGraphForObject:object handledObjects:handledObjects mergeChanges:mergeChanges];
            }
        }
        
        [BMCoreDataHelper faultObjectImpl:managedObject mergeChanges:mergeChanges];
    }
}

//TODO: this method doesn't always work correctly: to be debugged
+ (BOOL)copyObject:(NSManagedObject *)sourceObject toObject:(NSManagedObject *)destinationObject
handledSourceObjects:(NSMutableArray *)handledSourceObjects
handledDestinationObjects:(NSMutableArray *)handledDestinationObjects {
    
    if (!destinationObject || !sourceObject) {
        return NO;
    }
    
    if (![destinationObject isMemberOfClass:[sourceObject class]]) {
        return NO;
    }
    
    if ([handledSourceObjects containsObject:sourceObject]) {
        return YES;
    }
    
    BOOL ret = YES;
    
    [handledSourceObjects addObject:sourceObject];
    [handledDestinationObjects addObject:destinationObject];
    NSEntityDescription *entity = [sourceObject entity];
    NSDictionary *relationShips = [entity relationshipsByName];
    NSArray *relationShipNames = [relationShips allKeys];
    
    for (NSString *relationShipName in relationShipNames) {
        id sourceRelationShipTarget = [sourceObject valueForKey:relationShipName];
        NSRelationshipDescription *relationShipDescription = relationShips[relationShipName];
        if ([relationShipDescription isToMany]) {
            NSMutableSet *destSet = [NSMutableSet new];
            NSSet *sourceSet = [NSSet setWithSet:sourceRelationShipTarget];
            for (NSManagedObject* nestedSourceObject in sourceSet) {
                NSUInteger index = [handledSourceObjects indexOfObject:nestedSourceObject];
                NSManagedObject *nestedDestObject = nil;
                if (index != NSNotFound) {
                    nestedDestObject = handledDestinationObjects[index];
                } else {
                    if ([nestedSourceObject conformsToProtocol:@protocol(BMRootManagedObject)]) {
                        nestedDestObject = [[nestedSourceObject class] insertObjectInContext:[destinationObject managedObjectContext] withReference:nestedSourceObject];
                    } else {
                        NSEntityDescription *nestedEntityDescription = [nestedSourceObject entity];
                        nestedDestObject = [NSEntityDescription insertNewObjectForEntityForName:nestedEntityDescription.name
                                                                         inManagedObjectContext:[destinationObject managedObjectContext]];
                    }
                }
                [destSet addObject:nestedDestObject];
                ret = [self copyObject:nestedSourceObject toObject:nestedDestObject handledSourceObjects:handledSourceObjects handledDestinationObjects:handledDestinationObjects] && ret;
            }
            
            [destinationObject setValue:destSet forKey:relationShipName];
        } else {
            NSManagedObject *nestedSourceObject = sourceRelationShipTarget;
            if (![handledSourceObjects containsObject:nestedSourceObject]) {
                NSManagedObject *nestedDestObject = nil;
                if (nestedSourceObject != nil) {
                    nestedDestObject = [destinationObject valueForKey:relationShipName];
                    if (nestedDestObject == nil) {
                        //Create a new object
                        if ([nestedSourceObject conformsToProtocol:@protocol(BMRootManagedObject)]) {
                            nestedDestObject = [[nestedSourceObject class] insertObjectInContext:[destinationObject managedObjectContext]
                                                                                   withReference:nestedSourceObject];
                        } else {
                            NSEntityDescription *nestedEntityDescription = [nestedSourceObject entity];
                            nestedDestObject = [NSEntityDescription insertNewObjectForEntityForName:nestedEntityDescription.name
                                                                             inManagedObjectContext:[destinationObject managedObjectContext]];
                        }
                    }
                    ret =  [self copyObject:nestedSourceObject toObject:nestedDestObject handledSourceObjects:handledSourceObjects handledDestinationObjects:handledDestinationObjects] && ret;
                }
                [destinationObject setValue:nestedDestObject forKey:relationShipName];
            }
        }
    }
    
    NSDictionary *attributes = [entity attributesByName];
    NSArray *attributeNames = [attributes allKeys];
    for (NSString *attributeName in attributeNames) {
        id sourceValue = [sourceObject valueForKey:attributeName];
        [destinationObject setValue:sourceValue forKey:attributeName];
    }
    return ret;
}


+ (NSUInteger)numEntitiesForEntityDescription:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error;
    NSUInteger count;
    
    
    [request setReturnsObjectsAsFaults:YES];
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    count = array.count;
    
    if (count == NSNotFound) {
        return 0;
    } else {
        return count;
    }
}

+ (BOOL)confirmObjectValidity:(NSManagedObject *)managedObject handledObjects:(NSMutableArray *)handledObjects excludeEntities:(NSArray *)excludeEntities {
    if (managedObject == nil) {
        return YES;
    }
    
    for (NSEntityDescription *excludedEntity in excludeEntities) {
        if ([[managedObject entity] isKindOfEntity:excludedEntity]) {
            //Do not check
            return YES;
        }
    }
    
    if (![handledObjects containsObject:[managedObject objectID]]) {
        [handledObjects addObject:[managedObject objectID]];
        
        NSEntityDescription *entityDescription = [managedObject entity];
        
        //Test whether all attributes are accessible
        NSDictionary *attributes = [entityDescription attributesByName];
        
        for (NSString *attributeName in attributes) {
            @try {
                [managedObject valueForKey:attributeName];
            } @catch (NSException * e) {
                LogError(@"Attribute getter resulted in exception: %@", e);
                return NO;
            }
        }
        
        NSDictionary *relationships = [entityDescription relationshipsByName];
        for (NSString *relationshipName in relationships) {
            NSRelationshipDescription *relationshipDescription = relationships[relationshipName];
            
            NSEntityDescription *destinationEntity = [relationshipDescription destinationEntity];
            
            for (NSEntityDescription *excludedEntity in excludeEntities) {
                if ([destinationEntity isKindOfEntity:excludedEntity]) {
                    //Do not check
                    continue;
                }
            }
            
            @try {
                id relationshipTarget = [managedObject valueForKey:relationshipName];
                if ([relationshipDescription isToMany]) {
                    NSSet *set = [NSSet setWithSet:relationshipTarget];
                    for (NSManagedObject* object in set) {
                        if (![BMCoreDataHelper confirmObjectValidity:object handledObjects:handledObjects excludeEntities:excludeEntities]) {
                            return NO;
                        }
                    }
                } else {
                    if (![BMCoreDataHelper confirmObjectValidity:relationshipTarget handledObjects:handledObjects excludeEntities:excludeEntities]) {
                        return NO;
                    }
                }
            } @catch (NSException * e) {
                LogError(@"Attribute getter resulted in exception: %@", e);
                
                @try {
                    if ([relationshipDescription isOptional]) {
                        //Optional so it is repairable by setting to nil
                        LogInfo(@"Repairing broken relationship '%@': %@", relationshipName, e);
                        [managedObject setValue:nil forKey:relationshipName];
                    } else {
                        LogError(@"Cannot repair required relationship '%@'", relationshipName);
                        return NO;
                    }
                } @catch (NSException * e) {
                    LogError(@"Could not repair broken relationship '%@': %@", relationshipName, e);
                    //Not repairable
                    return NO;
                }
            }
        }
    }
    return YES;
}


@end
