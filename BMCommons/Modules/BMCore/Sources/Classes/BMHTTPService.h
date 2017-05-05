//
//  BMHTTPService.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMHTTPRequest.h>
#import <BMCommons/BMAbstractService.h>

/**
 Plain HTTP service. 
 
 Implementations are responsible for supplying the request and mapping the response via
 requestForServiceWithError: , resultFromRequest: and errorFromRequest:
 */
@interface BMHTTPService : BMAbstractService<BMHTTPRequestDelegate, BMCachedService>

@property (assign) BOOL parseInBackgroundThread;

@end

@interface BMHTTPService(Protected)

/**
 Returns the request to execute for this service.
 
 Sub classes should implement this method in a meaningful way.
 */
- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error;

/**
 Extracts a result object from the response (or null in case of error).
 
 Sub classes should implement this method in a meaningful way.
 */
- (id)resultFromRequest:(BMHTTPRequest *)theRequest;

/**
 Extracts/creates an error object from the response.
 
 Sub classes should implement this method in a meaningful way.
 */
- (NSError *)errorFromRequest:(BMHTTPRequest *)theRequest;

/**
 The URL from the request which is used for caching.
 
 Normally this is just [BMHTTPRequest url] (which is the default implementation of this method), but if a HTTP POST is used the url may need to be extended with the post parameters to make it unique.
 */
- (NSString *)URLFromRequest:(BMHTTPRequest *)theRequest;

/**
 The cached result (if present) for the specified HTTP request.
 
 Default returns the value from the BMURLCache for the URL in the HTTP request unless ignoreCacheForRequest: returns YES.
 */
- (id)cachedResultForRequest:(BMHTTPRequest *)theRequest;

/**
 If this method returns YES no cache info is stored or read for the specified request. 
 
 By default returns YES for requests that don't have an HTTP Method equal to "GET".
 */
- (BOOL)ignoreCacheForRequest:(BMHTTPRequest *)theRequest;

@end
