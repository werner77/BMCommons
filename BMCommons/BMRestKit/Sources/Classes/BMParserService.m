//
//  BMParserService.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMParserService.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMErrorCodes.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMJSONParser.h>
#import <BMCommons/BMRestKit.h>

@interface CacheData : NSObject {
	NSString *key;
	id value;
}

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) id value;

@end

@implementation CacheData

@synthesize key, value;


@end


@interface ParserContext : NSObject {
	BMParser *parser;
	id __weak target;
	SEL action;
	BOOL parsingFinished;
	NSCondition *parserCondition;
}

@property (nonatomic, strong) BMParser *parser;
@property (nonatomic, strong) NSCondition *parserCondition;
@property (nonatomic, assign) BOOL parsingFinished;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@end

@implementation ParserContext

@synthesize parser, target, action, parserCondition, parsingFinished;

- (id)init {
	if ((self = [super init])) {
		parserCondition = [NSCondition new];
	}
	return self;
}


@end

@interface ParserSuccessArgument : NSObject {
	BMHTTPRequest *request;
	BOOL success;
}

@property (nonatomic, strong) BMHTTPRequest *request;
@property (nonatomic, assign) BOOL success;

@end

@implementation ParserSuccessArgument

@synthesize request, success;

- (void)dealloc {
	self.request = nil;
}

@end

@interface CacheLoadingContext : NSObject {
	id __weak target;
	SEL action;
	NSData *data;
    NSString *url;
    BMURLCache *cache;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) BMURLCache *cache;

@end

@implementation CacheLoadingContext

@synthesize target, action, data, url, cache;


@end

@interface BMParserService()

@property (assign) BOOL cacheHit;
@property (strong) NSString *cacheURLUsed;

@end

@interface BMParserService(Private)

+ (void)performSelectorOnMainThread:(SEL)selector onTarget:(id)target withArgument:(NSObject *)arg;

- (void)cacheResult:(id)result forRequest:(BMHTTPRequest *)theRequest;
- (BOOL)loadCachedResultForRequest:(BMHTTPRequest *)theRequest;
- (BOOL)forceLoadCachedResultForRequest:(BMHTTPRequest *)theRequest;
- (void)destroyParserThread;
- (void)destroyCacheLoadingThread;
- (void)startParserThread;
- (void)setHandler:(BMParserHandler *)theHandler;
- (void)setRequest:(BMHTTPRequest *)theRequest;


@end

@interface BMParserService()

@property (nonatomic, strong) BMParserHandler *successHandler;
@property (nonatomic, strong) BMParserHandler *errorHandler;
@property (nonatomic, strong) NSError *lastRequestError;

@end

@implementation BMParserService

static volatile int threadCount = 0;

@synthesize readCacheEnabled, writeCacheEnabled, request, handler, cacheURLUsed, loadCachedResultOnError,
parserClass, successHandler, errorHandler, lastRequestError, parserType, cacheHit;

#pragma mark -
#pragma mark Initialization and Deallocation

- (id)initWithDelegate:(id <BMServiceDelegate>)theDelegate {
	if ((self = [self init])) {
		self.delegate = theDelegate;
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
        BMRestKitCheckLicense();
        self.parserType = BMParserTypeXML;
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(cacheURLUsed);
}

- (Class)parserClass {
    if (self.parserType == BMParserTypeXML) {
        return [BMXMLParser class];
    } else {
        return [BMJSONParser class];
    }
}

- (BOOL)hasCachedResultForRequest:(BMHTTPRequest *)theRequest {
	BMURLCache *cache = self.class.urlCache;
    BOOL ret = NO;
    if (![self ignoreCacheForRequest:theRequest]) {
        NSString *key = [self URLForRequest:theRequest];
        ret = [cache hasDataForURL:key];;
    }
    return ret;
}

#pragma mark -
#pragma mark Other methods

- (void)cancel {
	BOOL wasLoadCachedResult = loadCachedResultOnError;
	loadCachedResultOnError = NO;
	[request cancel];
	request.delegate = nil;
	[self destroyParserThread];
	[self destroyCacheLoadingThread];
	parser.delegate = nil;
	BM_RELEASE_SAFELY(request);
	BM_RELEASE_SAFELY(handler);
    BM_RELEASE_SAFELY(errorHandler);
    BM_RELEASE_SAFELY(successHandler);
	BM_RELEASE_SAFELY(parser);
    BM_RELEASE_SAFELY(lastRequestError);
	loadCachedResultOnError = wasLoadCachedResult;
	[super cancel];
}

- (void)prepare {
	[self destroyParserThread];
	BM_RELEASE_SAFELY(parser);
    self.lastRequestError = nil;
    self.request.delegate = nil;
	self.request = nil;
	self.handler = nil;
    self.errorHandler = nil;
    self.successHandler = nil;
    self.cacheURLUsed = nil;
	
	errorNotificationSent = NO;
    self.cacheHit = NO;
}

- (BOOL)handleNilRequest:(NSError **)error {
    if (error) {
        *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_NO_REQUEST description:@"Request could not be created"];
    }
    return NO;
}

