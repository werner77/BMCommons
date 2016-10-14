//
//  BMURLCache.h
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMURLCache.h>
#import <CommonCrypto/CommonDigest.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMCache.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMWeakTimer.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/BMFileAttributes.h>
#import <BMCommons/NSFileManager+BMCommons.h>
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE

#import <BMCommons/UIImage+BMCommons.h>

#endif

//////////////////////////////////////////////////////////////////////////////////////////////////

#define CACHE_EXPIRATION_CHECK_INTERVAL 60

#define FILE_PIN_ATTRIBUTE NSFileImmutable

#define IGNORE_EXTENSION @".ignore"

static NSString* kDefaultCacheName = @"BMURLCache";
static NSString* kEtagCacheDirectoryName = @"etag";

static NSString * const kBMInvalidationAgeAttribute = @"BMURLCacheInvalidationAge";

static BMURLCache* gSharedCache = nil;
static NSMutableDictionary* gNamedCaches = nil;

@interface BMURLCache()

@property (strong) NSDate *lastWriteDate;
@property(copy) NSString* cachePath;

@end

@interface BMURLCache(Private)

+ (NSString*)cachePathWithName:(NSString*)name persistent:(BOOL)persistent;
+ (NSString*)doubleImageURLPath:(NSString*)urlPath;

- (void)setValue:(id)value forAttribute:(id)attribute forFile:(NSString *)filePath;
- (void)invalidateFileAtPath:(NSString *)filePath;
- (void)unpinFile:(NSString *)filePath;
- (void)pinFile:(NSString *)filePath;
- (BOOL)removeFile:(NSString *)filePath;
- (BOOL)removeFile:(NSString *)filePath force:(BOOL)force;
- (void)expireFilesFromDisk;
- (void)expireFilesFromDiskWithCompletion:(void (^)(void))completion;
- (BOOL)hasDataForKey:(NSString *)key filePath:(NSString **)fp;

#if TARGET_OS_IPHONE

- (void)expireImagesFromMemory;
- (void)storeImage:(UIImage*)image forKey:(NSString*)key force:(BOOL)force;
- (UIImage*)loadImageFromBundle:(NSString*)URL;
- (UIImage*)loadImageFromDocuments:(NSString*)URL;

#endif

- (NSString*)createTemporaryURLForFile:(NSString *)file;
- (NSString*)createTemporaryURL;
- (NSString *)ignoredPathForPath:(NSString *)path;
- (NSString *)pathForIgnoredPath:(NSString *)path;
- (BOOL)isIgnoredPath:(NSString *)path;
- (void)resetIgnoredPath:(NSString *)path;
- (void)setIgnoredPath:(NSString *)path;
- (NSString*)loadEtagFromCacheWithKey:(NSString*)key;

- (BOOL)imageExistsFromBundle:(NSString*)URL;
- (BOOL)imageExistsFromDocuments:(NSString*)URL;
- (NSString *)localURLPrefix;
- (NSFileManager *)fileManager;

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BMURLCache {
    BMCache *_fileAttributesCache;
    NSFileManager *_fileManager;
    NSString* _name;
    NSString* _cachePath;
    NSMutableDictionary* _imageCache;
    NSMutableArray* _imageSortedList;
    NSUInteger _totalPixelCount;
    NSUInteger _maxPixelCount;
    NSUInteger _maxDiskSpace;
    NSInteger _totalLoading;
    NSTimeInterval _invalidationAge;
    BOOL _persistent;
    BMWeakTimer *_timer;
    BOOL _expiringFilesFromDisk;
    BOOL _active;
    BOOL _performingInitialExpiration;
    BOOL _diskCacheEnabled;
    BOOL _imageCacheEnabled;
}

@synthesize cachePath = _cachePath, maxPixelCount = _maxPixelCount, invalidationAge = _invalidationAge,
maxDiskSpace = _maxDiskSpace, persistent = _persistent, name = _name;

#pragma mark - Class methods

static BOOL gDiskCacheEnabled = YES;
static BOOL gImageCacheEnabled = YES;

+ (NSMutableDictionary *)gNamedCaches {
    @synchronized([BMURLCache class]) {
        if (!gNamedCaches) {
            gNamedCaches = [[NSMutableDictionary alloc] init];
        }
        return gNamedCaches;
    }
}

+ (BMURLCache*)cacheWithName:(NSString*)name persistent:(BOOL)persistent {
    @synchronized([BMURLCache class]) {
        BMURLCache* cache = [self.gNamedCaches objectForKey:[BMObjectHelper filterNullObject:name]];
        if (!cache) {
            cache = [[BMURLCache alloc] initWithName:name persistent:persistent];
        }
        return cache;
    }
}

+ (void)addCache:(BMURLCache *)cache forName:(NSString *)name {
    @synchronized([BMURLCache class]) {
        [self.gNamedCaches setObject:cache forKey:[BMObjectHelper filterNullObject:name]];
    }
}

+ (BMURLCache*)cacheWithName:(NSString*)name {
    return [self cacheWithName:name persistent:NO];
}

+ (BMURLCache*)sharedCache {
    @synchronized([BMURLCache class]) {
        if (!gSharedCache) {
            gSharedCache = [[BMURLCache alloc] init];
        }
        return gSharedCache;
    }
}

