/*
 *  BMService.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 15/10/10.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol BMServiceDelegate;

@protocol BMService<NSObject>

/**
 Delegate of the service
 */
@property(nullable, weak) id<BMServiceDelegate> delegate;

#if TARGET_OS_IPHONE
/**
 Identifier for the background task when the service is executed in the background.
 */
@property(assign) UIBackgroundTaskIdentifier bgTaskIdentifier;
#endif

/**
 A context object which can be used when the service completed or failed
 */
@property(nullable, strong) id context;

/**
 * Whether the service is executing in the foreground (user views progress) or hidden in the background. 
 
 Default should be NO (foreground).
 */
@property(assign, getter = isBackgroundService) BOOL backgroundService;

/**
 * Whether the service supports transitioning to a background service. 
 
 This means the method sendToBackground will be supported.
 
 Default should be NO.
 */
@property(assign, getter = isSendToBackgroundSupported) BOOL sendToBackgroundSupported;

/**
 * Whether the user is allowed to cancel the service or not. 
 
 Default should be YES.
 */
@property(assign, getter = isUserCancellable) BOOL userCancellable;

/**
* If an error is handled this boolean can be set to signal to delegates later in the chain that they don't need to take action.
*/
@property(assign, getter = isErrorHandled) BOOL errorHandled;

/**
 Returns true iff the cancel method was called. 
 
 Is reset after calling execute.
 */
@property(assign, readonly, getter = isCancelled) BOOL cancelled;

/**
 Returns true iff the service is not executing and either serviceSucceededWithSuccess or serviceFailedWithError are called.
*/
@property(assign, readonly, getter = isFinished) BOOL finished;

/**
 Returns true iff the service has started and has not been cancelled or succeededWithResult or failedWithError.
 */
@property(assign, readonly, getter = isExecuting) BOOL executing;

/**
 If set this transformer is used to process and transform the result. 
 
 This is done after retrieving the original response value from the cache (if applicable). This can be used to perform local data processing, e.g. with core data.
 */
@property(nullable, strong) NSValueTransformer *resultTransformer;

/**
 If set this transformer is used to transform the NSError object returned by the service before supplying it to the delegates.
 */
@property(nullable, strong) NSValueTransformer *errorTransformer;

/**
 Default message to show when loading.
 */
@property(nullable, strong) NSString *loadingMessage;

/**
 * Executes the service. 
 
 Callbacks will be delivered to the delegate in case of success/failure.
 */
- (void)execute;

/**
 * Mocks the service execution with the specified result. Can be an NSError object to mock an error.
 *
 * This method bypasses the result transformation (e.g. using resultTransformer/errorTransformer) and isRaw == NO.
 * If isRaw == YES the raw result is first converted (e.g. using resultTransformer/errorTransformer) before it is handed to the delegate.
 */
- (void)mockExecuteWithResult:(id)result isRaw:(BOOL)isRaw;

/**
 * Cancels the service.
 */
- (void)cancel;

/**
 * Unique identifier for each instance of a service
 */
- (NSString *)instanceIdentifier;

/**
 * Unique identifier for each class of services
 */
- (NSString *)classIdentifier;

/**
 * Sends the service to the background. 
 
 Returns YES if successful, NO otherwise (because background execution is not supported).
 */
- (BOOL)sendToBackground;

/**
 * Sends the service to the foreground.
 
 Returns YES if successful, NO otherwise (because background execution is not supported).
 */
- (BOOL)sendToForeground;

/**
 * Digest which uniquely identifies this service conveniently.
 */
- (nullable NSString *)digest;

@end

@class BMURLCache;

/**
 Protocol for services that implement caching using BMURLCache.
 
 @see BMURLCache
 */
@protocol BMCachedService <BMService>

/**
 Whether the cache is used for reading data to bypass a remote call (data is retrieved from cache if present). 
 
 Default is NO.
 */
@property (assign) BOOL readCacheEnabled;

/**
 Whether response data should be written to the cache. 
 
 Default is NO.
 */
@property (assign) BOOL writeCacheEnabled;

/**
 Whether after a service error data should be loaded from the cache to at least provide a meaningful response. 
 
 Default is NO.
 */
@property (assign) BOOL loadCachedResultOnError;

/**
 The key that was used to load/write the result from/to the cache.
 
 Can be used to access the cache directly to access the result.
 
 @see BMURLCache
 */
@property (nullable, readonly) NSString *cacheURLUsed;


/**
 Whether the cache was used for loading the result or not.
 
 @see cacheURLUsed.
 */
@property (readonly) BOOL cacheHit;

/**
 * Gets the result from the cache, if it exists.
 */
- (nullable id)resultFromCache;

/**
 Convenience method to enable/disable the properties readCacheEnabled, writeCacheEnabled and loadCachedResultOnError. 
 
 If enabled == NO and writeCacheEnabled was YES, writeCacheEnabled remains YES, to allow reenabling of the cache.
 */
- (void)setCachingEnabled:(BOOL)enabled;

/**
 * Should return the url cache to use for caching data for this class of services.
 
 * Default is the shared instance [BMURLCache sharedInstance]
 */
+ (BMURLCache *)urlCache;

@end

@protocol BMServiceDelegate<NSObject>

/**
 * Implement to act on successful completion of a service.
 */
- (void)service:(id <BMService>)service succeededWithResult:(id)result;

/**
 * Implement to act on failure of a service.
 */
- (void)service:(id <BMService>)service failedWithError:(NSError *)error;

@optional

/**
 The priority for the delegate, increase the number for higher priority (0 is default). 
 
 The priority is used to order the delivery of messages to the delegates.
 */
- (NSInteger)delegatePriorityForService:(id <BMService>)service;

/**
 Callback that is called when service is started.
 */
- (void)serviceDidStart:(id <BMService>)service;

/**
 Callback that is called when progress is updated. 
 
 Progress percentage is between 0.0 and 1.0.
 */
- (void)service:(id <BMService>)service updatedProgress:(double)progressPercentage withMessage:(nullable NSString *)message;

/**
Callback that is called when the service is cancelled.
*/
- (void)serviceWasCancelled:(id <BMService>)service;

/**
 Callback that is called when the service is sent to the background.
 */
- (void)serviceWasSentToBackground:(id <BMService>)service;

/**
 Callback that is called when the service is sent to the foreground.
 */
- (void)serviceWasSentToForeground:(id <BMService>)service;

/**
 * Callback that is called before the result is possibly converted to the actual result sent to service:succeededWithResult:.
 *
 * This callback supplies the raw result (as was also stored in the cache, in case of caching).
 */
- (void)service:(id <BMService>)service succeededWithRawResult:(id)rawResult;

/**
 * Callback that is called before the error is possibly converted to the actual error sent to service:failedWithError:.
 */
- (void)service:(id <BMService>)service failedWithRawError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
