//
//  BMSingleton.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BMReleaseSharedInstancesNotification @"com.behindmedia.BMReleaseSharedInstancesNotification"

#define BM_SYNTHESIZE_SINGLETON(getter) \
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
instance = instances[(id <NSCopying>)self]; \
if (instance == nil && createIfNotExists) { \
id allocatedInstance = [self alloc]; \
if (allocatedInstance != nil) { \
instances[(id <NSCopying>)self] = allocatedInstance; \
} \
instance = [allocatedInstance init]; \
if (allocatedInstance != instance) { \
if (instance == nil) { \
[instances removeObjectForKey:(id <NSCopying>)self]; \
} else { \
instances[(id <NSCopying>)self] = instance; \
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
if ([instances objectForKey:(id <NSCopying>)self] != nil) { \
[instances removeObjectForKey:(id <NSCopying>)self]; \
[[NSNotificationCenter defaultCenter] removeObserver:self name:BMReleaseSharedInstancesNotification object:nil]; \
} \
} \
}

#define BM_DECLARE_SINGLETON(getter) \
+ (instancetype)getter; \
+ (instancetype)getter:(BOOL)createIfNotExists; \
+ (void)releaseSharedInstance;

#define BM_DECLARE_DEFAULT_SINGLETON BM_DECLARE_SINGLETON(sharedInstance)
#define BM_SYNTHESIZE_DEFAULT_SINGLETON BM_SYNTHESIZE_SINGLETON(sharedInstance)


@interface BMSingleton : NSObject

BM_DECLARE_DEFAULT_SINGLETON

+ (void)releaseAllSharedInstances;

@end