+ (void)setSharedCache:(BMURLCache*)cache {
    @synchronized([BMURLCache class]) {
        if (gSharedCache != cache) {
            gSharedCache = cache;
        }
    }
}

+ (NSArray *)allCaches {
    @synchronized([BMURLCache class]) {
        return self.gNamedCaches.allValues;
    }
}

+ (void)setGlobalDiskCacheEnabled:(BOOL)enabled {
    @synchronized([BMURLCache class]) {
        gDiskCacheEnabled = enabled;
    }
}

+ (BOOL)isGlobalDiskCacheEnabled {
    @synchronized([BMURLCache class]) {
        return gDiskCacheEnabled;
    }
}

+ (void)setGlobalImageCacheEnabled:(BOOL)enabled {
    @synchronized([BMURLCache class]) {
        gImageCacheEnabled = enabled;
    }
}

+ (BOOL)isGlobalImageCacheEnabled {
    @synchronized([BMURLCache class]) {
        return gImageCacheEnabled;
    }
}

#pragma mark - Initialization and deallocation

- (id)initWithName:(NSString*)name {
    return [self initWithName:name persistent:NO];
}

- (id)initWithName:(NSString*)name persistent:(BOOL)persistent {
    if ((self = [super init])) {
        _name = [name copy];
        _cachePath = [BMURLCache cachePathWithName:name persistent:persistent];
        _imageCache = nil;
        _imageSortedList = nil;
        _totalLoading = 0;
        _imageCacheEnabled = YES;
        _diskCacheEnabled = YES;
        _invalidationAge = BM_DEFAULT_CACHE_INVALIDATION_AGE;
        _maxPixelCount = 0;
        _maxSingleImagePixelCount = 0;
        _totalPixelCount = 0;
        _persistent = persistent;
        _fileAttributesCache = [BMCache new];
        _fileAttributesCache.maxMemoryUsage = 1 * 1024 * 1024;
        
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
#endif
        [[self class] addCache:self forName:_name];
        self.active = YES;
    }
    return self;
}

- (id)init {
    return [self initWithName:kDefaultCacheName persistent:NO];
}

- (void)dealloc {
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
#endif
    [_timer invalidate];
    BM_RELEASE_SAFELY(_name);
    BM_RELEASE_SAFELY(_imageCache);
    BM_RELEASE_SAFELY(_imageSortedList);
    BM_RELEASE_SAFELY(_cachePath);
    BM_RELEASE_SAFELY(_timer);
}

- (void)setDiskCacheEnabled:(BOOL)diskCacheEnabled {
    @synchronized(self) {
        _diskCacheEnabled = diskCacheEnabled;
    }
}

- (BOOL)isDiskCacheEnabled {
    @synchronized(self) {
        return _diskCacheEnabled && (self.class.isGlobalDiskCacheEnabled || self.isPersistent);
    }
}

- (void)setImageCacheEnabled:(BOOL)imageCacheEnabled {
    @synchronized(self) {
        _imageCacheEnabled = imageCacheEnabled;
    }
}

- (BOOL)isImageCacheEnabled {
    @synchronized(self) {
        return _imageCacheEnabled && self.class.isGlobalImageCacheEnabled;
    }
}

- (void)setActive:(BOOL)active {
    @synchronized(self) {
        if (active != _active) {
            _active = active;
            if (active) {
                _performingInitialExpiration = YES;
                [self expireFilesFromDiskWithCompletion:^{
                    _performingInitialExpiration = NO;
                }];
                _timer = [BMWeakTimer scheduledTimerWithTimeInterval:CACHE_EXPIRATION_CHECK_INTERVAL target:self selector:@selector(expireFilesFromDisk) userInfo:nil repeats:YES];
            } else {
                [_timer invalidate];
                _timer = nil;
            }
        }
    }
}

- (BOOL)isActive {
    @synchronized(self) {
        return _active;
    }
}

- (BOOL)isActiveAndReady {
    @synchronized(self) {
        return _active && !_performingInitialExpiration;
    }
}

#pragma mark - Notifications

- (void)didReceiveMemoryWarning:(void*)object {
    // Empty the memory cache when memory is low
    [self removeAll:NO];
}


#pragma mark - TTURLCache protocol implementation

- (NSString*)etagCachePath {
    return [self.cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];
}

- (NSString*)etagCachePathForKey:(NSString*)key {
    return [self.etagCachePath stringByAppendingPathComponent:key];
}

- (BOOL)hasDataForKey:(NSString*)key {
    return [self hasDataForKey:key filePath:nil];
}

- (NSString*)etagForKey:(NSString*)key {
    return [self loadEtagFromCacheWithKey:key];
}

- (void)storeEtag:(NSString*)etag forKey:(NSString*)key {
    NSString* filePath = [self etagCachePathForKey:key];
    NSFileManager* fm = [self fileManager];
    [fm createFileAtPath: filePath
                contents: [etag dataUsingEncoding:NSUTF8StringEncoding]
              attributes: nil];
}

- (NSString *)keyForURL:(NSString*)URL {
    
    if (URL == nil) {
        return nil;
    } else if ([URL hasPrefix:self.localURLPrefix]) {
        return [URL substringFromIndex:self.localURLPrefix.length];
    }
    const char* str = [URL UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (unsigned int)strlen(str), result);
    
    NSString *pathExtension = [URL pathExtension];
    if (!pathExtension || pathExtension.length > 4) {
        pathExtension = nil;
    }
    
    NSMutableString *keyString = [NSMutableString bmHexEncodedStringForBytes:result length:CC_MD5_DIGEST_LENGTH lowercase:YES];
    if (pathExtension.length > 0) {
        [keyString appendString:@"."];
        [keyString appendString:pathExtension];
    }
    return keyString;
}

