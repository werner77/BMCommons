//
//  BMCache.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/23/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMCache.h"
#import "BMOrderedDictionary.h"
#import <BMCore/BMCore.h>
#import <malloc/malloc.h>

@interface _BMCacheDate : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) unsigned long long index;

@end

@implementation _BMCacheDate

@end

@implementation BMCache {
    NSUInteger _cacheIndexCounter;
}

@synthesize timeout = _timeout, maxCount = _maxCount, memoryUsed = _memoryUsed;

- (id)init {
    if ((self = [super init])) {
        _dictionary = [NSMutableDictionary new];
        _keys = [NSMutableDictionary new];
        _cacheIndexCounter = 0;
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(_dictionary);
    BM_RELEASE_SAFELY(_keys);
}

- (void)setObject:(id)object forKey:(id<NSCopying, NSObject>)key {
    @synchronized(self) {
        if (key) {
            id oldObject = [_dictionary objectForKey:key];
            if (oldObject) {
                [self removeObjectForKey:key];
            }
            
            [self removeSuperfluousObjects];
            
            if (object) {
                [_dictionary setObject:object forKey:key];
                
                _BMCacheDate *cacheDate = [_BMCacheDate new];
                cacheDate.date = [NSDate date];
                cacheDate.index = _cacheIndexCounter++;
                
                [_keys setObject:cacheDate forKey:key];
                [self incrementMemoryUsageForKey:key andObject:object];
            }
        }
    }
}

- (void)removeObjectForKey:(id<NSCopying, NSObject>)key {
    @synchronized(self) {
        if (key) {
            [self decrementMemoryUsageForKey:key];
            [_dictionary removeObjectForKey:key];
            [_keys removeObjectForKey:key];
        }
    }
}

- (void)clear {
    @synchronized(self) {
        [_dictionary removeAllObjects];
        [_keys removeAllObjects];
        _memoryUsed = 0;
    }
}

- (NSArray *)allKeys {
    @synchronized(self) {
        return [NSArray arrayWithArray:[_dictionary allKeys]];
    }
}

- (NSArray *)allObjects {
    @synchronized(self) {
        return [NSArray arrayWithArray:[_dictionary allValues]];
    }
}

- (NSUInteger)count {
    return _dictionary.count;
}

- (BOOL)hasObjectForKey:(id<NSCopying, NSObject>)key {
    @synchronized(self) {
        _BMCacheDate *cacheDate = [_keys objectForKey:key];
        BOOL ret = NO;
        if (cacheDate) {
            if (self.timeout <= 0 || (-[cacheDate.date timeIntervalSinceNow]) <= self.timeout) {
                ret = YES;
            }
        }
        return ret;
    }
}

- (id)objectForKey:(id<NSCopying, NSObject>)key {
    @synchronized(self) {
        _BMCacheDate *cacheDate = [_keys objectForKey:key];
        id ret = nil;
        if (cacheDate) {
            if (self.timeout <= 0 || (-[cacheDate.date timeIntervalSinceNow]) <= self.timeout) {
                ret = [_dictionary objectForKey:key];
                if (ret) {
                    cacheDate.index = _cacheIndexCounter++;
                }
            } else {
                [_keys removeObjectForKey:key];
                [_dictionary removeObjectForKey:key];
            }
        }
        return ret;
    }
}

#pragma mark - Private

- (NSArray *)sortedKeys {
    return [[_keys allKeys] sortedArrayUsingComparator:^NSComparisonResult(id key1, id key2) {
        _BMCacheDate *obj1 = [_keys objectForKey:key1];
        _BMCacheDate *obj2 = [_keys objectForKey:key2];
        
        if (obj1.index < obj2.index) {
            return NSOrderedAscending;
        } else if (obj1.index > obj2.index) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)removeSuperfluousObjects {
    if (self.maxCount > 0 && _keys.count >= self.maxCount) {
        NSArray *sortedKeys = [self sortedKeys];
        NSUInteger limit = self.maxCount/2;
        
        for (NSUInteger i = 0; i < limit; ++i) {
            id theKey = [sortedKeys objectAtIndex:i];
            
            [self decrementMemoryUsageForKey:theKey];
            [_dictionary removeObjectForKey:theKey];
            [_keys removeObjectForKey:theKey];
        }
    }
    if (self.maxMemoryUsage > 0 && _memoryUsed >= self.maxMemoryUsage) {
        NSArray *sortedKeys = [self sortedKeys];
        NSUInteger limit = self.maxMemoryUsage/2;
        NSUInteger i = 0;
        while (_memoryUsed > limit) {
            id theKey = [sortedKeys objectAtIndex:i++];
            [self decrementMemoryUsageForKey:theKey];
            [_dictionary removeObjectForKey:theKey];
            [_keys removeObjectForKey:theKey];
        }
    }
}

- (void)incrementMemoryUsageForKey:(id)key andObject:(id)object {
    if (key && object) {
        size_t numberOfBytes = [self sizeForObject:object] + [self sizeForObject:key];
        _memoryUsed += numberOfBytes;
    }
}

- (size_t)sizeForObject:(id)object {
    if (object == nil) {
        return 0;
    }
    
    size_t size = malloc_size((__bridge void *)object);
    return size;
}

- (void)decrementMemoryUsageForKey:(id)theKey {
    id theObject = [_dictionary objectForKey:theKey];
    if (theObject) {
        size_t numberOfBytes = [self sizeForObject:theObject] + [self sizeForObject:theKey];
        if (numberOfBytes  > _memoryUsed) {
            _memoryUsed = 0;
        } else {
            _memoryUsed -= numberOfBytes;
        }
    }
}


@end
