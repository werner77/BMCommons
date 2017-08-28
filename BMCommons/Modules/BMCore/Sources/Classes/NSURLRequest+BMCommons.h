//
//  NSURLRequest+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 16/02/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (BMCommons)

/**
 * Setter for the timeout interval for a request.
 */
- (void)bmSetTimeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 * Setter for the cache policy of a request.
 */
- (void)bmSetCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

/**
 * String containing a digest uniquely identifying the request.
 *
 * The digest is calculated from the HTTP method, URL, header fields and body.
 */
- (NSString *)bmDigest;

/**
 Calculates a digest by including the specified header fields and optionally also includes the request body. 
 */
- (NSString *)bmDigestByIncludingHeaders:(nullable NSArray *)includeHeaders includeBody:(BOOL)includeBody;

/**
 Calculates a digest by using all the header fields exluding the specified headers and optionally also including the request body.
 */
- (NSString *)bmDigestByExcludingHeaders:(nullable NSArray *)excludeHeaders includeBody:(BOOL)includeBody;

/**
 Whether or not BMURLCaching based on the BMURLCachingProtocol is enabled for this request.
 */
- (BOOL)isBMURLCachingEnabled;

/**
 Whether or not handling by the BMURLCachingProtocol is enabled for this request.
 */
- (BOOL)isBMURLProtocolEnabled;

/**
 * Returns the raw description for the request including the method, url, headers and body.
 */
- (NSString *)bmRawDescription;

@end

@interface NSMutableURLRequest (BMCommons)

/**
 Enables/disables URL caching based on the BMURLCachingProtocol explicitly for this request, overriding the default behavior.
 */
- (void)setBMURLCachingEnabled:(BOOL)enabled;

/**
 * Enables/disables handling by the BMURLCachingProtocol explicitly for this request, overriding the default behavior.
 */
- (void)setBMURLProtocolEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END