- (NSString*)cachePathForURL:(NSString*)URL {
    NSString* key = [self keyForURL:URL];
    NSString *path = [self cachePathForKey:key];
    return path;
}

- (NSString*)cachePathForKey:(NSString*)key {
    return key ? [_cachePath stringByAppendingPathComponent:key] : nil;
}

- (BOOL)hasDataForURL:(NSString*)URL {
    NSString *key = [self keyForURL:URL];
    BOOL ret = [self hasDataForKey:key];
    return ret;
}

- (NSData*)dataForURL:(NSString*)URL {
    NSString* key = [self keyForURL:URL];
    NSData *data = [self dataForKey:key];
    return data;
}

- (NSData*)dataForKey:(NSString*)key {
    NSString* filePath = nil;
    if ([self hasDataForKey:key filePath:&filePath]) {
        return [NSData dataWithContentsOfFile:filePath];
    } else {
        NSString *ignoredPath = [self ignoredPathForPath:filePath];
        if ([[self fileManager] fileExistsAtPath:ignoredPath]) {
            [self resetIgnoredPath:ignoredPath];
        }
    }
    return nil;
}

#if TARGET_OS_IPHONE

- (UIImage *)imageForURL:(NSString*)URL {
    return [self imageForURL:URL fromDisk:YES];
}

- (UIImage *)imageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
    UIImage* image = nil;
    NSString *key = [self keyForURL:URL];
    @synchronized(self) {
        image = [_imageCache objectForKey:key];
    }
    if (!image && fromDisk) {
        if (BMIsBundleURL(URL)) {
            image = [self loadImageFromBundle:URL];
            [self storeImage:image forKey:key];
        } else if (BMIsDocumentsURL(URL)) {
            image = [self loadImageFromDocuments:URL];
            [self storeImage:image forKey:key];
        } else {
            NSData *data = [self dataForKey:key];
            if (data) {
                image = [UIImage bmImageWithData:data];
                [self storeImage:image forKey:key];
            }
        }
    }
    return image;
}

- (UIImage *)imageForKey:(NSString*)key {
    return [self imageForKey:key fromDisk:YES];
}

- (UIImage *)imageForKey:(NSString*)key fromDisk:(BOOL)fromDisk {
    UIImage* image = nil;
    @synchronized(self) {
        image = [_imageCache objectForKey:key];
    }
    if (!image && fromDisk) {
        NSData *data = [self dataForKey:key];
        if (data) {
            image = [UIImage bmImageWithData:data];
            [self storeImage:image forKey:key];
        }
    }
    return image;
}

- (BOOL)hasImageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
    BMURLCacheState cacheState = [self cacheStateForURL:URL checkDisk:fromDisk];
    return cacheState != BMURLCacheStateNone;
}

- (BMURLCacheState)cacheStateForURL:(NSString *)URL {
    return [self cacheStateForURL:URL checkDisk:YES];
}

- (BMURLCacheState)cacheStateForURL:(NSString *)URL checkDisk:(BOOL)checkDisk {
    BMURLCacheState cacheState = BMURLCacheStateNone;
    if (URL != nil) {
        BOOL hasImage = NO;
        NSString *key = [self keyForURL:URL];
        @synchronized(self) {
            if (self.isImageCacheEnabled) {
                hasImage = [_imageCache objectForKey:key] != nil;
            }
        }
        if (hasImage) {
            cacheState = BMURLCacheStateMemory;
        } else if (checkDisk) {
            if (BMIsBundleURL(URL)) {
                hasImage = [self imageExistsFromBundle:URL];
                if (!hasImage) {
                    hasImage = [self imageExistsFromBundle:[[self class] doubleImageURLPath:URL]];
                }
            } else if (BMIsDocumentsURL(URL)) {
                hasImage = [self imageExistsFromDocuments:URL];
                if (!hasImage) {
                    hasImage = [self imageExistsFromDocuments:[[self class] doubleImageURLPath:URL]];
                }
            } else {
                hasImage = [self hasDataForKey:key];
            }
            
            if (hasImage) {
                cacheState = BMURLCacheStateDisk;
            }
        }
    }
    return cacheState;
}

#endif

- (BMFileAttributes *)fileAttributesForFile:(NSString *)filePath {
    BMFileAttributes *ret = [self cachedAttributesForFile:filePath];
    if (!ret) {
        NSFileManager* fm = [self fileManager];
        NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
        if (attrs) {
            NSTimeInterval expirationTimeInterval = self.invalidationAge;
            NSTimeInterval customInvalidationAge = [self invalidationAgeForFile:filePath];
            if (customInvalidationAge > 0) {
                expirationTimeInterval = customInvalidationAge;
            }
            
            ret = [BMFileAttributes fileAttributesForFileAtPath:filePath
                                                                         fileSize:[[attrs objectForKey:NSFileSize] unsignedLongLongValue]
                                                                 modificationDate:[attrs objectForKey:NSFileModificationDate]
                                                                           pinned:[[attrs objectForKey:FILE_PIN_ATTRIBUTE] boolValue] expirationTimeInterval:expirationTimeInterval];
            [self setCachedAttributes:ret forFile:filePath];
        }
    }
    return ret;
}

