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
}

@property (strong) NSString *key;
@property (strong) id value;

@end

@implementation CacheData

@end


@interface ParserContext : NSObject {
}

@property (weak) BMParser *parser;
@property (strong) NSCondition *parserCondition;
@property (assign) BOOL parsingFinished;
@property (weak) id target;
@property (assign) SEL action;

@end

@implementation ParserContext

- (id)init {
	if ((self = [super init])) {
		self.parserCondition = [NSCondition new];
	}
	return self;
}


@end

@interface ParserSuccessArgument : NSObject {
}

@property (strong) BMHTTPRequest *request;
@property (assign) BOOL success;

@end

@implementation ParserSuccessArgument

- (void)dealloc {
	self.request = nil;
}

@end

@interface CacheLoadingContext : NSObject {
}

@property (weak) id target;
@property (assign) SEL action;
@property (strong) NSData *data;
@property (strong) NSString *url;
@property (strong) BMURLCache *cache;

@end

@implementation CacheLoadingContext

@end

@interface BMParserService(Private)

+ (void)performSelectorOnMainThread:(SEL)selector onTarget:(id)target withArgument:(NSObject *)arg;

- (void)cacheResult:(id)result forRequest:(BMHTTPRequest *)theRequest;
- (BOOL)loadCachedResultForRequest:(BMHTTPRequest *)theRequest;
- (BOOL)forceLoadCachedResultForRequest:(BMHTTPRequest *)theRequest;
- (void)destroyParserThread;
- (void)destroyCacheLoadingThread;
- (void)startParserThread;

@end

@interface BMParserService()

@property (assign) BOOL cacheHit;
@property (strong) NSString *cacheURLUsed;
@property (strong) BMParserHandler *successHandler;
@property (strong) BMParserHandler *errorHandler;
@property (strong) NSError *lastRequestError;
@property (strong) BMParser *parser;
@property (assign) BOOL errorNotificationSent;
@property (strong) NSThread *parserThread;
@property (strong) ParserContext *parserContext;
@property (strong) NSThread *cacheLoadingThread;
@property (strong) BMHTTPRequest *request;
@property (strong) BMParserHandler *handler;

@end

@implementation BMParserService {
}

static volatile int threadCount = 0;

@synthesize readCacheEnabled = _readCacheEnabled, writeCacheEnabled = _writeCacheEnabled, request = _request, handler = _handler, cacheURLUsed = _cacheURLUsed, loadCachedResultOnError = _loadCachedResultOnError,
parserClass = _parserClass, successHandler = _successHandler, errorHandler = _errorHandler, lastRequestError = _lastRequestError, parserType = _parserType, cacheHit = _cacheHit;

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
        self.parserType = BMParserTypeXML;
	}
	return self;
}

- (void)dealloc {
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
	BOOL wasLoadCachedResult = self.loadCachedResultOnError;
	self.loadCachedResultOnError = NO;
	[self.request cancel];
	self.request.delegate = nil;
	[self destroyParserThread];
	[self destroyCacheLoadingThread];
	self.parser.delegate = nil;
	self.request = nil;
	self.handler = nil;
	self.errorHandler = nil;
	self.successHandler = nil;
	self.parser = nil;
	self.lastRequestError = nil;
	self.loadCachedResultOnError = wasLoadCachedResult;
	[super cancel];
}

- (void)prepare {
	[self destroyParserThread];
	self.parser = nil;
    self.lastRequestError = nil;
    self.request.delegate = nil;
	self.request = nil;
	self.parser.delegate = nil;
	self.handler = nil;
    self.errorHandler = nil;
    self.successHandler = nil;
    self.cacheURLUsed = nil;
	
	self.errorNotificationSent = NO;
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
			self.request.delegate = self;
			NSInputStream *inputStream = [self.request inputStreamForConnection];
			self.parser = [[self.parserClass alloc] initWithStream:inputStream];
			[self configureParser:self.parser];
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
		self.parser = [[self.parserClass alloc] initWithData:theData];
		[self configureParser:self.parser];
		self.handler = theHandler;
		self.parser.delegate = theHandler;
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
	self.request.delegate = nil;
}

- (void)requestFailed:(BMHTTPRequest *)theRequest {
	//Let the parsingFinishedWithSuccess method handle the error
	LogError(@"Request failed with error: %@", theRequest.lastError);
    
    self.lastRequestError = theRequest.lastError;
    self.request.delegate = nil;
}

- (void)request:(BMHTTPRequest *)theRequest didReceiveResponse:(NSURLResponse *)response {
    BOOL successResponse = [theRequest isSuccessfulHTTPResponse];
    if (!successResponse && self.errorHandler) {
        self.handler = self.errorHandler;
		self.parser.delegate = self.handler;
    } else {
        self.handler = self.successHandler;
		self.parser.delegate = self.handler;
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
		if (self.parser.parserError) {
			LogError(@"Error returned by parser: %@", self.parser.parserError);
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
	
	self.parser.delegate = nil;
	self.parser = nil;
	self.handler = nil;
	self.successHandler = nil;
	self.errorHandler = nil;
	self.request = nil;
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
	ParserContext *parserContext = [ParserContext new];
	parserContext.parser = self.parser;
	parserContext.target = self;
	parserContext.action = @selector(parser:completedOK:context:);
	parserContext.parsingFinished = NO;
	self.parserContext = parserContext;
	self.parserThread = [[NSThread alloc] initWithTarget:[BMParserService class] selector:@selector(parseThread:) object:parserContext];
	
	[self.parserThread start];
}

- (void)destroyParserThread {
	if (self.parserThread) {
		self.parser.delegate = nil;
		[self.parserThread cancel];
		[self.parser abortParsing];
		
		if ([self.parserThread isExecuting]) {
			[self.parserContext.parserCondition lock];
			
			while (!self.parserContext.parsingFinished) {
				[self.parserContext.parserCondition wait];
			}
			
			[self.parserContext.parserCondition unlock];
		}
		
		self.parserThread = nil;
		
		self.parserContext = nil;
		
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
            
            self.cacheLoadingThread = [[NSThread alloc] initWithTarget:[BMParserService class] selector:@selector(loadThread:) object:cacheLoadingContext];
            [self.cacheLoadingThread start];
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
	if (self.cacheLoadingThread) {
		@synchronized(self.cacheLoadingThread) {
			[self.cacheLoadingThread cancel];
		}
		self.cacheLoadingThread = nil;
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

@end