- (id)resultFromCache {
    id result = nil;
    BMHTTPRequest *theRequest = [self requestForServiceWithError:nil];
    
    if (![self ignoreCacheForRequest:theRequest]) {
        BMURLCache *cache = self.class.urlCache;
        NSString *key = [self URLForRequest:theRequest];
        NSData *data = [cache dataForURL:key];
        
        @try {
            result = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
        } @catch (NSException *exception) {
            LogWarn(@"Could not unarchive data from cache: %@", exception);
            [cache removeURL:key fromDisk:YES];
        }
    }
    return result;
}

- (BOOL)ignoreCacheForRequest:(BMHTTPRequest *)theRequest {
    return ![theRequest.request.HTTPMethod isEqual:BM_HTTP_METHOD_GET];
}

- (void)setCachingEnabled:(BOOL)enabled {
    self.readCacheEnabled = enabled;
    self.writeCacheEnabled = enabled || self.writeCacheEnabled;
    self.loadCachedResultOnError = enabled;
}

- (BOOL)executeRequest:(BMHTTPRequest *)theRequest withHandler:(BMParserHandler *)theHandler errorHandler:(BMParserHandler *)theErrorHandler error:(NSError **)error {
    [self prepare];
	
	if (theRequest) {
		BOOL hasCachedResult = [self loadCachedResultForRequest:theRequest];
		if (!hasCachedResult) {
			self.request = theRequest;
			request.delegate = self;
			NSInputStream *inputStream = [request inputStreamForConnection];
			parser = [[self.parserClass alloc] initWithStream:inputStream];
			[self configureParser:parser];
            self.successHandler = theHandler;
            self.errorHandler = theErrorHandler;
			[self startParserThread];
		}
		return YES;
	} else {
		return [self handleNilRequest:error];
	}
}

- (BOOL)executeRequest:(BMHTTPRequest *)theRequest withHandler:(BMParserHandler *)theHandler error:(NSError **)error {
    return [self executeRequest:theRequest withHandler:theHandler errorHandler:nil error:error];
}

- (BOOL)parseData:(NSData *)theData withHandler:(BMParserHandler *)theHandler error:(NSError **)error {
	[self prepare];
	
	if (theData) {
		parser = [[self.parserClass alloc] initWithData:theData];
		[self configureParser:parser];
		self.handler = theHandler;
		[self startParserThread];
		return YES;
	} else {
		if (error) {
			*error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA description:@"No data was supplied"];
		}
		return NO;
	}
}

#pragma mark - Request delegate

- (void)requestSucceeded:(BMHTTPRequest *)theRequest {
	LogInfo(@"Request succeeded");
	request.delegate = nil;
}

- (void)requestFailed:(BMHTTPRequest *)theRequest {
	//Let the parsingFinishedWithSuccess method handle the error
	LogError(@"Request failed with error: %@", theRequest.lastError);
    
    self.lastRequestError = theRequest.lastError;
    request.delegate = nil;
}

- (void)request:(BMHTTPRequest *)theRequest didReceiveResponse:(NSURLResponse *)response {
    BOOL successResponse = [theRequest isSuccessfulHTTPResponse];
    if (!successResponse && self.errorHandler) {
        self.handler = self.errorHandler;
    } else {
        self.handler = self.successHandler;
    }
}

#pragma mark - Parser callback

