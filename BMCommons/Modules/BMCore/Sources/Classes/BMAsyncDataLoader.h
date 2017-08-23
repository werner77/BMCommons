//
//  BMAsyncDataLoader.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

#define BM_ASYNCDATALOADER_DEFAULT_MAX_RETRY_COUNT 2
#define BM_ASYNCDATALOADER_DEFAULT_MAX_CONNECTIONS 3
#define BM_ASYNCDATALOADER_DEFAULT_CONNECTION_TIMEOUT 20.0

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMAsyncLoadingStatus) {
    BMAsyncLoadingStatusIdle = 0,
    BMAsyncLoadingStatusQueued = 1,
    BMAsyncLoadingStatusLoading = 2,
    BMAsyncLoadingStatusLoadingFromCache = 3,
};

typedef NS_ENUM(NSUInteger, BMAsyncDataLoaderCacheState) {
    BMAsyncDataLoaderCacheStateNone = 0,
    BMAsyncDataLoaderCacheStateMemory = 1,
    BMAsyncDataLoaderCacheStateDisk = 2,
};

@class BMAsyncDataLoader;
@class BMURLCache;

/**
 Delegate protocol for BMAsyncDataLoader.
 */
@protocol BMAsyncDataLoaderDelegate<NSObject>

/**
 Callback sent on completion.
 
 If error == nil the loading was successful and the [BMAsyncDataLoader object] property contains the data (or converted data) loaded.
 */
- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(nullable NSError *)error;

@optional

/**
 Callback sent when the loader will actually start loading (is dequeued from the waiting queue).
 */
- (void)asyncDataLoaderDidStartLoading:(BMAsyncDataLoader *)dataLoader;

/**
 Callback sent when the loader has cancelled loading.
 
 Called whenever cancelLoading is called when the data loader was not idle.
 */
- (void)asyncDataLoaderDidCancelLoading:(BMAsyncDataLoader *)dataLoader;

/**
 To be implemented by delegates if the data should not be buffered in memory (because it is too large, e.g. videos).
 
 In that case the delegate should return NO. The delegate is then responsible for handling/appending the data.
 
 This method may be called from a background thread!
 */
- (BOOL)asyncDataLoader:(BMAsyncDataLoader *)dataLoader shouldAppendData:(NSData *)data;

@end

/**
 Class to schedule/perform asynchronous loading of remote objects by retrieving the data by URL using HTTP GET.
 
 The class ensures that if multiple loaders are scheduled for the same object, only one is performed but the delegate messages are delivered to all.
 The number of maximum concurrent connections in use is configurable and by default 3.
 Retries are performed automatically in the case of errors up to the max retry count which is 2 by default.
 The default connection timeout is 20 seconds.
 The default implementation of the object property method is to return a NSData object containing the bytes loaded, but subclasses may override to return a more meaningful object (such as an image).
 */
@interface BMAsyncDataLoader : BMCoreObject

/**
 Returns the BMAsyncLoadingStatus which is idle = 0, queued = 1 and loading = 2.
 
 The loader moves from state idle to either loading or queued after startLoading has been called. From queued the status will move to loading if a slot becomes available.
 After loading returned successfully or erroneously the status moves back to idle.
 */
@property(readonly) BMAsyncLoadingStatus loadingStatus;

/**
 Upon successful load this property contains the object loaded.
 */
@property(strong, nullable, readonly) NSObject *object;

/**
 Optional object to attach to the loader which can be used to track the loader or to use upon successful load.
 */
@property(strong, nullable) id context;

/**
 The url to load the data from.
 */
@property(strong, readonly) NSURL *url;

@property(strong, readonly) NSString *urlString;

/**
 The mime type of the returned data or nil if it could not be determined
 */
@property (readonly, nullable) NSString *mimeType;

/**
 The number of retries after an error. Default is DEFAULT_MAX_RETRY_COUNT.
 */
@property(assign) NSUInteger maxRetryCount;

