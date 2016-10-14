//
//  BMSingleton.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#ifndef BMCommons_BMSingleton_h
#define BMCommons_BMSingleton_h

/**
 Macros to easily create singleton classes.
 */

#define BM_SYNTHESIZE_SINGLETON(classname, getter) \
+ (classname *)getter \
{ \
static classname *shared##classname = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##classname = [super new]; \
}); \
return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
static classname *instance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [super allocWithZone:zone]; \
}); \
return instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}

#define BM_DECLARE_SINGLETON(getter) \
- (instancetype)init NS_UNAVAILABLE; \
+ (instancetype)new NS_UNAVAILABLE; \
+ (instancetype)getter;

#define BM_DECLARE_DEFAULT_SINGLETON BM_DECLARE_SINGLETON(sharedInstance)
#define BM_SYNTHESIZE_DEFAULT_SINGLETON(classname) BM_SYNTHESIZE_SINGLETON(classname, sharedInstance)

#endif
