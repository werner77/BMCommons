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
#import <BMCommons/BMCore.h>
#import <BMCommons/BMObjectHelper.h>

@interface BMNib()

@property (nonatomic, strong) NSString *nibName;
@property (nonatomic, strong) UINib *nibImpl;
@property (nonatomic, assign) Class objectClass;
@property (nonatomic, strong) NSMutableArray *cache;
@property (assign) BOOL cacheWarmupScheduled;
@property (nonatomic, strong) BMWeakTimer *cacheWarmupTimer;

@end

#define DEBUG_LOGGING 0

@implementation BMNib {
    NSUInteger _preCacheSize;
}

// If the bundle parameter is nil, the main bundle is used.
// Releases resources in response to memory pressure (e.g. memory warning), reloading from the bundle when necessary.
+ (BMNib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil {
    BMNib *nib = [BMNib new];
    nib.nibImpl = [UINib nibWithNibName:name bundle:bundleOrNil];
    nib.nibName = name;
    [nib configure];
    return nib;
}

// If the bundle parameter is nil, the main bundle is used.
+ (BMNib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil {
    BMNib *nib = [BMNib new];
    nib.nibImpl = [UINib nibWithData:data bundle:bundleOrNil];
    nib.nibName = nil;
    [nib configure];
    return nib;
}

+ (BMNib *)nibWithObjectClass:(Class)clazz {
    BMNib *nib = [BMNib new];
    nib.objectClass = clazz;
    nib.nibName = NSStringFromClass(clazz);
    [nib configure];
    return nib;
}

+ (NSMutableDictionary *)configurationBlocks {
    static NSMutableDictionary *ret = nil;
    BM_DISPATCH_ONCE(^{
        ret = [NSMutableDictionary new];
    });
    return ret;
}

+ (void)setConfigurationBlock:(BMNibConfigurationBlock)block forNibWithName:(NSString *)nibName {
    @synchronized (BMNib.class) {
        if (block) {
            self.configurationBlocks[[BMObjectHelper filterNullObject:nibName]] = [block copy];
        }
    }
}

+ (BMNibConfigurationBlock)configurationBlockForNibWithName:(NSString *)nibName {
    BMNibConfigurationBlock block = nil;
    @synchronized (BMNib.class) {
        block = self.configurationBlocks[[BMObjectHelper filterNullObject:nibName]];
        if (block == nil && nibName != nil) {
            //Revert to default block
            block = self.configurationBlocks[[NSNull null]];
        }
    }
    return block;
}

#pragma mark - Properties

- (void)configure {
    BMNibConfigurationBlock configurationBlock = [self.class configurationBlockForNibWithName:self.nibName];
    if (configurationBlock) {
        configurationBlock(self);
    }
}

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
    while (self.cacheCount < cacheSize || count < cacheSize) {
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

        if (self.warmupCacheInBackground) {
            [self bmPerformBlockInBackground:^id {
                block();
                return nil;
            } withCompletion:nil];
        } else {
            self.cacheWarmupTimer = [BMWeakTimer scheduledTimerWithTimeInterval:0.01 block:^(BMWeakTimer *t) {
                block();
                weakSelf.cacheWarmupTimer = nil;
            } repeats:NO onRunloop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
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
    if ((owner == nil && options == nil) || self.nibImpl == nil) {
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