- (BOOL)hasCachedAttributesForFile:(NSString *)filePath {
    return [_fileAttributesCache hasObjectForKey:filePath];
}

- (BMFileAttributes *)cachedAttributesForFile:(NSString *)filePath {
    return [_fileAttributesCache objectForKey:filePath];
}

- (void)setCachedAttributes:(BMFileAttributes *)attributes forFile:(NSString *)filePath {
    @synchronized(_fileAttributesCache) {
        if (attributes) {
            if (attributes.filePath != nil && ![attributes.filePath isEqual:filePath]) {
                [_fileAttributesCache removeObjectForKey:attributes.filePath];
            }
            attributes.filePath = filePath;
            [_fileAttributesCache setObject:attributes forKey:filePath];
        } else {
            [_fileAttributesCache removeObjectForKey:filePath];
        }
    }
}

- (void)storeData:(NSData *)data forURL:(NSString *)URL {
    [self storeData:data forURL:URL invalidationAge:0];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key {
    [self storeData:data forKey:key invalidationAge:0];
}

- (void)storeData:(NSData *)data forURL:(NSString *)URL invalidationAge:(NSTimeInterval)invalidationAge {
    NSString* key = [self keyForURL:URL];
    [self storeData:data forKey:key invalidationAge:invalidationAge];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key invalidationAge:(NSTimeInterval)invalidationAge {
    if (self.isDiskCacheEnabled) {
        NSString* filePath = [self cachePathForKey:key];
        
        BMFileAttributes *attributes = [self fileAttributesForFile:filePath];
        BOOL pinned = attributes.pinned;
        
        if (pinned) {
            //First unpin the data
            [self unpinFile:filePath];
        }
        
        NSError *error;
        if (![data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            LogWarn(@"Could not create file for storing cache value at path: %@: %@", filePath, error);
        } else {
            NSString *ignoredPath = [self ignoredPathForPath:filePath];
            
            if (ignoredPath) {
                [self removeFile:ignoredPath force:YES];
            }
            
            NSDate *currentDate = [NSDate new];
            [self setLastWriteDate:currentDate];
            
            //Update attributes
            BOOL storeCachedAttribute = NO;
            if (!attributes) {
                storeCachedAttribute = YES;
                attributes = [BMFileAttributes new];
                attributes.filePath = filePath;
            }
            
            attributes.modificationDate = currentDate;
            attributes.fileSize = data.length;
            if (invalidationAge > 0) {
                attributes.expirationTimeInterval = invalidationAge;
                [self setInvalidationAge:invalidationAge forFile:filePath];
            } else {
                attributes.expirationTimeInterval = self.invalidationAge;
            }
            
            if (storeCachedAttribute) {
                [self setCachedAttributes:attributes forFile:filePath];
            }
        }
        
        if (pinned) {
            //Re-pin the file
            [self pinFile:filePath];
        }
    }
}

- (BMFileAttributes *)fileAttributesForURL:(NSString *)URL {
    return [self fileAttributesForKey:[self keyForURL:URL]];
}

- (BMFileAttributes *)fileAttributesForKey:(NSString *)key {
    NSString* filePath = [self cachePathForKey:key];
    return [self fileAttributesForFile:filePath];
}

- (NSTimeInterval)invalidationAgeForFile:(NSString *)filePath {
    NSTimeInterval ret = 0;
    NSError *error = nil;
    NSData *data = [[self fileManager] bmExtendedAttribute:kBMInvalidationAgeAttribute atPath:filePath traverseLink:NO error:&error];
    if (data) {
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (s) {
            ret = [s doubleValue];
        }
    }
    return ret;
}

- (void)setInvalidationAge:(NSTimeInterval)invalidationAge forFile:(NSString *)filePath {
    NSError *error = nil;
    NSString *s = [NSString stringWithFormat:@"%lf", invalidationAge];
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    if (![[self fileManager] bmSetExtendedAttribute:kBMInvalidationAgeAttribute value:data atPath:filePath traverseLink:NO mode:BMXAAnyMode error:&error]) {
        LogWarn(@"Could not set invalidation age extended attribute: %@", error);
    }
}

#if TARGET_OS_IPHONE

- (void)storeImage:(UIImage*)image forURL:(NSString*)URL {
    [self storeImage:image forURL:URL toDisk:NO];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    [self storeImage:image forKey:key toDisk:NO];
}

#endif

- (NSString*)storeTemporaryData:(NSData*)data {
    NSString* URL = [self createTemporaryURL];
    [self storeData:data forURL:URL];
    return URL;
}

- (NSString*)storeTemporaryFile:(NSURL*)fileURL {
    return [self storeTemporaryFile:fileURL copy:NO];
}

#if TARGET_OS_IPHONE

- (NSString*)storeTemporaryImage:(UIImage*)image toDisk:(BOOL)toDisk {
    NSString* URL = [self createTemporaryURLForFile:@"dummy.png"];
    NSString *key = [self keyForURL:URL];
    [self storeImage:image forKey:key force:YES];
    
    if (toDisk)	{
        NSData* data = UIImagePNGRepresentation(image);
        [self storeData:data forKey:key];
    }
    return URL;
}

#endif

- (void)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL {
    if ([oldURL isEqual:newURL]) {
        return;
    }
    NSString* oldKey = [self keyForURL:oldURL];
    NSString* newKey = [self keyForURL:newURL];
    
#if TARGET_OS_IPHONE
    @synchronized(self) {
        id image = [self imageForURL:oldURL];
        if (image) {
            [_imageSortedList removeObject:oldKey];
            [_imageCache removeObjectForKey:oldKey];
            [_imageSortedList addObject:newKey];
            [_imageCache setObject:image forKey:newKey];
        }
    }
#endif
    NSString* oldPath = [self cachePathForKey:oldKey];
    NSFileManager* fm = [self fileManager];
    if ([fm fileExistsAtPath:oldPath]) {
        BOOL pinned = [self isFilePinned:oldPath];
        if (pinned) {
            [self unpinFile:oldPath];
        }
        NSString* newPath = [self cachePathForKey:newKey];
        if ([fm fileExistsAtPath:newPath]) {
            [self removeFile:newPath force:YES];
        }
        
        if ([fm moveItemAtPath:oldPath toPath:newPath error:nil]) {
            BMFileAttributes *attributes = [self cachedAttributesForFile:oldPath];
            [self setCachedAttributes:attributes forFile:newPath];
            
            if (pinned) {
                [self pinFile:newPath];
            }
        } else {
            if (pinned) {
                [self pinFile:oldPath];
            }
        }
    }
}

- (void)moveDataFromPath:(NSString*)path toURL:(NSString*)newURL {
    NSString* newKey = [self keyForURL:newURL];
    NSFileManager* fm = [self fileManager];
    if ([fm fileExistsAtPath:path]) {
        NSString* newPath = [self cachePathForKey:newKey];
        BOOL pinned = NO;
        if ([fm fileExistsAtPath:newPath]) {
            pinned = [self isFilePinned:newPath];
            [self removeFile:newPath force:YES];
        }
        if ([fm moveItemAtPath:path toPath:newPath error:nil]) {
            BMFileAttributes *attributes = [self cachedAttributesForFile:path];
            [self setCachedAttributes:attributes forFile:newPath];
        }
        if (pinned) {
            [self pinFile:newPath];
        }
    }
}

- (NSString*)moveDataFromPathToTemporaryURL:(NSString*)path {
    NSString* tempURL = [self createTemporaryURLForFile:path];
    [self moveDataFromPath:path toURL:tempURL];
    return tempURL;
}

- (void)removeURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
    if (URL) {
        NSString*  key = [self keyForURL:URL];
        [self removeKey:key fromDisk:fromDisk];
    }
}

- (void)removeKey:(NSString *)key fromDisk:(BOOL)fromDisk {
#if TARGET_OS_IPHONE
    @synchronized(self) {
        UIImage* image = [_imageCache objectForKey:key];
        if (image) {
            _totalPixelCount -= image.size.width * image.size.height;
            [_imageSortedList removeObject:key];
            [_imageCache removeObjectForKey:key];
        }
    }
#endif
    
    if (fromDisk) {
        NSString* filePath = [self cachePathForKey:key];
        [self removeFile:filePath];
    }
}

- (void)removeKey:(NSString*)key {
    [self removeKey:key fromDisk:YES];
}

- (void)removeAll:(BOOL)fromDisk {
    @synchronized(self) {
        [_fileAttributesCache clear];
        [_imageCache removeAllObjects];
        [_imageSortedList removeAllObjects];
        _totalPixelCount = 0;
    }
    
    if (fromDisk) {
        NSFileManager* fm = [self fileManager];
        
        NSArray *contents = [fm contentsOfDirectoryAtPath:_cachePath error:nil];
        
        for (NSString *fileName in contents) {
            [self unpinFile:[_cachePath stringByAppendingPathComponent:fileName]];
        }
        
        NSError *error = nil;

        if (![fm bmClearContentsOfDirectoryAtPath:_cachePath error:&error]) {
            LogDebug(@"Could not clear cache: %@", error);
        }
    }
}

- (void)invalidateURL:(NSString*)URL {
    NSString* key = [self keyForURL:URL];
    return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString*)key {
    NSString* filePath = [self cachePathForKey:key];
    [self invalidateFileAtPath:filePath];
}

- (void)invalidateAll {
    NSFileManager* fm = [self fileManager];
    NSString *cachePath = self.cachePath;
    NSDirectoryEnumerator* e = [fm enumeratorAtPath:cachePath];
    for (NSString* fileName; (fileName = [e nextObject]); ) {
        NSString* filePath = [cachePath stringByAppendingPathComponent:fileName];
        [self invalidateFileAtPath:filePath];
    }
}

#if TARGET_OS_IPHONE
- (void)logMemoryUsage {
    @synchronized(self) {
#if TTLOGLEVEL_INFO <= TTMAXLOGLEVEL
        NSLog(@"======= IMAGE CACHE: %tu images, %tu pixels ========", _imageCache.count, _totalPixelCount);
        NSEnumerator* e = [_imageCache keyEnumerator];
        for (NSString* key ; (key = [e nextObject]); ) {
            UIImage* image = [_imageCache objectForKey:key];
            NSLog(@"  %f x %f %@", image.size.width, image.size.height, key);
        }
#endif
    }
}
#endif


#pragma mark - BMURLCache public methods


- (void)pinDataForURL:(NSString*)URL {
    [self pinDataForKey:[self keyForURL:URL]];
}

- (void)pinDataForKey:(NSString*)key {
    NSString* filePath = [self cachePathForKey:key];
    [self pinFile:filePath];
}

- (void)unpinDataForURL:(NSString*)URL {
    [self unpinDataForKey:[self keyForURL:URL]];
}

- (void)unpinDataForKey:(NSString*)key {
    NSString* filePath = [self cachePathForKey:key];
    [self unpinFile:filePath];
}

- (BOOL)isFilePinned:(NSString *)filePath {
    BMFileAttributes *attributes = [self fileAttributesForFile:filePath];
    return attributes.pinned;
}

- (BOOL)isDataPinnedForKey:(NSString *)key {
    NSString* filePath = [self cachePathForKey:key];
    return [self isFilePinned:filePath];
}

- (BOOL)isDataPinnedForURL:(NSString *)URL {
    return [self isDataPinnedForKey:[self keyForURL:URL]];
}

#if TARGET_OS_IPHONE

- (void)storeImage:(UIImage*)image forURL:(NSString*)URL toDisk:(BOOL)toDisk {
    NSString *key = [self keyForURL:URL];
    [self storeImage:image forKey:key toDisk:toDisk];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk {
    if (image) {
        [self storeImage:image forKey:key force:NO];
        if (toDisk && image) {
            NSData* data = UIImagePNGRepresentation(image);
            if (data) {
                [self storeData:data forKey:key];
            }
        }
    } else {
        [self removeKey:key fromDisk:toDisk];
    }
}

#endif

//Start added by W. Altewischer
- (void)ignoreAllOnce {
    NSFileManager* fm = [self fileManager];
    NSDirectoryEnumerator* e = [fm enumeratorAtPath:_cachePath];
    for (NSString* fileName; (fileName = [e nextObject]); ) {
        NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
        [self setIgnoredPath:filePath];
    }
}

- (void)ignoreURLOnce:(NSString *)url {
    [self ignoreKeyOnce:[self keyForURL:url]];
}

- (void)ignoreKeyOnce:(NSString *)key {
    NSString* filePath = [self cachePathForKey:key];
    NSFileManager* fm = [self fileManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
        [self setIgnoredPath:filePath];
    }
}

- (NSString*)storeTemporaryFile:(NSURL*)fileURL copy:(BOOL)copy {
    if ([fileURL isFileURL]) {
        NSString* filePath = [fileURL path];
        NSFileManager* fm = [self fileManager];
        if ([fm fileExistsAtPath:filePath]) {
            NSString* tempURL = nil;
            NSString* newPath = nil;
            do {
                tempURL = [self createTemporaryURLForFile:filePath];
                newPath = [self cachePathForURL:tempURL];
            } while ([fm fileExistsAtPath:newPath]);
            
            BOOL success = NO;
            if (copy) {
                success = [fm copyItemAtPath:filePath toPath:newPath error:nil];
            } else {
                success = [fm moveItemAtPath:filePath toPath:newPath error:nil];
            }
            if (success) {
                return tempURL;
            }
        }
    }
    return nil;
}

- (NSString *)uniqueLocalURL {
    return [self uniqueLocalURLWithExtension:nil];
}

- (NSString *)uniqueLocalURLWithExtension:(NSString *)extension {
    if ([BMStringHelper isEmpty:extension]) {
        return [self.localURLPrefix stringByAppendingString:[BMStringHelper stringWithUUID]];
    } else {
        NSString *prefix = self.localURLPrefix;
        NSString *guid = [BMStringHelper stringWithUUID];
        NSMutableString *ret = [[NSMutableString alloc] initWithCapacity:prefix.length + guid.length + extension.length + 1];
        [ret appendString:prefix];
        [ret appendString:guid];
        [ret appendString:@"."];
        [ret appendString:extension];
        return ret;
    }
    
}

- (BOOL)isLocalURL:(NSString *)url {
    return [url hasPrefix:self.localURLPrefix];
}

@end

@implementation BMURLCache(Private)

+ (NSString*)cachePathWithName:(NSString*)name persistent:(BOOL)persistent {
    //Use the documents directory because the data may need to be backed up and iOS doesn't back up the Caches directory.
    NSString *cachesPath = nil;
    if (persistent) {
        cachesPath = [BMFileHelper documentsDirectory];
    } else {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachesPath = [paths objectAtIndex:0];
    }
    NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
    NSString* etagCachePath = [cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachesPath]) {
        [fm createDirectoryAtPath:cachesPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fm fileExistsAtPath:cachePath]) {
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![fm fileExistsAtPath:etagCachePath]) {
        [fm createDirectoryAtPath:etagCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}

+ (NSString*)doubleImageURLPath:(NSString*)urlPath {
    if ([[urlPath substringToIndex:1] isEqualToString:@"."]) {
        return urlPath;
    }
    
    // We'd ideally use stringByAppendingPathExtension: in this method, but it seems
    // to wreck bundle:// urls by replacing them with bundle:/ prefixes. Strange.
    NSString* pathExtension = [urlPath pathExtension];
    
    NSString* urlPathWithNoExtension = [urlPath substringToIndex:
                                        [urlPath length] - [pathExtension length]
                                        - (([pathExtension length] > 0) ? 1 : 0)];
    
    urlPath = [urlPathWithNoExtension stringByAppendingString:@"@2x"];
    
    if ([pathExtension length] > 0) {
        urlPath = [urlPath stringByAppendingFormat:@".%@", pathExtension];
    }
    
    return urlPath;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)setValue:(id)value forAttribute:(id)attribute forFile:(NSString *)filePath {
    NSFileManager* fm = [self fileManager];
    NSError *error = nil;
    if (![fm setAttributes:[NSDictionary dictionaryWithObject:value forKey:attribute] ofItemAtPath:filePath error:&error]) {
        LogDebug(@"Could not set attribute: %@", error);
    }
}

- (void)invalidateFileAtPath:(NSString *)filePath {
    if (filePath) {
        BMFileAttributes *cachedAttributes = [self cachedAttributesForFile:filePath];
        
        if (cachedAttributes) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(cachedAttributes.expirationTimeInterval + 1)];
            cachedAttributes.modificationDate = date;
            [self setValue:date forAttribute:NSFileModificationDate forFile:filePath];
        }
    }
}

- (void)unpinFile:(NSString *)filePath {
    if (filePath) {
        [self setValue:[NSNumber numberWithBool:NO] forAttribute:FILE_PIN_ATTRIBUTE forFile:filePath];
        BMFileAttributes *cachedAttribute = [self cachedAttributesForFile:filePath];
        cachedAttribute.pinned = NO;
    }
}

- (void)pinFile:(NSString *)filePath {
    if (filePath) {
        [self setValue:[NSNumber numberWithBool:YES] forAttribute:FILE_PIN_ATTRIBUTE forFile:filePath];
        BMFileAttributes *cachedAttribute = [self cachedAttributesForFile:filePath];
        cachedAttribute.pinned = YES;
    }
}

- (BOOL)removeFile:(NSString *)filePath force:(BOOL)force {
    BOOL removed = NO;
    if (filePath) {
        NSFileManager* fm = [self fileManager];
        
        if (force) {
            [self unpinFile:filePath];
        }
        NSError *error = nil;
        removed = [fm removeItemAtPath:filePath error:&error];
        if (!removed) {
            LogDebug(@"Could not remove item from cache: %@", error);
        } else {
            [self setCachedAttributes:nil forFile:filePath];
        }
    }
    return removed;
}

- (BOOL)removeFile:(NSString *)filePath {
    return [self removeFile:filePath force:YES];
}

- (void)expireFilesFromDisk {
    [self expireFilesFromDiskWithCompletion:nil];
}

- (void)expireFilesFromDiskWithCompletion:(void (^)(void))completion {
    
    if (!_expiringFilesFromDisk) {
        _expiringFilesFromDisk = YES;
        [self bmPerformBlockInBackground:^id {

            NSString *const cachePath = self.cachePath;
            const long long maxTotalFileSize = (long long) self.maxDiskSpace;
            NSDate *lastDate = nil;
            NSFileManager *fm = [self fileManager];
            NSDirectoryEnumerator *e = [fm enumeratorAtPath:cachePath];

            long long totalFileSize = 0;

            NSMutableArray *files = [NSMutableArray new];

            for (NSString *fileName; (fileName = [e nextObject]);) {
                NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
                BMFileAttributes *attrs = [self fileAttributesForFile:filePath];

                if (attrs) {
                    NSDate *modified = attrs.modificationDate;

                    if (lastDate == nil || [modified compare:lastDate] == NSOrderedDescending) {
                        lastDate = modified;
                    }

                    BOOL pinned = attrs.pinned;
                    if (!pinned && modified) {
                        if ([attrs isExpired]) {
                            [self removeFile:filePath force:NO];
                        } else if (maxTotalFileSize > 0) {
                            long long fileSize = attrs.fileSize;
                            if (fileSize > 0) {
                                totalFileSize += fileSize;
                                [files addObject:attrs];
                            }
                        }
                    }
                }
            }

            if (maxTotalFileSize > 0 && maxTotalFileSize < totalFileSize) {
                [files sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]]];

                for (BMFileAttributes *fd in files) {
                    if ([self removeFile:fd.filePath force:NO]) {
                        totalFileSize -= fd.fileSize;
                    }
                    if (maxTotalFileSize >= totalFileSize) {
                        break;
                    }
                }
            }
            return lastDate;
        }                 withCompletion:^(NSDate *lastDate) {
            if (self.lastWriteDate == nil) {
                self.lastWriteDate = lastDate;
            }
            _expiringFilesFromDisk = NO;
            if (completion) {
                completion();
            }
        }];
    }
}