/**
 The number of seconds to use as a timeout for the connection. Default is DEFAULT_CONNECTION_TIMEOUT.
 */
@property(assign) NSTimeInterval connectionTimeOut;

/**
 Whether to ignore the BMURLCache for loading. The method cachedObject will be bypassed.
 */
@property(assign) BOOL ignoreCache;

/**
 Whether to store the loaded data in the cache. Default is true.
 */
@property(assign) BOOL storeToCache;

/**
 Whether to continue loading with servers that present an untrusted certificate.
 */
@property(assign) BOOL shouldAllowSelfSignedCert;

/**
 Whether to load with priority: put the loader first in the queue. Default is last.
 */
@property(readonly, getter=isPriority) BOOL priority;

/**
 The delegate for receiving callbacks.
 
 @see BMAsyncDataLoaderDelegate
 */
@property(weak, nullable) id <BMAsyncDataLoaderDelegate> delegate;

/**
 Whether the delegate is always notified asynchronously of a successful or failed load, even if the object is retrieved from the cache.
 
 Defaults to NO.
 */
@property(assign) BOOL alwaysNotifyAsynchronously;

/**
 The cache to use for loading.
 
 If this property is nil the defaultCache is used which is set on class level.
 */
@property(strong, nullable) BMURLCache *cache;

/**
 Returns the default cache that is used to cache images.
 
 By default the [BMURLCache sharedCache] is used. May be overridden by setting a cache on instance level via the cache property.
 */
+ (BMURLCache *)defaultCache;

/**
 The default cache that should be used.
 */
+ (void)setDefaultCache:(nullable BMURLCache *)cache;

/**
 The max number of concurrent connections to use.
 */
+ (void)setMaxConnections:(NSUInteger)maxConnections;
+ (NSUInteger)maxConnections;

/**
 Init with URL
 */
- (id)initWithURL:(NSURL *)theURL;
- (nullable id)initWithURLString:(NSString *)theURLString;

/**
 The plain data that was received.
 */
- (NSData *)receivedData;

/**
 Starts loading the data.
 
 The loader will be queued in case more than the maxConnections are already open concurrently.
 
 @param priority Whether to put the loader first in the queue or last
 */
- (BMAsyncLoadingStatus)startLoadingWithPriority:(BOOL)priority;

/**
 Starts loading with no priority.
 */
- (BMAsyncLoadingStatus)startLoading;

/**
 Cancels current request or removes the loader from the queue if not currently active.
 */
- (void)cancelLoading;

/**
 Method that returns the cached object for the URL specified.
 */
- (nullable NSObject *)cachedObject;

/**
 Whether the object for the specified URL is on disk, in memory or not cached at all.
 */
- (BMAsyncDataLoaderCacheState)cacheState;

@end

@interface BMAsyncDataLoader(Protected)

/**
 * Sets the object associated with the data loader.
 *
 * @param object The object
 */
- (void)setObject:(nullable id)object;

/**
 Validates the url.
 
 Validation is done when startLoading is called.
 
 @return True if valid, false otherwise
 */
- (BOOL)validateURL:(NSURL *)url;

/**
 Override to perfom some custom setup for the URL request to use for loading.
 */
- (NSMutableURLRequest *)requestForURL:(NSURL *)theURL;

/**
 By default returns true if and only if HTTP_OK (200) is returned as status from the response.
 
 Override to do something different.
 */
- (BOOL)isSuccessfulResponse:(NSURLResponse *)response;

/**
 The cache which is in effect, which follows from the property cache on instance level and defaultCache on class level.
 */
- (BMURLCache *)effectiveCache;

/**
 Method to be implemented by subclasses to convert the data to an object
 
 The cache may be used to save data in at that moment with the specified key.
 
 Should be thread safe.
 */
- (NSObject *)objectFromData:(NSData *)data withCache:(nullable BMURLCache *)cache cacheKey:(nullable NSString *)cacheKey;

@end

NS_ASSUME_NONNULL_END
