//
//  NSManagedObjectContext+BMCoreData.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/09/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSManagedObjectContext+BMCommons.h"
#import <objc/runtime.h>
#import <BMCore/BMCore.h>

@implementation NSManagedObjectContext (BMCommons)

static char * const kCacheKey = "com.behindmedia.BMCommons.NSManagedObjectContext.cache";

- (NSMutableDictionary *)cache {
    NSMutableDictionary *cache = objc_getAssociatedObject(self, kCacheKey);
    if (cache == nil) {
        cache = [NSMutableDictionary new];
        objc_setAssociatedObject(self, kCacheKey, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (void)bmSaveRecursively:(BOOL)recursively completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion {
    [BMCoreDataHelper saveContext:self recursively:recursively completionContext:completionContext completion:completion];
}

- (void)bmPerformCoreDataBlock:(BMCoreDataBlock)block saveMode:(BMCoreDataSaveMode)saveMode completionContext:(NSManagedObjectContext *)completionContext completion:(BMCoreDataSaveCompletionBlock)completion {
    [BMCoreDataHelper performCoreDataBlock:block onContext:self saveMode:saveMode completionContext:completionContext completion:completion];
}

- (NSArray *)bmObjectsWithIDs:(NSArray *)objectIDs checkExistence:(BOOL)existing {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:objectIDs.count];
    for (NSManagedObjectID *objectID in objectIDs) {
        
        NSManagedObject *existingObject = nil;
        if (objectID) {
            if (existing) {
                NSError *error = nil;
                existingObject = [self existingObjectWithID:objectID error:&error];
                if (!existingObject) {
                    LogDebug(@"Could not get object: %@", error);
                }
            } else {
                existingObject = [self objectWithID:objectID];
            }
        }
        
        if (existingObject) {
            [ret addObject:existingObject];
        }
    }
    return ret;
}

- (NSArray *)bmObjectsFromObjects:(NSArray *)objects checkExistence:(BOOL)existing {
    
    if (existing) {
        NSError *error = nil;
        if (![self obtainPermanentIDsForObjects:objects error:&error]) {
            LogDebug(@"Could not obtain permanent IDs for objects: %@", error);
        }
    }
    
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
    for (NSManagedObject *object in objects) {
        NSManagedObjectID *objectID = object.objectID;
        if (objectID) {
            [objectIDs addObject:objectID];
        }
    }
    return [self bmObjectsWithIDs:objectIDs checkExistence:existing];
}

- (void)bmSetCachedObject:(id)object forKey:(id<NSCopying>)key {
    if (key) {
        if (object) {
            [self.cache setObject:object forKey:key];
        } else {
            [self.cache removeObjectForKey:key];
        }
    }
}

- (id)bmCachedObjectForKey:(id <NSCopying>)key {
    return [self.cache objectForKey:key];
}

- (void)bmClearCache {
    [self.cache removeAllObjects];
}

@end
