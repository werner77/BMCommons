//
//  BMAsyncDataLoader.m
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAsyncDataLoader.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMErrorCodes.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMHTTPStatusCodes.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/NSArray+BMCommons.h>
#import <BMCommons/NSObject+BMCommons.h>

@interface BMAsyncDataLoader()

@property(assign) BMAsyncLoadingStatus loadingStatus;

@property (strong) NSString *mimeType;

@property(assign, getter=isPriority) BOOL priority;

@end

@interface BMAsyncDataLoader(Private)

- (void)setUrl:(NSURL *)url;

- (void)finishedLoadingWithError:(NSError *)error;
- (void)finishedLoadingWithObject:(NSObject *)theObject;
- (void)retryRequest;
- (void)startLoadingImmediately;
- (void)startedLoading;
- (void)notifyDelegateWithError:(NSError *)error;

- (void)appendBufferData:(NSData *)incrementalData;
- (NSObject *)objectFromBufferData;

//Loader management
+ (NSMutableArray *)loadersForURL:(NSURL *)url;
+ (NSMutableArray *)loadersForURL:(NSURL *)url ofClass:(Class)loaderClass;
+ (void)addLoader:(BMAsyncDataLoader *)loader;
+ (NSMutableArray *)popLoadersForUrl:(NSURL *)url ofClass:(Class)loaderClass;
+ (BOOL)hasLoaderForUrl:(NSURL *)url ofClass:(Class)loaderClass;
+ (NSArray *)popLoader:(BMAsyncDataLoader *)loader;

//Loader connection queueing and dequeueing
+ (void)queueLoader:(BMAsyncDataLoader *)loader withPriority:(BOOL)priority;
+ (BOOL)dequeueLoader:(BMAsyncDataLoader *)loader;
+ (BOOL)dequeueLoader:(BMAsyncDataLoader *)loader startLoadingNext:(BOOL)startLoadingNext;
+ (void)addAndQueueLoader:(BMAsyncDataLoader *)loader;

@end

static NSUInteger maxConnections = 1;
static NSMutableDictionary *urlDataLoaders = nil;
static NSMutableArray *loaderQueue = nil;
static BMURLCache *defaultCache = nil;
static NSOperationQueue *backgroundOperationQueue = nil;

@implementation BMAsyncDataLoader {
    NSMutableData *_buffer;
    NSURLConnection *_connection;
    NSInteger _tryCount;
    NSURLRequest *_request;
}

@synthesize loadingStatus = _loadingStatus;
@synthesize object = _object;
@synthesize delegate = _delegate;
@synthesize maxRetryCount = _maxRetryCount;
@synthesize url = _url;
@synthesize urlString = _urlString;
@synthesize context = _context;
@synthesize priority = _priority;
@synthesize connectionTimeOut = _connectionTimeOut;
@synthesize ignoreCache = _ignoreCache;
@synthesize storeToCache = _storeToCache;
@synthesize mimeType = _mimeType;
@synthesize cache = _cache;

+ (void)initialize {
    if (self == [BMAsyncDataLoader class]) {
        @synchronized([BMAsyncDataLoader class]) {
            if(!loaderQueue) {
                loaderQueue = [[NSMutableArray alloc] initWithCapacity:20];
            }
            if (!urlDataLoaders) {
                urlDataLoaders = [[NSMutableDictionary alloc] initWithCapacity:20];
            }
            [self setMaxConnections:BM_ASYNCDATALOADER_DEFAULT_MAX_CONNECTIONS];
            if (!backgroundOperationQueue) {
                backgroundOperationQueue = [[NSOperationQueue alloc] init];
            }
        }
    }
}

+ (void)setMaxConnections:(NSUInteger)theMaxConnections {
    @synchronized([BMAsyncDataLoader class]) {
        maxConnections = theMaxConnections;
    }
}

+ (NSUInteger)maxConnections {
    @synchronized([BMAsyncDataLoader class]) {
        return maxConnections;
    }
}

+ (void)setDefaultCache:(BMURLCache *)cache {
    @synchronized([BMAsyncDataLoader class]) {
        defaultCache = cache;
    }
}

+ (BMURLCache *)defaultCache {
    BMURLCache *ret = nil;
    @synchronized([BMAsyncDataLoader class]) {
        if (defaultCache) {
            ret = defaultCache;
        }
    }
    if (ret == nil) {
        ret = [BMURLCache sharedCache];
    }
    return ret;
}

