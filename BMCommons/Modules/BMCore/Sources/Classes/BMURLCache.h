//
//  BMURLCache.h
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2012 BehindMedia. All rights reserved.
//
#import <BMCommons/BMCoreObject.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import <BMCommons/BMFileAttributes.h>

typedef NS_ENUM(NSUInteger, BMURLCacheState) {
    BMURLCacheStateNone = 0,
    BMURLCacheStateDisk = 1,
    BMURLCacheStateMemory = 2
};

NS_ASSUME_NONNULL_BEGIN

/**
 Local Cache for storing remote images/files. 
 
 This is both an in-memory cache and a disk cache. The in-memory cache contains images upto a specified amount of pixels to store.
 The diskcache is also configurable with max space and a time to live (invalidationAge).
 */
@interface BMURLCache : BMCoreObject 

@property (readonly, getter = isPersistent) BOOL persistent;

/**
 The max disk space in bytes for the disk cache.
 
 Oldest files are removed automatically if the disk cache reaches this threshold.
 */
@property (assign) NSUInteger maxDiskSpace;

/**
 * Disables the disk cache. 
 
 Disables etag support as well.
 */
@property (getter = isDiskCacheEnabled) BOOL diskCacheEnabled;

/**
 * Disables the in-memory cache for images.
 */
@property(getter = isImageCacheEnabled) BOOL imageCacheEnabled;

/**
 The name of the cache.
 */
@property (readonly) NSString *name;

/**
 * The path to the directory of the disk cache.
 */
@property(copy, readonly) NSString* cachePath;

/**
 * Gets the path to the directory of the disk cache for etags.
 */
@property (strong, readonly) NSString* etagCachePath;


/**
 * The maximum number of pixels to keep in memory for cached images.
 *
 * Setting this to zero will allow an unlimited number of images to be cached.  The default
 * is zero.
 */
@property(assign) NSUInteger maxPixelCount;

/**
 The maximum number of pixels for a single image to allow it to be cached.
 
 Setting this to zero will allow any image to be stored in the cache.
 The default is zero.
 */
@property(assign) NSUInteger maxSingleImagePixelCount;

/**
 * The amount of time after which items in the cache are considered invalid.
 
 Default is BM_DEFAULT_CACHE_INVALIDATION_AGE
 */
@property(assign) NSTimeInterval invalidationAge;

/**
 A cache is by default active which means a timer is there to automatically cleanup files, etc.
 
 You may set active to false on deactivation of the app and reactivate the cache upon activation.
 Whenever the timer is set to active an immediate run is done to revalidate the files on disk for timeout, etc.
 */
@property(assign, getter=isActive) BOOL active;

/**
 Date the last time a data entry was stored to disk in this cache.
 */
@property(strong, readonly) NSDate *lastWriteDate;

/**
 * Gets a non persistent shared cache identified with a unique name.
 */
+ (BMURLCache *)cacheWithName:(NSString*)name;

/**
 * Gets a shared cache identified with a unique name.
 
 @param name The name of the cache
 @param persistent Whether or not the data should be persistent, i.e. should reside in the documents directory instead of in the caches directory.
 */
+ (BMURLCache*)cacheWithName:(NSString*)name persistent:(BOOL)persistent;

/**
 * Gets the shared cache singleton used across the application.
 */
+ (BMURLCache *)sharedCache;

/**
 * Sets the shared cache singleton used across the application.
 */
+ (void)setSharedCache:(BMURLCache *)cache;

/**
 Returns all BMURLCaches that are present.
 */
+ (NSArray *)allCaches;

+ (void)setGlobalDiskCacheEnabled:(BOOL)enabled;
+ (BOOL)isGlobalDiskCacheEnabled;

+ (void)setGlobalImageCacheEnabled:(BOOL)enabled;
+ (BOOL)isGlobalImageCacheEnabled;

/**
 Initializes a cache with the specified name.
 
 @param name The name of the cache
 @param persistent Whether or not the data should be persistent, i.e. should reside in the documents directory instead of in the caches directory.
 */
- (nullable id)initWithName:(NSString*)name persistent:(BOOL)persistent NS_DESIGNATED_INITIALIZER;


/**
 * Initializes a non-persistent cache with the specified name
 */
- (nullable id)initWithName:(NSString*)name;

/**
 * Gets the key that would be used to cache a URL response.
 */
- (NSString *)keyForURL:(NSString*)URL;

/**
 * Gets the path in the cache where a URL may be stored.
 */
- (NSString*)cachePathForURL:(NSString*)URL;