- (BOOL)hasDataForKey:(NSString *)key filePath:(NSString **)fp {
    if (!self.isDiskCacheEnabled) {
        return NO;
    }
    
    NSString* filePath = [self cachePathForKey:key];
    if (fp) {
        *fp = filePath;
    }
    
    BOOL ret = NO;
    
    BMFileAttributes *attributes = [self fileAttributesForFile:filePath];
    if (attributes) {
        ret = ![attributes isExpired];
    }
    return ret;
}

#if TARGET_OS_IPHONE

- (void)expireImagesFromMemory {
    @synchronized(self) {
        while (_imageSortedList.count) {
            NSString* key = [_imageSortedList objectAtIndex:0];
            UIImage* image = [_imageCache objectForKey:key];
            // TTDINFO(@"EXPIRING %@", key);
            
            _totalPixelCount -= image.size.width * image.size.height;
            [_imageCache removeObjectForKey:key];
            [_imageSortedList removeObjectAtIndex:0];
            
            if (_totalPixelCount <= _maxPixelCount) {
                break;
            }
        }
    }
}

- (void)storeImage:(UIImage*)image forKey:(NSString*)key force:(BOOL)force {
    @synchronized(self) {
        if (key && (force || self.isImageCacheEnabled)) {
            if (image) {
                NSUInteger pixelCount = image.size.width * image.size.height;
                NSUInteger pixelLimit = self.maxSingleImagePixelCount;
                if (force || pixelLimit == 0 || pixelCount < pixelLimit) {
                    _totalPixelCount += pixelCount;
                    if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
                        [self expireImagesFromMemory];
                    }
                    
                    if (!_imageCache) {
                        _imageCache = [[NSMutableDictionary alloc] init];
                    }
                    if (!_imageSortedList) {
                        _imageSortedList = [[NSMutableArray alloc] init];
                    }
                    
                    [_imageSortedList addObject:key];
                    [_imageCache setObject:image forKey:key];
                }
            } else {
                [self removeKey:key fromDisk:NO];
            }
        }
    }
    
}

