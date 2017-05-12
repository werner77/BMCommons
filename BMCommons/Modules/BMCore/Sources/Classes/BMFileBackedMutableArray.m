//
//  BMFileBackedMutableArray.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMFileBackedMutableArray.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMCache.h>

@interface BMFileBackedMutableArrayCacheKey : NSObject<NSCopying>

@property (nonatomic, assign) uint64_t instanceAddress;
@property (nonatomic, assign) uint32_t location;

@end

static inline uint32_t safeCast(uint64_t i) {
    static NSString * const exceptionReason = @"File size of backing store for BMFileBackedMutableArray cannot exceed 4GB";
    return BMShortenUIntSafely(i, exceptionReason);
}

@implementation BMFileBackedMutableArrayCacheKey

- (id)initWithInstance:(BMFileBackedMutableArray *)instance andLocation:(NSUInteger)location {
    if ((self = [self init])) {
        self.instanceAddress = (uint64_t)instance;
        self.location = safeCast(location);
    }
    return self;
}

- (BOOL)isForInstance:(BMFileBackedMutableArray *)instance {
    return self.instanceAddress == (uint64_t)instance;
}

- (id)copyWithZone:(NSZone *)zone {
    BMFileBackedMutableArrayCacheKey *copy = (BMFileBackedMutableArrayCacheKey *)[[[self class] alloc] init];
    copy.instanceAddress = self.instanceAddress;
    copy.location = self.location;
    return copy;
}

- (NSUInteger)hash {
    NSUInteger hash = 31;
    hash = 31 * hash + (NSUInteger)self.instanceAddress;
    hash = 31 * hash + self.location;
    return hash;
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[self class]]) {
        BMFileBackedMutableArrayCacheKey *otherKey = (BMFileBackedMutableArrayCacheKey *)object;
        ret = self.instanceAddress == otherKey.instanceAddress && self.location == otherKey.location;
    }
    return ret;
}

@end

@implementation BMFileBackedMutableArray {
    NSFileHandle *_fileHandle;
    NSString *_filePath;
    NSMutableArray *_filePointers;
    NSUInteger _maxLocation;
}

static BMCache *globalCache = nil;

static const NSUInteger kDefaultCacheMaxMemoryUsage = 20 * 1000 * 1000;

+ (BMCache *)globalCache {
    if (globalCache == nil) {
        globalCache = [[BMCache alloc] init];
        globalCache.timeout = 0;
        globalCache.maxMemoryUsage = kDefaultCacheMaxMemoryUsage;
        globalCache.maxCount = 0;
    }
    return globalCache;
}

- (id)init {
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)numItems {
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    BMFileBackedMutableArray *copy = (BMFileBackedMutableArray *)[[self.class alloc] init];
    [copy addObjectsFromArray:self];
    return copy;
}

- (void)commonInit {
    _filePath = [BMFileHelper createTempFile];
    
    if (_filePath) {
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        _filePointers = [NSMutableArray new];
    } else {
        @throw [NSException exceptionWithName:@"BMDiskLimitExceededException" reason:@"Could not create temp file as backing store for BMFileBackedMutableArray" userInfo:nil];
    }
}

- (void)dealloc {
    [self removeCachedObjects];
    if (_fileHandle) {
        [_fileHandle closeFile];
    }
    if (_filePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    }
}

- (void)addObject:(id)anObject {
    [self insertObject:anObject atIndex:self.count];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self removeObjectAtIndex:index];
    [self insertObject:anObject atIndex:index];
}

- (void)removeLastObject {
    [self removeObjectAtIndex:self.count - 1];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    @autoreleasepool {
        unsigned long long eofPointer = [_fileHandle seekToEndOfFile];
        uint32_t location = safeCast(eofPointer);
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
        uint32_t dataLength = safeCast(data.length);
        [_fileHandle writeData:data];
        
        uint64_t pointer = [self pointerForFileLocation:location withDataSize:dataLength];
        [_filePointers insertObject:[NSNumber numberWithUnsignedLongLong:pointer] atIndex:index];
        
        uint32_t endLocation = location + dataLength;
        _maxLocation = MAX(_maxLocation, endLocation);
        
        [self setCachedObject:anObject forLocation:location];
    }
}

