//
//  BMNib.m
//  BMCommons
//
//  Created by Werner Altewischer on 29/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMNib.h>
#import <BMCommons/BMWeakTimer.h>
#import <BMCommons/NSObject+BMCommons.h>

@interface BMNib()

@property (nonatomic, strong) UINib *nibImpl;
@property (nonatomic, assign) Class objectClass;
@property (nonatomic, strong) NSMutableArray *cache;
@property (assign) BOOL cacheWarmupScheduled;

@end

#define DEBUG_LOGGING 0

@implementation BMNib {
    NSUInteger _preCacheSize;
}

static NSMutableDictionary *defaultPreCacheSizeDictionary = nil;
static NSMutableDictionary *defaultCacheSizeDictionary = nil;

// If the bundle parameter is nil, the main bundle is used.
// Releases resources in response to memory pressure (e.g. memory warning), reloading from the bundle when necessary.
+ (BMNib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil {
    BMNib *nib = [BMNib new];
    nib.nibImpl = [UINib nibWithNibName:name bundle:bundleOrNil];
    return nib;
}

// If the bundle parameter is nil, the main bundle is used.
+ (BMNib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil {
    BMNib *nib = [BMNib new];
    nib.nibImpl = [UINib nibWithData:data bundle:bundleOrNil];
    return nib;
}

+ (BMNib *)nibWithObjectClass:(Class)clazz {
    BMNib *nib = [BMNib new];
    nib.objectClass = clazz;
    return nib;
}

+ (NSUInteger)defaultPreCacheSizeForNibName:(NSString *)nibName {
    @synchronized (BMNib.class) {
        return [[defaultPreCacheSizeDictionary objectForKey:nibName] unsignedIntegerValue];
    }
}

+ (NSUInteger)defaultCacheSizeForNibName:(NSString *)nibName{
    @synchronized (BMNib.class) {
        return [[defaultCacheSizeDictionary objectForKey:nibName] unsignedIntegerValue];
    }
}

+ (void)setDefaultPreCacheSize:(NSUInteger)preCacheSize forNibName:(NSString *)nibName {
    @synchronized (BMNib.class) {
        if (defaultPreCacheSizeDictionary == nil) {
            defaultPreCacheSizeDictionary = [NSMutableDictionary new];
        }
        if (nibName) {
            [defaultPreCacheSizeDictionary setObject:@(preCacheSize) forKey:nibName];
        }
    }
}

+ (void)setDefaultCacheSize:(NSUInteger)preCacheSize forNibName:(NSString *)nibName{
    @synchronized (BMNib.class) {
        if (defaultCacheSizeDictionary == nil) {
            defaultCacheSizeDictionary = [NSMutableDictionary new];
        }
        if (nibName) {
            [defaultCacheSizeDictionary setObject:@(preCacheSize) forKey:nibName];
        }
    }
}

#pragma mark - Properties

- (void)setPreCacheSize:(NSUInteger)cacheSize {
    @synchronized (self) {
        if (cacheSize != _preCacheSize) {
            _preCacheSize = cacheSize;
            [self populatePreCache];
        }
    }
}

- (NSUInteger)preCacheSize {
    @synchronized (self) {
        return _preCacheSize;
    }
}

- (NSMutableArray *)cache {
    @synchronized (self) {
        if (_cache == nil) {
            _cache = [NSMutableArray new];
        }
        return _cache;
    }
}

#pragma mark - Caching

- (NSUInteger)maxCacheSize {
    @synchronized (self) {
        return MAX(self.preCacheSize, self.cacheSize);
    }
}

- (NSUInteger)minCacheSize {
    @synchronized (self) {
        return MIN(self.cacheSize, self.preCacheSize);
    }
}

- (void)populatePreCache {
    if (self.cacheCount < self.maxCacheSize) {
        [self scheduleWarmupToSize:self.maxCacheSize];
    }
}

- (NSUInteger)cacheCount {
    @synchronized (self) {
        return self.cache.count;
    }
}

- (void)warmupCacheToSize:(NSUInteger)cacheSize {
#if DEBUG_LOGGING
    NSLog(@"Warming up cache...");
#endif
    NSUInteger count = 0;
    while (self.cacheCount < cacheSize) {
        NSArray *data = [self instantiateReusable];
        if (data) {
            @synchronized (self) {
                [self.cache addObject:data];
            }
            count++;
        } else {
            break;
        }
    }
#if DEBUG_LOGGING
    NSLog(@"Cache warm up finished: instantiated %tu objects", count);
#endif
    [self unscheduleWarmup];
}

- (NSArray *)popDataFromCache {
    @synchronized (self) {
        NSArray *ret = [self.cache firstObject];
        if (ret) {
            [self.cache removeObjectAtIndex:0];
        }
        NSUInteger minCacheSize = self.minCacheSize;
        if (self.cache.count < minCacheSize) {
            [self scheduleWarmupToSize:minCacheSize];
        }
#if DEBUG_LOGGING
        if (ret == nil) {
            NSLog(@"No cached object available!");
        } else {
            NSLog(@"Got object from cache, cache size is now: %tu", self.cache.count);
        }
#endif
        return ret;
    }
}

- (void)scheduleWarmupToSize:(NSUInteger)size {
    if (!self.cacheWarmupScheduled) {
        self.cacheWarmupScheduled = YES;
        __typeof(self) __weak weakSelf = self;
        void (^block)(void) = ^{
            if (weakSelf.cacheWarmupScheduled) {
                [weakSelf warmupCacheToSize:size];
            }
        };
        [self bmPerformBlockInBackground:^id {
            block();
            return nil;
        } withCompletion:nil];
    }
}

- (void)unscheduleWarmup {
    self.cacheWarmupScheduled = NO;
}

#pragma mark - Instantiation

- (NSArray *)instantiateCachedWithOwner:(id)owner options:(NSDictionary *)options fromCache:(BOOL *)fromCache {
    NSArray *ret = nil;
    BOOL cached = NO;
    if (owner == nil && options == nil) {
        ret = [self popDataFromCache];
        if (ret == nil) {
#if DEBUG_LOGGING
            NSLog(@"Cache empty! Instantiating new object!");
#endif
            ret = [self instantiateReusable];
        } else {
            cached = YES;
        }
    } else {
        ret = [self instantiateImplWithOwner:owner options:options];
    }
    if (fromCache) {
        *fromCache = cached;
    }
    return ret;
}

- (NSArray *)instantiateReusable {
    NSArray *ret = [self instantiateImplWithOwner:nil options:nil];
    return ret;
}

- (void)clearCache {
    @synchronized (self) {
        [_cache removeAllObjects];
    }
}

- (NSArray *)instantiateImplWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil {
    Class objectClass = self.objectClass;
    NSArray *ret = nil;

    if (self.nibImpl != nil) {
        return [self.nibImpl instantiateWithOwner:ownerOrNil options:optionsOrNil];
    } else if (objectClass != nil) {
        id object = [objectClass new];
        [object awakeFromNib];
        ret = object ? @[object] : nil;
    }
    return ret;
}

- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil {
    BOOL fromCache = NO;
    NSArray *ret = [self instantiateCachedWithOwner:ownerOrNil options:optionsOrNil fromCache:&fromCache];
    return ret;
}


@end
