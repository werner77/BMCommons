//
// Created by Werner Altewischer on 27/08/2017.
//

#import "BMAbstractMappableObject+BMCoreData.h"
#import "BMLogging.h"
#import "BMPropertyDescriptor.h"
#import "BMStringHelper.h"
#import "BMVersionAvailability.h"

@implementation BMAbstractMappableObject (BMCoreData)

+ (void)mergeDataObjects:(NSArray *)dataObjects
        withModelObjects:(NSArray *)modelObjects
              modelClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector
       parentModelObject:(id)parentModelObject
             addSelector:(SEL)addSelector
               inContext:(NSManagedObjectContext *)context {

    BMPropertyDescriptor *pdData = [BMPropertyDescriptor propertyDescriptorFromKeyPath:dataPrimaryKeyProperty
                                                                            withTarget:nil];

    BMPropertyDescriptor *pdModel = [BMPropertyDescriptor propertyDescriptorFromKeyPath:modelPrimaryKeyProperty
                                                                             withTarget:nil];

    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:dataObjects.count];

    for (id data in dataObjects) {
        id key = [pdData callGetterOnTarget:data];

        if (key == nil) {
            //Create a random key
            key = [BMStringHelper stringWithUUID];
        } else if ([dataDictionary objectForKey:key] != nil) {
            LogError(@"Found duplicate key!");
        }

        [dataDictionary setObject:data forKey:key];
    }

    NSMutableArray *objectsToRemove = [NSMutableArray array];

    for (id modelObject in modelObjects) {

        id key = [pdModel callGetterOnTarget:modelObject];
        id correspondingData = key ? [dataDictionary objectForKey:key] : nil;

        if (correspondingData) {
            //Existing object which should remain
            if (mergeSelector) {
                BM_IGNORE_SELECTOR_LEAK_WARNING(
                        [correspondingData performSelector:mergeSelector withObject:modelObject];
                )
            }
            [dataDictionary removeObjectForKey:key];
        } else {
            //Object should be removed
            [objectsToRemove addObject:modelObject];
        }
    }

    //Objects to remove
    for (id modelObject in objectsToRemove) {
        [[modelObject managedObjectContext] deleteObject:modelObject];
    }

    //Objects to add
    for (id dataObject in [dataDictionary allValues]) {
        NSString *entityName = nil;

        Protocol *protocol = NSProtocolFromString(@"BMRootManagedObject");

        if (protocol && [modelClass conformsToProtocol:protocol] && [modelClass respondsToSelector:@selector(entityName)]) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    entityName = [modelClass performSelector:@selector(entityName)];
            )
        }

        if (!entityName) {
            entityName = NSStringFromClass(modelClass);
        }

        id newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];

        if (parentModelObject && addSelector) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [parentModelObject performSelector:addSelector withObject:newObject];
            )
        }
        if (mergeSelector) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [dataObject performSelector:mergeSelector withObject:newObject];
            )
        }
    }
}

+ (void)mergeDataObjects:(NSArray *)dataObjects
        withModelObjects:(NSArray *)modelObjects
                 ofClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector
               inContext:(NSManagedObjectContext *)context {

    [self mergeDataObjects:dataObjects
          withModelObjects:modelObjects
                modelClass:modelClass
    dataPrimaryKeyProperty:dataPrimaryKeyProperty
   modelPrimaryKeyProperty:modelPrimaryKeyProperty
             mergeSelector:mergeSelector
         parentModelObject:nil
               addSelector:nil
                 inContext:context];

}

+ (void)mergeDataObjects:(NSArray *)dataObjects
         withModelObject:(NSManagedObject *)modelObject
 usingToManyRelationship:(NSString *)relationShip
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector {

    NSManagedObjectContext *context = [modelObject managedObjectContext];
    NSEntityDescription *entity = [modelObject entity];
    NSDictionary *relationShips = [entity relationshipsByName];
    NSRelationshipDescription *relationShipDescription = [relationShips objectForKey:relationShip];

    if (relationShipDescription && [relationShipDescription isToMany]) {

        NSSet *modelObjects = [modelObject valueForKey:relationShip];
        NSString *firstChar = relationShip.length > 0 ? [[relationShip substringToIndex:1] uppercaseString] : @"";
        NSString *rest = relationShip.length > 1 ? [relationShip substringFromIndex:1] : @"";
        NSString *capitalizedRelationshipName = [firstChar stringByAppendingString:rest];

        SEL addSelector = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:", capitalizedRelationshipName]);
        Class modelClass = NSClassFromString([[relationShipDescription destinationEntity] managedObjectClassName]);

        [[self class] mergeDataObjects:dataObjects
                      withModelObjects:[modelObjects allObjects]
                            modelClass:modelClass
                dataPrimaryKeyProperty:dataPrimaryKeyProperty
               modelPrimaryKeyProperty:modelPrimaryKeyProperty
                         mergeSelector:mergeSelector
                     parentModelObject:modelObject
                           addSelector:addSelector
                             inContext:context];
    } else {
        LogWarn(@"Relationship with name '%@' does not exist or is not to-many", relationShip);
    }
}

@end