- (id)init {
    return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)theURL {
    if ((self = [super init])) {
        if (!theURL) {
            return nil;
        }
        @synchronized(self) {
            _maxRetryCount = BM_ASYNCDATALOADER_DEFAULT_MAX_RETRY_COUNT;
            _connectionTimeOut = BM_ASYNCDATALOADER_DEFAULT_CONNECTION_TIMEOUT;
            _loadingStatus = BMAsyncLoadingStatusIdle;
            _storeToCache = YES;
            _alwaysNotifyAsynchronously = NO;
            self.url = theURL;
        }
    }
    return self;
}

- (id)initWithURLString:(NSString *)theURLString {
    NSURL *url = [BMStringHelper urlFromString:theURLString];
    return url == nil ? nil : [self initWithURL:url];
}

- (void)dealloc {
    [self cancelLoading];
}

- (BMAsyncLoadingStatus)startLoadingWithPriority:(BOOL)thePriority {
    BOOL shouldQueue = NO;
    
    BMAsyncDataLoader *__strong strongSelf = self;
    
    if (self.loadingStatus == BMAsyncLoadingStatusLoading ||
        (self.loadingStatus == BMAsyncLoadingStatusQueued && self.isPriority == thePriority)) {
        //Already loading or queued
        return self.loadingStatus;
    }
    
    [self cancelLoading];
    
    self.object = nil;
    self.priority = thePriority;
    
    if ([self validateURL:self.url]) {
        
        BMAsyncDataLoaderCacheState cacheState = self.ignoreCache ? BMAsyncDataLoaderCacheStateNone : self.cacheState;
        
        BOOL shouldLoadAsynchronous = self.alwaysNotifyAsynchronously || cacheState == BMAsyncDataLoaderCacheStateDisk;
        BOOL hasCache = cacheState != BMAsyncDataLoaderCacheStateNone;
        
        BMAsyncDataLoader *__weak weakLoader = self;
        if (hasCache) {
            if (shouldLoadAsynchronous) {
                self.loadingStatus = BMAsyncLoadingStatusLoadingFromCache;
                [self bmPerformBlockInBackground:^id {
                    weakLoader.loadingStatus = BMAsyncLoadingStatusIdle;
                    weakLoader.object = [self cachedObject];
                    
                    if (weakLoader.object == nil) {
                        //Data corrupt? Cached data exists but cached object is nil: ignore cache
                        [weakLoader.class addAndQueueLoader:weakLoader];
                    } else {
                        [weakLoader notifyDelegateWithError:nil];
                    }
                    return nil;
                } withCompletion:nil];
            } else {
                self.object = self.cachedObject;
                if (self.object == nil) {
                    shouldQueue = YES;
                } else {
                    [self notifyDelegateWithError:nil];
                }
            }
        } else {
            shouldQueue = YES;
        }
    } else {
        NSError *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_URL
                                           description:[NSString stringWithFormat:@"Invalid URL specified: %@", self.url]];
        
        if (self.alwaysNotifyAsynchronously) {
            [self performSelector:@selector(notifyDelegateWithError:) withObject:error afterDelay:0.0];
        } else {
            [self notifyDelegateWithError:error];
        }
    }
    
    if (shouldQueue) {
        [[self class] addAndQueueLoader:self];
    }
    
    return strongSelf.loadingStatus;
}

- (BMAsyncLoadingStatus)startLoading {
    return [self startLoadingWithPriority:NO];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse
{
    NSInteger statusCode = 0;
    if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)theResponse;
        statusCode = httpResponse.statusCode;
        LogDebug(@"Got HTTP response from server: %d", (int)httpResponse.statusCode);
    }
    
    self.mimeType = [theResponse MIMEType];
    
    if (![self isSuccessfulResponse:theResponse]) {
        //Don't retry unsuccesful responses, only failed connections
        @synchronized(self) {
            [_connection cancel];
        }
        NSError *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:statusCode
                                           description:[NSString stringWithFormat:@"Unsuccessful response: %zd",  statusCode]];
        [self finishedLoadingWithError:error];
    }
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (![self.delegate respondsToSelector:@selector(asyncDataLoader:shouldAppendData:)] || [self.delegate asyncDataLoader:self shouldAppendData:incrementalData]) {
        [self appendBufferData:incrementalData];
    }
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    NSObject *theObject = [self objectFromBufferData];
    if (theObject) {
        [self finishedLoadingWithObject:theObject];
    } else {
        NSError *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_INVALID_RESPONSE
                                           description:@"No parseable content returned from server"];
        [self finishedLoadingWithError:error];
    }
}