- (void)parsingFinishedWithSuccess:(ParserSuccessArgument *)arg {
	BOOL parsedOK = arg.success;
    
	NSError *error = nil;
	if (parsedOK) {
        if (self.lastRequestError) {
            error = self.lastRequestError;
        } else {
            error = [self.handler error];
        }
	} else {
		if (parser.parserError) {
			LogError(@"Error returned by parser: %@", parser.parserError);
		}
		
		if (self.lastRequestError) {
			error = self.lastRequestError;
		} else {
			error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER
											 code:BM_ERROR_INVALID_RESPONSE
									  description:BMLocalizedString(@"No valid response from server",
																	nil)];
		}
	}
	if (error) {
		LogError(@"Service error: %@", error);
		if (self.loadCachedResultOnError && [self forceLoadCachedResultForRequest:arg.request]) {
			LogError(@"Retrieving result from cache on error");
		} else {
			[self serviceFailedWithRawError:error];
		}
	} else {
		id result = [self.handler result];
		[self cacheResult:result forRequest:arg.request];
		[self serviceSucceededWithRawResult:result];
	}
	
	parser.delegate = nil;
	BM_AUTORELEASE_SAFELY(parser);
	BM_AUTORELEASE_SAFELY(handler);
    BM_AUTORELEASE_SAFELY(successHandler);
    BM_AUTORELEASE_SAFELY(errorHandler);
    BM_AUTORELEASE_SAFELY(request);
}

- (NSString *)URLForRequest:(BMHTTPRequest *)theRequest {
	return [theRequest.url absoluteString];
}

+ (BMURLCache *)urlCache {
	return [BMURLCache sharedCache];
}

+ (BOOL)isBusy {
	BOOL ret = NO;
	@synchronized([BMParserService class]) {
		ret = threadCount > 0;
	}
	return ret;
}

- (BOOL)executeWithError:(NSError **)error {
    BMHTTPRequest *theRequest = [self requestForServiceWithError:error];
    if (!theRequest) {
        if (error && *error == nil) {
            [self handleNilRequest:error];
        }
        return NO;
    }
	return [self executeRequest:theRequest withHandler:[self handlerForService] errorHandler:[self errorHandlerForService] error:error];
}

#pragma mark -
#pragma mark Methods to be implemented by sub classes

- (BMParserHandler *)handlerForService {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BMParserHandler *)errorHandlerForService {
    return nil;
}

- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)configureParser:(BMParser *)theParser {
	//Default don't do anything
}

@end

@implementation BMParserService(Private)

+ (void)performSelectorOnMainThread:(SEL)selector onTarget:(id)target withArgument:(NSObject *)arg {
	[target performSelectorOnMainThread:selector withObject:arg waitUntilDone:NO];
}

#pragma mark Parser Thread

- (void)startParserThread {
	parserContext = [ParserContext new];
	parserContext.parser = parser;
	parserContext.target = self;
	parserContext.action = @selector(parser:completedOK:context:);
	parserContext.parsingFinished = NO;
	parserThread = [[NSThread alloc] initWithTarget:[BMParserService class] selector:@selector(parseThread:) object:parserContext];
	
	[parserThread start];
}

- (void)destroyParserThread {
	if (parserThread) {
		parser.delegate = nil;
		[parserThread cancel];
		[parser abortParsing];
		
		if ([parserThread isExecuting]) {
			[parserContext.parserCondition lock];
			
			while (!parserContext.parsingFinished) {
				[parserContext.parserCondition wait];
			}
			
			[parserContext.parserCondition unlock];
		}
		
		parserThread = nil;
		
		parserContext = nil;
		
		LogInfo(@"Parser thread destroyed");
	}
}

- (void)parser:(BMParser *)theParser completedOK:(BOOL)parsedOK context:(void *)context {
	if (![[NSThread currentThread] isCancelled]) {
		[[NSThread currentThread] cancel];
		
		ParserSuccessArgument *arg = [ParserSuccessArgument new];
		arg.success = parsedOK;
		arg.request = self.request;
		
		[[self class] performSelectorOnMainThread:@selector(parsingFinishedWithSuccess:) onTarget:self withArgument:arg];
	}
}

+ (void)parseThread:(ParserContext *)parserContext {
	@autoreleasepool {
	
		@synchronized ([BMParserService class]) {
			threadCount++;
		}
		
		[parserContext.parser parseAsynchronouslyUsingRunLoop:[NSRunLoop currentRunLoop]
														 mode:NSDefaultRunLoopMode
											notifyingDelegate:parserContext.target
													 selector:parserContext.action
													  context:nil];
		
		
		while (![[NSThread currentThread] isCancelled]) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
		
		[parserContext.parserCondition lock];
		parserContext.parsingFinished = YES;
		[parserContext.parserCondition signal];
		LogInfo(@"Parser thread finished");
		[parserContext.parserCondition unlock];
		
		@synchronized ([BMParserService class]) {
			threadCount--;
		}
	
	}
}