- (UIImage*)loadImageFromBundle:(NSString*)URL {
    NSString* path = BMPathForBundleResource([URL substringFromIndex:9]);
    NSData* data = [NSData dataWithContentsOfFile:path];
    return [UIImage bmImageWithData:data];
}

- (UIImage*)loadImageFromDocuments:(NSString*)URL {
    NSString* path = BMPathForDocumentsResource([URL substringFromIndex:12]);
    NSData* data = [NSData dataWithContentsOfFile:path];
    return [UIImage bmImageWithData:data];
}


#endif

- (NSString *)localURLPrefix {
    NSURL *url = [NSURL fileURLWithPath:_cachePath isDirectory:YES];
    return [url absoluteString];
}

- (NSString*)createTemporaryURLForFile:(NSString *)file {
    NSString *extension = [file pathExtension];
    return [self uniqueLocalURLWithExtension:extension];
}

- (NSString*)createTemporaryURL {
    return [self createTemporaryURLForFile:nil];
}

- (NSString *)ignoredPathForPath:(NSString *)path {
    return [path stringByAppendingString:IGNORE_EXTENSION];
}

- (NSString *)pathForIgnoredPath:(NSString *)path {
    NSString *extension = IGNORE_EXTENSION;
    return [path substringToIndex:path.length - extension.length];
}

