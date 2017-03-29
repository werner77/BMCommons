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
@property (assign) NSUInteger instantiationCount;

@end

@implementation BMNib

static NSMutableDictionary *defaultCacheSizeDictionary = nil;
static NSMutableDictionary *minCacheSizeDictionary = nil;

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

+ (NSUInteger)defaultPrecacheSizeForNibName:(NSString *)nibName {
    return [[defaultCacheSizeDictionary objectForKey:nibName] unsignedIntegerValue];
}

+ (NSUInteger)defaultMinPrecacheSizeForNibName:(NSString *)nibName{
    return [[minCacheSizeDictionary objectForKey:nibName] unsignedIntegerValue];
}

+ (void)setDefaultPrecacheSize:(NSUInteger)preCacheSize forNibName:(NSString *)nibName {
    if (defaultCacheSizeDictionary == nil) {
        defaultCacheSizeDictionary = [NSMutableDictionary new];
    }
    if (nibName) {
        [defaultCacheSizeDictionary setObject:@(preCacheSize) forKey:nibName];
    }
}

+ (void)setDefaultMinPrecacheSize:(NSUInteger)preCacheSize forNibName:(NSString *)nibName{
    if (minCacheSizeDictionary == nil) {
        minCacheSizeDictionary = [NSMutableDictionary new];
    }
    if (nibName) {
        [minCacheSizeDictionary setObject:@(preCacheSize) forKey:nibName];
    }
}

#pragma mark - Properties

- (void)setPreCacheSize:(NSUInteger)cacheSize {
    if (cacheSize != _preCacheSize) {
        _preCacheSize = cacheSize;
        [self populateCache];
    }
}

- (NSMutableArray *)cache {
    if (_cache == nil) {
        _cache = [NSMutableArray new];
    }
    return _cache;
}

#pragma mark - Caching

- (void)populateCache {
    if (self.instantiationCount < self.preCacheSize) {
        [self scheduleWarmup];
    }
}

- (void)warmupCache {
    @synchronized (self) {
        while (self.instantiationCount < self.preCacheSize) {
            NSArray *data = [self instantiateReusable];
            if (data) {
                [self.cache addObject:data];
            } else {
                break;
            }
        }
        self.cacheWarmupScheduled = NO;
    }
}

- (NSArray *)popDataFromCache {
    @synchronized (self) {
        NSArray *ret = [self.cache firstObject];
        if (ret) {
            [self.cache removeObjectAtIndex:0];
        }
        NSUInteger minCacheSize = MIN(self.minPreCacheSize, self.preCacheSize);
        if (self.cache.count < minCacheSize) {
            self.instantiationCount = self.preCacheSize - minCacheSize;
            [self scheduleWarmup];
        }
        return ret;
    }
}

- (void)scheduleWarmup {
    if (!self.cacheWarmupScheduled) {
        self.cacheWarmupScheduled = YES;
        __typeof(self) __weak weakSelf = self;
        void (^block)(void) = ^{
            if (weakSelf.cacheWarmupScheduled) {
                [weakSelf warmupCache];
            }
        };

        if (self.allocateInBackgroundThread) {
            [self bmPerformBlockInBackground:^id {
                block();
                return nil;
            } withCompletion:nil];
        } else {
            [self bmPerformBlock:block afterDelay:0.1];
        }
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
            ret = [self instantiateReusable];
            if (self.instantiationCount >= self.preCacheSize) {
                [self unscheduleWarmup];
            } else if (self.preCacheSize > 0) {
                [self scheduleWarmup];
            }
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
    NSLog(@"Instantiating new cell!");
    NSArray *ret = [self instantiateImplWithOwner:nil options:nil];
    if (ret) {
        self.instantiationCount++;
    }
    return ret;
}

- (void)clearCache {
    @synchronized (self) {
        self.instantiationCount -= self.cache.count;
        _cache = nil;
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