#pragma mark Cache loading thread

- (void)serviceSucceededWithCachedResult:(id)result {
    self.cacheHit = YES;
    [self serviceSucceededWithRawResult:result];
}

- (BOOL)forceLoadCachedResultForRequest:(BMHTTPRequest *)theRequest {
	BOOL ret = NO;
    if (![self ignoreCacheForRequest:theRequest]) {
        BMURLCache *cache = self.class.urlCache;
        NSString *key = [self URLForRequest:theRequest];
        self.cacheURLUsed = key;
        if ([cache hasDataForURL:key]) {
            
            LogInfo(@"Result found in cache");
            ret = YES;
            
            CacheLoadingContext *cacheLoadingContext = [CacheLoadingContext new];
            cacheLoadingContext.target = self;
            cacheLoadingContext.action = @selector(serviceSucceededWithCachedResult:);
            cacheLoadingContext.url = key;
            cacheLoadingContext.cache = cache;
            
            cacheLoadingThread = [[NSThread alloc] initWithTarget:[BMParserService class] selector:@selector(loadThread:) object:cacheLoadingContext];
            [cacheLoadingThread start];
        }
    }
	return ret;
}

- (BOOL)loadCachedResultForRequest:(BMHTTPRequest *)theRequest {
	BOOL ret = NO;
	if (self.readCacheEnabled) {
		ret = [self forceLoadCachedResultForRequest:theRequest];
	}
	return ret;
}

- (void)destroyCacheLoadingThread {
	if (cacheLoadingThread) {
		@synchronized(cacheLoadingThread) {
			[cacheLoadingThread cancel];
		}
		cacheLoadingThread = nil;
	}
}

+ (void)loadThread:(CacheLoadingContext *)context {
	@autoreleasepool {
    
		NSData *data = nil;
		@synchronized ([NSThread currentThread]) {
			if (![[NSThread currentThread] isCancelled]) {
                data = [context.cache dataForURL:context.url];
			}
		}

		id result = nil;
        @try {
            result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (result == nil && data != nil) {
                LogWarn(@"Data on disk could not be deserialized");
                [context.cache removeURL:context.url fromDisk:YES];
            }
        }
        @catch (NSException *exception) {
            LogWarn(@"Could not unarchive data from cache: %@", exception);
            [context.cache removeURL:context.url fromDisk:YES];
        }
        
		@synchronized([NSThread currentThread]) {
			if (![[NSThread currentThread] isCancelled]) {
				[self performSelectorOnMainThread:context.action onTarget:context.target withArgument:result];
			}
		}
		LogInfo(@"Cache load thread finished");
	
	}
}


#pragma mark Save thread

- (void)cacheResult:(id)result forRequest:(BMHTTPRequest *)theRequest {
	if (self.writeCacheEnabled && [result conformsToProtocol:@protocol(NSCoding)] && ![self ignoreCacheForRequest:theRequest]) {
		LogInfo(@"Caching result");
		NSString *key = [self URLForRequest:theRequest];
		self.cacheURLUsed = key;
		if (key) {
			NSArray *arguments = [[NSArray alloc] initWithObjects:key, result, nil];
			[NSThread detachNewThreadSelector:@selector(saveThread:) toTarget:[BMParserService class] withObject:arguments];
		}
	}
}

+ (void)saveThread:(NSArray *)arguments {
	
	@autoreleasepool {
	
		NSString *key = [arguments objectAtIndex:0];
		id result = [arguments objectAtIndex:1];
		
		NSData *data = nil;
        @try {
            data = [NSKeyedArchiver archivedDataWithRootObject:result];
        }
        @catch (NSException *exception) {
            LogWarn(@"Could not archive data for caching: %@", exception);
        }
		
		if (data) {
            BMURLCache *cache = self.class.urlCache;
            [cache storeData:data forURL:key];
        }
		LogInfo(@"Data save thread finished");
	}
}

#pragma mark Private setters

- (void)setHandler:(BMParserHandler *)theHandler {
	if (handler != theHandler) {
		handler = theHandler;
	}
    parser.delegate = theHandler;
}

- (void)setRequest:(BMHTTPRequest *)theRequest {
	if (request != theRequest) {
		request = theRequest;
	}
}

@end