- (BOOL)isIgnoredPath:(NSString *)path {
    NSString *extension = IGNORE_EXTENSION;
    NSInteger startIndex = path.length - extension.length;
    return startIndex >= 0 && [extension isEqual:[path substringFromIndex:startIndex]];
}

- (void)resetIgnoredPath:(NSString *)path {
    if ([self isIgnoredPath:path]) {
        BOOL pinned = [self isFilePinned:path];
        if (pinned) {
            [self unpinFile:path];
        }
        NSString *newPath = [self pathForIgnoredPath:path];
        NSFileManager* fm = [self fileManager];
        
        if ([fm moveItemAtPath:path toPath:newPath error:nil]) {
            BMFileAttributes *fileAttributes = [_fileAttributesCache objectForKey:path];
            if (fileAttributes) {
                [self setCachedAttributes:fileAttributes forFile:newPath];
            }
        } else {
            newPath = path;
        }
        if (pinned) {
            [self pinFile:newPath];
        }
    }
}

- (void)setIgnoredPath:(NSString *)path {
    if (![self isIgnoredPath:path]) {
        BOOL pinned = [self isFilePinned:path];
        if (pinned) {
            [self unpinFile:path];
        }
        
        NSString *newPath = [self ignoredPathForPath:path];
        NSFileManager* fm = [self fileManager];
        if ([fm moveItemAtPath:path toPath:newPath error:nil]) {
            BMFileAttributes *fileAttributes = [_fileAttributesCache objectForKey:path];
            if (fileAttributes) {
                [self setCachedAttributes:fileAttributes forFile:newPath];
            }
        } else {
            newPath = path;
        }
        if (pinned) {
            [self pinFile:newPath];
        }
    }
}

- (NSString*)loadEtagFromCacheWithKey:(NSString*)key {
    NSString* path = [self etagCachePathForKey:key];
    NSData* data = [NSData dataWithContentsOfFile:path];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)imageExistsFromBundle:(NSString*)URL {
    NSString* path = BMPathForBundleResource([URL substringFromIndex:9]);
    NSFileManager* fm = [self fileManager];
    return [fm fileExistsAtPath:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)imageExistsFromDocuments:(NSString*)URL {
    NSString* path = BMPathForDocumentsResource([URL substringFromIndex:12]);
    NSFileManager* fm = [self fileManager];
    return [fm fileExistsAtPath:path];
}

- (NSFileManager *)fileManager {
    @synchronized(self) {
        if (_fileManager == nil) {
            _fileManager = [[NSFileManager alloc] init];
        }
        return _fileManager;
    }
}

@end
