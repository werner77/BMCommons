//
//  BMParserService.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMHTTPRequest.h>
#import <BMCommons/BMXMLParser.h>
#import <BMCommons/BMParserHandler.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMAbstractService.h>

@class ParserContext;
@class CacheLoadingContext;
@class BMParserService;

typedef NS_ENUM(NSUInteger, BMParserType) {
    BMParserTypeXML,
    BMParserTypeJSON
};

/**
 Service for parsing XML/JSON responses.
 
 The implementation uses a streaming parser to avoid memory problems.
 
 @see BMParser
 */
@interface BMParserService : BMAbstractService<BMHTTPRequestDelegate, BMCachedService> {
    @private
	BMHTTPRequest *request;
	BMParser *parser;
	BOOL errorNotificationSent;
	BMParserHandler *handler;
    
    BMParserHandler *successHandler;
    BMParserHandler *errorHandler;
    
	BOOL readCacheEnabled;
	BOOL writeCacheEnabled;
	NSString *cacheURLUsed;
	
	NSThread *parserThread;
	
	ParserContext *parserContext;
	
	NSThread *cacheLoadingThread;
	BOOL loadCachedResultOnError;
	Class parserClass;
    
    NSError *lastRequestError;
    BMParserType parserType;
    BOOL cacheHit;
}

/**
 Parser type to use.
 
 BMXMLParser or BMJSONParser.
 */
@property (nonatomic, assign) BMParserType parserType;

/**
 The parser implementation class to use.
 
 BMXMLParser is default when parserType == BMParserTypeXML, otherwise BMJSONParser is used.
 
 Should be an implementation of BMParser.
 */
@property (nonatomic, readonly) Class parserClass;

/**
 Whether the cache is used for reading data to bypass a remote call (data is retrieved from cache if present). 
 
 Default is NO. Uses BMURLCache.
 */
@property (nonatomic, assign) BOOL readCacheEnabled;

/**
 Whether response data should be written to the cache. 
 
 Default is NO. Uses BMURLCache.
 */
@property (nonatomic, assign) BOOL writeCacheEnabled;

/**
 Whether after a service error data should be loaded from the cache to at least provide a meaningful response. 
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL loadCachedResultOnError;

/**
 The request that is being executed.
 */
@property (strong, nonatomic, readonly) BMHTTPRequest *request;

/**
 The parser handler that is used to parse the result.
 */
@property (strong, nonatomic, readonly) BMParserHandler *handler;

/**
 The key that was used to load the result from the cache. 
 
 Can be supplied to [BMURLCache dataForURL:]
 */
@property (strong, readonly) NSString *cacheURLUsed;

/**
 * Initialize with a BMServiceDelegate
 */
- (id)initWithDelegate:(id <BMServiceDelegate>)theDelegate;

/**
 * Executes the specified request and used the specified handler to parse the data.
 */
- (BOOL)executeRequest:(BMHTTPRequest *)theRequest withHandler:(BMParserHandler *)handler error:(NSError **)error;

/**
 * Executes the specified request and used the specified handler to parse the data. 
 
 Uses a special error handler to parse the error result.
 */
- (BOOL)executeRequest:(BMHTTPRequest *)theRequest withHandler:(BMParserHandler *)theHandler errorHandler:(BMParserHandler *)theErrorHandler error:(NSError **)error;

/**
 * Parse from local data instead of starting a URL request.
 */
- (BOOL)parseData:(NSData *)theData withHandler:(BMParserHandler *)handler error:(NSError **)error;

/**
 * Returns true if the value for the request can be retrieved from the cache
 */
- (BOOL)hasCachedResultForRequest:(BMHTTPRequest *)theRequest;

/**
 If this method returns YES no cache info is stored or read for the specified request.
 
 By default returns YES for requests that don't have an HTTP Method equal to "GET".
 */
- (BOOL)ignoreCacheForRequest:(BMHTTPRequest *)theRequest;

/**
 * Should return a url uniquely identifying the current request. 
 
 In case of a post request it needs to be transformed to a get form.
 * Is used for caching.
 */
- (NSString *)URLForRequest:(BMHTTPRequest *)theRequest;

/**
 * Returns true if a request is currently underway, or being received/parsed
 */
+ (BOOL)isBusy;

@end

@interface BMParserService(Protected)

/**
 Returns the handler to use for parsing the response.
 */
- (BMParserHandler *)handlerForService;

/**
 Optional separate error handler in case a non successful http code is returned.
 */
- (BMParserHandler *)errorHandlerForService;

/**
 Returns the request to execute.
 */
- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error;

/**
 Override hook to initialize the parser with any custom configuration before the request takes place
 */
- (void)configureParser:(BMParser *)theParser;

/**
 Override hook to perform initialization before starting the service. Be sure to always call super when overriding.
 */
- (void)prepare;

@end