- (void)removeAllObjects {
    [self removeCachedObjects];
    [_filePointers removeAllObjects];
    [_fileHandle truncateFileAtOffset:0];
    _maxLocation = 0;
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    uint32_t location, dataSize;
    [self getLocation:&location andDataSize:&dataSize atIndex:index];
    uint32_t endLocation = location + dataSize;
    
    if (endLocation == _maxLocation) {
        _maxLocation -= dataSize;
        [_fileHandle truncateFileAtOffset:_maxLocation];
    }
    [_filePointers removeObjectAtIndex:index];
    [self removeCachedObjectForLocation:location];
}

- (NSUInteger)count {
    return [_filePointers count];
}

- (unsigned long long)fileSize {
    return [_fileHandle seekToEndOfFile];
}

- (id)objectAtIndex:(NSUInteger)index {
    id object = nil;
    @autoreleasepool {
        //Automatically raises an NSRangeException because _filePointer contains exactly as many objects as this array
        uint32_t location, dataSize;
        [self getLocation:&location andDataSize:&dataSize atIndex:index];
        object = [self cachedObjectAtLocation:location];
        if (object == nil) {
            [_fileHandle seekToFileOffset:location];
            NSData *data = [_fileHandle readDataOfLength:dataSize];
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self setCachedObject:object forLocation:location];
        }
    }
    return object;
}

#pragma mark - Private

- (uint64_t)pointerAtIndex:(NSUInteger)index {
    return [[_filePointers objectAtIndex:index] unsignedLongLongValue];
}

- (void)getLocation:(uint32_t *)location andDataSize:(uint32_t *)dataSize atIndex:(NSUInteger)index {
    uint64_t pointer = [self pointerAtIndex:index];
    [self getLocation:location andDataSize:dataSize fromPointer:pointer];
}

- (uint64_t)pointerForFileLocation:(uint32_t)location withDataSize:(uint32_t)dataSize {
    uint64_t pointer = (uint64_t)location;
    pointer <<= 32;
    pointer |= (uint64_t)dataSize;
    return pointer;
}

- (void)getLocation:(uint32_t *)location andDataSize:(uint32_t *)dataSize fromPointer:(uint64_t)pointer {
    uint64_t location64 = pointer >> 32;
    
    if (location) {
        *location = (uint32_t)location64;
    }
    
    if (dataSize) {
        *dataSize = (uint32_t)pointer;
    }
}

- (void)truncateFile {
    uint32_t maxLocation = 0;
    uint32_t location, dataSize;
    uint32_t endLocation;
    for (NSUInteger i = 0; i < _filePointers.count; ++i) {
        [self getLocation:&location andDataSize:&dataSize atIndex:i];
        endLocation = location + dataSize;
        maxLocation = MAX(maxLocation, endLocation);
    }
    [_fileHandle truncateFileAtOffset:maxLocation];
    _maxLocation = maxLocation;
}

- (void)setCachedObject:(id)object forLocation:(NSUInteger)location {
    if (object) {
        BMFileBackedMutableArrayCacheKey *key = [[BMFileBackedMutableArrayCacheKey alloc] initWithInstance:self andLocation:location];
        BMCache *cache = [[self class] globalCache];
        [cache setObject:object forKey:key];
    }
}

- (void)removeCachedObjectForLocation:(NSUInteger)location {
    BMFileBackedMutableArrayCacheKey *key = [[BMFileBackedMutableArrayCacheKey alloc] initWithInstance:self andLocation:location];
    BMCache *cache = [[self class] globalCache];
    [cache removeObjectForKey:key];
}

- (id)cachedObjectAtLocation:(NSUInteger)location {
    BMFileBackedMutableArrayCacheKey *key = [[BMFileBackedMutableArrayCacheKey alloc] initWithInstance:self andLocation:location];
    BMCache *cache = [[self class] globalCache];
    return [cache objectForKey:key];
}

- (void)removeCachedObjects {
    BMCache *cache = [[self class] globalCache];
    for (BMFileBackedMutableArrayCacheKey *key in [cache allKeys]) {
        if ([key isForInstance:self]) {
            [cache removeObjectForKey:key];
        }
    }
}

@end