/**
 * Gets the path in the cache where a key may be stored.
 */
- (NSString*)cachePathForKey:(NSString*)key;


/**
 * Etag cache files are stored in the following way:
 * File name: <key>
 * File data: <etag value>
 *
 * @return The etag cache path for the given key.
 */
- (NSString*)etagCachePathForKey:(NSString*)key;


/**
 * Determines if there is a cache entry for a URL.
 */
- (BOOL)hasDataForURL:(NSString*)URL;

/**
 * Determines if there is a cache entry for a key.
 */
- (BOOL)hasDataForKey:(NSString*)key;


#if TARGET_OS_IPHONE

/**
 * Determines if there is an image cache entry for a URL.
 */
- (BOOL)hasImageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk;

- (BOOL)hasImageForKey:(NSString*)key fromDisk:(BOOL)fromDisk;

- (BMURLCacheState)cacheStateForKey:(NSString *)key;

/**
 * Returns the current cache state for the specified URL.
 */
- (BMURLCacheState)cacheStateForURL:(NSString *)URL;

#endif

/**
 * Gets the data for a URL from the cache if it exists.
 *
 * @return nil if the URL is not cached.
 */
- (nullable NSData*)dataForURL:(NSString*)URL;

/**
 Returns the data for the specified key or nil if not found.
 */
- (nullable NSData *)dataForKey:(NSString *)key;

/**
 Returns the file attributes for the cached entity for the specified URL.
 
 If not entry exists on disk for the specified URL, this method returns nil.
 */
- (nullable BMFileAttributes *)fileAttributesForURL:(NSString *)URL;

/**
 Returns the file attributes for the cached entity for the specified key.
 
 If not entry exists on disk for the specified key, this method returns nil.
 */
- (nullable BMFileAttributes *)fileAttributesForKey:(NSString *)key;


#if TARGET_OS_IPHONE

/**
 * Gets an image from the in-memory image cache.
 
 * If not found in the memory cache the disk cache is consulted for data for the specified URL and an image is constructed with the data (of course only if the data is image data).
 *
 * @return nil if the URL is not cached.
 */
- (nullable id)imageForURL:(NSString*)URL;

/**
 * Gets an image from the in-memory image cache.
 
 * If not found in the memory cache and fromDisk is true the disk cache is consulted for data for the specified URL and an image is constructed with the data.
 *
 * @return nil if the URL is not cached.
 */
- (nullable id)imageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk;

- (nullable UIImage *)imageForKey:(NSString*)key;

- (nullable UIImage *)imageForKey:(NSString*)key fromDisk:(BOOL)fromDisk;

#endif

/**
 * Get an etag value for a given cache key.
 */
- (nullable NSString*)etagForKey:(NSString*)key;

/**
 * Stores data in the disk cache.
 */
- (void)storeData:(NSData*)data forURL:(NSString*)URL;

/**
 * Stores data in the disk cache.
 */
- (void)storeData:(NSData*)data forKey:(NSString*)key;

/**
 * Stores data in the disk cache by specying a custom invalidation age.
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key invalidationAge:(NSTimeInterval)invalidationAge;

/**
 * Stores data in the disk cache by specying a custom invalidation age.
 */
- (void)storeData:(NSData *)data forURL:(NSString*)URL invalidationAge:(NSTimeInterval)invalidationAge;


#if TARGET_OS_IPHONE

/**
 * Stores an image in the memory cache.
 */
- (void)storeImage:(UIImage*)image forURL:(NSString*)URL;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

#endif


/**
 * Stores an etag value in the etag cache.
 */
- (void)storeEtag:(NSString*)etag forKey:(NSString*)key;

#if TARGET_OS_IPHONE

/**
 * Convenient way to create a temporary URL for some data and cache it in memory.
 *
 * @return The temporary URL
 */
- (NSString*)storeTemporaryImage:(UIImage*)image toDisk:(BOOL)toDisk;

#endif

/**
 * Convenient way to create a temporary URL for some data and cache in on disk.
 *
 * @return The temporary URL
 */
- (NSString*)storeTemporaryData:(NSData*)data;

/**
 * Convenient way to create a temporary URL for a file and move it to the disk cache.
 *
 * @return The temporary URL
 */
- (nullable NSString*)storeTemporaryFile:(NSURL*)fileURL;

/**
 * Moves the data currently stored under one URL to another URL.
 *
 * This is handy when you are caching data at a temporary URL while the permanent URL is being
 * retrieved from a server.  Once you know the permanent URL you can use this to move the data.
 *
 * @return true if successful, false otherwise
 */
