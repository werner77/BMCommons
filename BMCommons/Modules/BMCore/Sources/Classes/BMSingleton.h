//
//  BMSingleton.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BM_SYNTHESIZE_SINGLETON_IMPL(getter, singletonKey) \
+ (NSMutableDictionary *)bmSharedInstanceDictionary { \
static NSMutableDictionary *instances = nil; \
static dispatch_once_t token; \
dispatch_once(&token, ^{ \
instances = [NSMutableDictionary new]; \
}); \
return instances; \
} \
+ (void)bmDidReceiveReleaseSharedInstanceNotification:(NSNotification *)notification { \
    [self releaseSharedInstance]; \
} \
+ (instancetype)getter { \
return [self getter:YES]; \
} \
+ (instancetype)getter:(BOOL)createIfNotExists { \
id instance = nil; \
NSMutableDictionary *instances = [self bmSharedInstanceDictionary]; \
@synchronized(instances) { \
id key = (id <NSCopying>)(singletonKey); \
instance = instances[key]; \
if (instance == nil && createIfNotExists && [BMSingleton isSharedInstanceCreationAllowed]) { \
id allocatedInstance = [self alloc]; \
if (allocatedInstance != nil) { \
instances[key] = allocatedInstance; \
} \
instance = [allocatedInstance init]; \
if (allocatedInstance != instance) { \
if (instance == nil) { \
[instances removeObjectForKey:key]; \
} else { \
instances[key] = instance; \
} \
} \
if (instance != nil) { \
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bmDidReceiveReleaseSharedInstanceNotification:) name:BMReleaseSharedInstancesNotification object:nil]; \
} \
} \
} \
return instance; \
} \
+ (void)releaseSharedInstance { \
NSMutableDictionary *instances = [self bmSharedInstanceDictionary]; \
@synchronized (instances) { \
id key = (id <NSCopying>)(singletonKey); \
if ([instances objectForKey:key] != nil) { \
[instances removeObjectForKey:key]; \
[[NSNotificationCenter defaultCenter] removeObserver:self name:BMReleaseSharedInstancesNotification object:nil]; \
} \
} \
}

#define BM_DECLARE_SINGLETON(getter) \
+ (instancetype)getter; \
+ (instancetype)getter:(BOOL)createIfNotExists; \
+ (void)releaseSharedInstance;

#define BM_DECLARE_DEFAULT_SINGLETON BM_DECLARE_SINGLETON(sharedInstance)
#define BM_SYNTHESIZE_ABSTRACT_SINGLETON(getter) BM_SYNTHESIZE_SINGLETON_IMPL(getter, self)
#define BM_SYNTHESIZE_DEFAULT_ABSTRACT_SINGLETON BM_SYNTHESIZE_ABSTRACT_SINGLETON(sharedInstance)
#define BM_SYNTHESIZE_SINGLETON(getter) BM_SYNTHESIZE_SINGLETON_IMPL(getter, BMSingleton.class)
#define BM_SYNTHESIZE_DEFAULT_SINGLETON BM_SYNTHESIZE_SINGLETON(sharedInstance)

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BMReleaseSharedInstancesNotification;

@interface BMSingleton : NSObject

BM_DECLARE_DEFAULT_SINGLETON

+ (void)releaseAllSharedInstances;

/**
 * Returns NO while releaseAllSharedInstances is busy to avoid creating shared instances while they are being released.
 */
+ (BOOL)isSharedInstanceCreationAllowed;

@end

NS_ASSUME_NONNULL_END