- (NSObject *)processData:(NSData *)data forURLString:(NSString *)urlString withCache:(BMURLCache *)cache {
    NSString *cacheKey = nil;
    if (cache) {
        cacheKey = [cache keyForURL:urlString];
        if (data.length > 0) {
            [cache storeData:data forKey:cacheKey];
        } else {
            [cache removeKey:cacheKey fromDisk:YES];
        }
    }
    return [self objectFromData:data withCache:cache cacheKey:cacheKey];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    
    LogInfo(@"Failed to load Object, error: %@", error);
    
    BOOL canRetry = NO;
    @synchronized(self) {
        canRetry = _tryCount++ < self.maxRetryCount;
    }
    if (canRetry) {
        [self retryRequest];
    } else {
        NSError *theError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_CONNECTION_FAILURE description:BMLocalizedString(@"httprequest.error.connectionfailed", @"Connection failed")
                                          underlyingError:error
                             ];
        [self finishedLoadingWithError:theError];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
    BOOL canAuthenticate = NO;
    if (self.shouldAllowSelfSignedCert && [[space authenticationMethod]
                                           isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        canAuthenticate = YES;
    }
    return canAuthenticate;
}

- (NSObject *)cachedObject {
    
    BMURLCache *cache = self.effectiveCache;
    NSData *data = [cache dataForURL:self.urlString];
    return data;
}

- (void)cancelLoading {
    
    BOOL wasIdle = (_loadingStatus == BMAsyncLoadingStatusIdle);
    
    BOOL dequeued = [[self class] dequeueLoader:self startLoadingNext:NO];
    NSArray *otherLoaders = [[self class] popLoader:self];
    
    @synchronized(self) {
        if (_connection) {
            [_connection cancel];
            _connection = nil;
        }
        _request = nil;
        _buffer = nil;
        _tryCount = 0;
        _loadingStatus = BMAsyncLoadingStatusIdle;
    }
    
    if (!wasIdle) {
        if ([self.delegate respondsToSelector:@selector(asyncDataLoaderDidCancelLoading:)]) {
            [self.delegate asyncDataLoaderDidCancelLoading:self];
        }
    }
    
    if (dequeued) {
        //If there were other loaders for the same URL: be sure to queue the next one, otherwise all loaders for the same URL are cancelled.
        for (BMAsyncDataLoader *loader in otherLoaders) {
            if (loader.loadingStatus == BMAsyncLoadingStatusQueued) {
                [[self class] queueLoader:loader withPriority:loader.priority];
                break;
            }
        }
    }
}

- (NSData *)receivedData {
    @synchronized(self) {
        return [NSData dataWithData:_buffer];
    }
}

/**
 Whether the object for the specified URL is on disk, in memory or not cached at all.
 */
- (BMAsyncDataLoaderCacheState)cacheState {
    if ([self.effectiveCache hasDataForURL:self.urlString]) {
        return BMAsyncDataLoaderCacheStateDisk;
    } else {
        return BMAsyncDataLoaderCacheStateNone;
    }
}

@end

@implementation BMAsyncDataLoader(Private)

- (void)appendBufferData:(NSData *)incrementalData {
    @synchronized(self) {
        if (_buffer == nil) {
            _buffer = [[NSMutableData alloc] initWithCapacity:4096];
        }
        [_buffer appendData:incrementalData];
    }
}

- (NSObject *)objectFromBufferData {
    BMURLCache *cache = self.storeToCache ? self.effectiveCache : nil;
    NSObject *theObject = nil;
    @synchronized(self) {
        theObject = [self processData:_buffer forURLString:self.urlString withCache:cache];
    }
    return theObject;
}

- (void)retryRequest {
    @synchronized(self) {
        _buffer = nil;
        _connection = nil;
    }
    [[self class] dequeueLoader:self startLoadingNext:NO];
    LogInfo(@"Retrying request");
    [[self class] queueLoader:self withPriority:YES];
}

- (void)setUrl:(NSURL *)theUrl {
    @synchronized(self) {
        if (theUrl != _url) {
            _url = theUrl;
            _urlString = [_url absoluteString];
        }
    }
}

- (void)startLoadingImpl {
    BOOL startedLoading = NO;
    @synchronized(self) {
        //Just to be sure: clean up connection (should already be done)
        if (_connection) {
            [_connection cancel];
            _connection = nil;
        }
        
        //Queue the loader if non equivalent existed already
        _request = [self requestForURL:self.url];
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
        
        if (_connection) {
            [_connection setDelegateQueue:backgroundOperationQueue];
            [_connection start];
            _loadingStatus = BMAsyncLoadingStatusLoading;
            startedLoading = YES;
        }
    }
    if (startedLoading) {
        [self startedLoading];
    } else {
        NSError *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION
                                           description:@"Could not create connection"];
        [self finishedLoadingWithError:error];
    }
}

