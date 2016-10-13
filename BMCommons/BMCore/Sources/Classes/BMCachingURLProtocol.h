//
//  BMURLProtocol.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/05/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMURLCache.h>

@class BMDataRecorder;

/**
 * Notification sent when any NSURLRequest is sent.
 *
 * May be used for logging or monitoring the responses.
 */
extern NSString * const BMCachingURLProtocolDidSendURLRequestNotification;

/**
 * Notification sent when any NSURLResponse is received.
 *
 * May be used for logging or monitoring the responses.
 */
extern NSString * const BMCachingURLProtocolDidReceiveURLResponseNotification;

/**
 * Key for request in the user info for notifications.
 */
extern NSString * const BMCachingURLProtocolURLRequestKey;

/**
 * Key for response in the user info for notifications.
 */
extern NSString * const BMCachingURLProtocolURLResponseKey;

@interface BMCachingURLProtocol : NSURLProtocol

/**
 The BMURLCache used to cache the responses.
 */
+ (BMURLCache *)cache;

/**
 The header keys that should be included for cache equivalence, if nil (the default) the implementation will revert to exclude header keys mode.
 */
+ (void)setIncludedHeaderKeysForCacheEquivalence:(NSArray *)headerKeys;
+ (NSArray *)includedHeaderKeysForCacheEquivalence;

/**
 The header keys that should be excluded for cache equivalence, if nil (the default) none will be excluded, so all headers are taken into account.
 */
+ (void)setExcludedHeaderKeysForCacheEquivalence:(NSArray *)headerKeys;
+ (NSArray *)excludedHeaderKeysForCacheEquivalence;

/**
 Whether the body of the request should be included to check cache equivalence. 
 
 Default is YES.
 */
+ (void)setIncludeBodyForCacheEquivalence:(BOOL)includeBody;
+ (BOOL)includeBodyForCacheEquivalence;

/**
 Whether or not caching is enabled by default.
 
 Default is YES.
 
 This can be overridden per request using the method [BMURLCachingProtocol setCachingEnabled:forRequest:].
 */
+ (void)setCachingEnabledByDefault:(BOOL)defaultEnabled;
+ (BOOL)isCachingEnabledByDefault;

/**
 Explicitly sets caching enabled for the specified request, overriding the default.
 */
+ (void)setCachingEnabled:(BOOL)enabled forRequest:(NSMutableURLRequest *)request;

/**
 Returns the overridden cachingEnabled state for the specified request if set, otherwise returns the default cachingEnabled state.
 */
+ (BOOL)isCachingEnabledForRequest:(NSURLRequest *)request;

/**
 If true the cache headers as returned by the response are honored for the max time to cache it (if allowed at all).
 
 Default is YES.
 */
+ (void)setHonorHTTPCacheHeaders:(BOOL)honorCacheHeaders;
+ (BOOL)honorHTTPCacheHeaders;

/**
 * Use for recording/playback funtionality.
 */
+ (BMDataRecorder *)recorder;

/**
 * If true, which is the default, a connection failure error is mocked in playback mode if a request is sent for which no response was recorded previously.
 * If false the request is just performed as usual and sent to the server, so no playback is performed for that particular request.
 *
 * @return Whether error mocking is enabled or not.
 */
+ (BOOL)mockConnectionFailureIfPlaybackFails;
+ (void)setMockConnectionFailureIfPlaybackFails:(BOOL)b;


/**
 * Returns true if any connection is active managed by this protocol.
 *
 * @return true if loading, false otherwise.
 */
+ (BOOL)isLoading;

/**
 * Waits until all connections managed by instances of this protocol are terminated.
 *
 * @param completion Completion block, specifying whether loading actually finished (false if a timeout occured while waiting) and
 * whether a wait was necessary or if the block returned immediately without waiting because no connection was active.
 * @param timeout Time out for waiting, 0 for waiting indefinitely
 */
+ (void)waitUntilLoadingFinishedWithCompletion:(void (^)(BOOL loadingFinished, BOOL waited))completion timeout:(NSTimeInterval)timeout;

@end