- (BOOL)moveDataForURL:(NSString*)oldURL toURL:(NSString*)newURL;

/**
 * Moves the data from the specified path to this cache with as key the specified URL.
 *
 * @return true if successful, false otherwise
 */
- (BOOL)moveDataFromPath:(NSString*)path toURL:(NSString*)newURL;

/**
 * Moves the data from the specified path to this cache and generates a new temporary URL for it.
 
 @return The newly generated temporary URL.
 */
- (nullable NSString*)moveDataFromPathToTemporaryURL:(NSString*)path;

/**
 * Removes the data for a URL from the memory cache and optionally from the disk cache.
 */
- (void)removeURL:(NSString*)URL fromDisk:(BOOL)fromDisk;

/**
 * Removes the data for a key from the disk cache.
 */
- (void)removeKey:(NSString*)key;

- (void)removeKey:(NSString *)key fromDisk:(BOOL)fromDisk;

/**
 * Erases the memory cache and optionally the disk cache. 
 
@warning Setting fromDisk to true will also remove pinned data!
 */
- (void)removeAll:(BOOL)fromDisk;

/**
 * Invalidates the file in the disk cache.
 *
 * This ensures that the next time the URL is requested from the cache it will be loaded
 * from the network.
 */
- (void)invalidateURL:(NSString*)URL;

/**
 * Invalidates a file from the disk cache by key.
 */
- (void)invalidateKey:(NSString*)key;

/**
 * Invalidates all files in the disk cache according to rules explained in invalidateURL:.
 */
- (void)invalidateAll;

#if TARGET_OS_IPHONE

/**
 * Logs the memory in use by the cache.
 */
- (void)logMemoryUsage;

#endif

/**
 * Pins data for the specified URL. 
 
 The data is protected from deletion until unpin is called.
 */
- (void)pinDataForURL:(NSString*)URL;

/**
 * Pins data for the specified key. 
 
 The data is protected from deletion until unpin is called.
 */
- (void)pinDataForKey:(NSString*)key;

/**
 * Unpins data for the specified URL. 
 
 The data is not protected anymore from deletion.
 */
- (void)unpinDataForURL:(NSString*)URL;

/**
 * Unpins data for the specified key. 
 
 The data is not protected anymore from deletion.
 */
- (void)unpinDataForKey:(NSString*)key;

/**
 Checks whether data is pinned for the specified key.
 */
- (BOOL)isDataPinnedForKey:(NSString *)key;

/**
 Checks whether data is pinned for the specified URL.
 */
- (BOOL)isDataPinnedForURL:(NSString *)URL;

/**
 Checks whether the file at the specified filePath is pinned or not.
 */
- (BOOL)isFilePinned:(NSString *)filePath;

#if TARGET_OS_IPHONE

/**
 * Stores an image in the memory cache and optionally in the disk cache too (using PNG representation).
 *
 * @param image The image to store
 * @param URL The URL to use as key
 * @param toDisk Whether to store the image data in the disk cache as well
 */
- (void)storeImage:(UIImage*)image forURL:(NSString*)URL toDisk:(BOOL)toDisk;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;

#endif

/**
 * Ignores all cached results on disk exactly once (to allow for refresh but maintain the data on disk).
 
 * After one of the load methods is called for the cached result, the ignore status is reset. This way you can force a round trip to the server to check for a new version, but maintain the old data in case of an error.
 */
- (void)ignoreAllOnce;

/**
 Ignores the specified URL once.
 
 @see ignoreAllOnce
 */
- (void)ignoreURLOnce:(NSString *)url;

/**
 Ignores the specified key once.
 
 @see ignoreAllOnce
 */
- (void)ignoreKeyOnce:(NSString *)key;

/**
 Stores a temporary file in this cache. 
 
 @param fileURL The source file. Should be a file URL otherwise it is ignored and nil is returned.
 @param copy Whether the source file should be copied or moved
 @return The url created for the file or nil in case the operation was not successful.
 */
- (nullable NSString*)storeTemporaryFile:(NSURL*)fileURL copy:(BOOL)copy;

/**
 Returns a unique local URL for this cache.
 */
- (NSString *)uniqueLocalURL;

/**
 Returns a unique local URL for this cache with the specified file extension.
 */
- (NSString *)uniqueLocalURLWithExtension:(NSString *)extension;

/**
 Checks whether the supplied url is a url local to this cache.
 */
- (BOOL)isLocalURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