- (void)startLoadingImmediately {
    if ([NSThread isMainThread]) {
        id __weak weakSelf = self;
        [self bmPerformBlockInBackground:^id {
            [weakSelf startLoadingImpl];
            return nil;
        }                 withCompletion:nil];
    } else {
        [self startLoadingImpl];
    }
}

+ (NSUInteger)connectionCount {
    @synchronized([BMAsyncDataLoader class]) {
        return [self loaderCountWithPredicate:^BOOL(BMAsyncDataLoader *loader) {
            return loader.loadingStatus == BMAsyncLoadingStatusLoading;
        }];
    }
}

+ (void)addAndQueueLoader:(BMAsyncDataLoader *)loader {
    @synchronized([BMAsyncDataLoader class]) {
        BOOL hasLoader = [self hasLoaderForUrl:loader.url ofClass:[self class]];
        [self addLoader:loader];
        if (!hasLoader) {
            [self queueLoader:loader withPriority:loader.priority];
        }
    }
}

+ (void)queueLoader:(BMAsyncDataLoader *)loader withPriority:(BOOL)priority {
    @synchronized([BMAsyncDataLoader class]) {
        if (loader != nil) {
            if ([self connectionCount] < [self maxConnections]) {
                [loader startLoadingImmediately];
            } else {
                //Queue the loader
                if (priority) {
                    [loaderQueue insertObject:loader atIndex:0];
                } else {
                    [loaderQueue addObject:loader];
                }
            }
        }
    }
}

+ (BOOL)dequeueLoader:(BMAsyncDataLoader *)loader startLoadingNext:(BOOL)startLoadingNext {
    @synchronized([BMAsyncDataLoader class]) {
        BOOL ret = NO;
        if (loader != nil) {
            NSUInteger index = [loaderQueue indexOfObjectIdenticalTo:loader];
            if (index != NSNotFound) {
                //queued connection
                [loaderQueue removeObjectAtIndex:index];
                ret = YES;
            } else if (loader.loadingStatus == BMAsyncLoadingStatusLoading) {
                //active connection
                ret = YES;
            }
            loader.loadingStatus = BMAsyncLoadingStatusIdle;
            
            if (startLoadingNext) {
                while ([self connectionCount] < [self maxConnections] && loaderQueue.count > 0) {
                    BMAsyncDataLoader *nextLoader = [loaderQueue objectAtIndex:0];
                    [loaderQueue removeObjectAtIndex:0];
                    [nextLoader startLoadingImmediately];
                }
            }
        }
        return ret;
    }
}

+ (BOOL)dequeueLoader:(BMAsyncDataLoader *)loader {
    return [self dequeueLoader:loader startLoadingNext:YES];
}

+ (BOOL)hasLoaderForUrl:(NSURL *)theUrl ofClass:(Class)loaderClass {
    @synchronized([BMAsyncDataLoader class]) {
        NSArray *loaders = [urlDataLoaders objectForKey:theUrl];
        BOOL hasLoader = NO;
        for (BMAsyncDataLoader *loader in loaders) {
            if ([loader isMemberOfClass:loaderClass]) {
                hasLoader = YES;
                break;
            }
        }
        if (hasLoader) {
            LogDebug(@"A request is already queued for URL: %@", theUrl);
        }
        return hasLoader;
    }
}

+ (NSMutableArray *)loadersForURL:(NSURL *)url {
    @synchronized([BMAsyncDataLoader class]) {
        NSMutableArray *loaders = [urlDataLoaders objectForKey:url];
        if (!loaders) {
            loaders = BMCreateNonRetainingArray();
            [urlDataLoaders setObject:loaders forKey:url];
        }
        return loaders;
    }
}

+ (NSMutableArray *)loadersForURL:(NSURL *)url ofClass:(Class)loaderClass {
    @synchronized([BMAsyncDataLoader class]) {
        NSMutableArray *loaders = [self loadersForURL:url];
        NSMutableArray *theLoaders = [NSMutableArray arrayWithCapacity:loaders.count];
        for (BMAsyncDataLoader *loader in loaders) {
            if ([loader isMemberOfClass:loaderClass]) {
                [theLoaders addObject:loader];
            }
        }
        return theLoaders;
    }
}

+ (NSUInteger)loaderCountWithPredicate:(BOOL(^)(BMAsyncDataLoader *))predicate {
    @synchronized ([BMAsyncDataLoader class]) {
        NSUInteger ret = 0;
        for (NSArray *loaders in urlDataLoaders.allValues) {
            for (BMAsyncDataLoader *loader in loaders) {
                if (predicate == nil || predicate(loader)) {
                    ret++;
                }
            }
        }
        return ret;
    }
}

+ (void)addLoader:(BMAsyncDataLoader *)loader {
    @synchronized([BMAsyncDataLoader class]) {
        NSMutableArray *loaders = [self loadersForURL:loader.url];
        if (![loaders bmContainsObjectIdenticalTo:loader]) {
            [loaders addObject:loader];
            loader.loadingStatus = BMAsyncLoadingStatusQueued;
        }
    }
}

+ (NSMutableArray *)popLoadersForUrl:(NSURL *)url ofClass:(Class)loaderClass {
    @synchronized([BMAsyncDataLoader class]) {
        NSMutableArray *loaders = [urlDataLoaders objectForKey:url];
        NSArray *loadersArrayCopy = [NSArray arrayWithArray:loaders];
        
        NSMutableArray *theLoaders = [NSMutableArray arrayWithCapacity:loaders.count];
        
        for (BMAsyncDataLoader *loader in loadersArrayCopy) {
            if ([loader isMemberOfClass:loaderClass]) {
                [theLoaders addObject:loader];
                loader.loadingStatus = BMAsyncLoadingStatusIdle;
                [loaders removeObjectIdenticalTo:loader];
            }
        }
        
        if (loaders.count == 0) {
            [urlDataLoaders removeObjectForKey:url];
        }
        
        return theLoaders;
    }
}

+ (NSArray *)popLoader:(BMAsyncDataLoader *)loader {
    @synchronized([BMAsyncDataLoader class]) {
        NSArray *ret = nil;
        NSURL *url = loader.url;
        if (url) {
            NSMutableArray *loaders = [urlDataLoaders objectForKey:url];
            if (loaders) {
                loader.loadingStatus = BMAsyncLoadingStatusIdle;
                [loaders removeObjectIdenticalTo:loader];
                if (loaders.count == 0) {
                    [urlDataLoaders removeObjectForKey:url];
                }
                ret = [NSArray arrayWithArray:loaders];
            }
        }
        return ret;
    }
}

- (void)notifyDelegateWithError:(NSError *)error {
    BMAsyncDataLoader *__weak weakSelf = self;
    [self bmPerformBlockOnMainThread:^{
        [weakSelf.delegate asyncDataLoader:weakSelf didFinishLoadingWithError:error];
    }];
}

- (NSArray *)cleanup {
    @synchronized(self) {
        //Autorelease the buffer because the buffer might equal the object returned
        _buffer = nil;
        _request = nil;
        _connection = nil;
    }
    [[self class] dequeueLoader:self];
    
    NSMutableArray *ret = [[self class] popLoadersForUrl:self.url ofClass:[self class]];
    if (![ret bmContainsObjectIdenticalTo:self]) {
        [ret addObject:self];
    }
    return ret;
}

- (void)startedLoading {
    NSMutableArray *theLoaders = [[self class] loadersForURL:self.url ofClass:[self class]];
    for (BMAsyncDataLoader *loader in theLoaders) {
        if ([loader.delegate respondsToSelector:@selector(asyncDataLoaderDidStartLoading:)]) {
            [loader bmPerformBlockOnMainThread:^{
                if (loader.loadingStatus == BMAsyncLoadingStatusLoading) {
                    [loader.delegate asyncDataLoaderDidStartLoading:loader];
                }
            }];
        }
    }
}

- (void)finishedLoadingWithError:(NSError *)error {
    NSArray *loaders = [self cleanup];
    for (BMAsyncDataLoader *loader in loaders) {
        [loader notifyDelegateWithError:error];
    }
    
}

- (void)finishedLoadingWithObject:(NSObject *)theObject {
    NSArray *loaders = [self cleanup];
    for (BMAsyncDataLoader *loader in loaders) {
        loader.object = theObject;
        [loader notifyDelegateWithError:nil];
    }
}

@end

@implementation BMAsyncDataLoader(Protected)

- (void)setObject:(nullable id)object {
    _object = object;
}

- (BOOL)validateURL:(NSURL *)theUrl {
    return theUrl != nil;
}

- (BMURLCache *)effectiveCache {
    BMURLCache *theCache = self.cache;
    if (!theCache) {
        theCache = [[self class] defaultCache];
    }
    return theCache;
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)theURL {
    return [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.connectionTimeOut];
}

- (BOOL)isSuccessfulResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        return httpResponse.statusCode == HTTP_STATUS_OK;
    } else {
        return YES;
    }
}

- (NSObject *)objectFromData:(NSData *)theData withCache:(BMURLCache *)cache cacheKey:(NSString *)cacheKey {
    return theData ? theData : [NSData data];
}

@end

