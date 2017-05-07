//
//  BMHTTPService.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPService.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMURLCache.h>
#import "NSObject+BMCommons.h"
#import <BMCommons/BMCore.h>

@interface BMHTTPService()

@property (assign) BOOL cacheHit;
@property (strong) NSString *cacheURLUsed;
@property (strong) BMHTTPRequest *request;
@property (assign) BOOL startedFromMainThread;

@end

@implementation BMHTTPService {
}

@synthesize readCacheEnabled = _readCacheEnabled, writeCacheEnabled = _writeCacheEnabled, loadCachedResultOnError = _loadCachedResultOnError, cacheURLUsed = _cacheURLUsed;
@synthesize cacheHit = _cacheHit;

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)dealloc {
	self.context = nil;
	self.request.delegate = nil;
}

- (void)cancel {
    self.cacheHit = NO;
	self.request.delegate = nil;
	[self.request cancel];
	self.request = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super cancel];
}

- (BOOL)executeWithError:(NSError **)error {
    self.startedFromMainThread = [NSThread isMainThread];
	self.request.delegate = nil;
    self.cacheHit = NO;
	self.request = nil;
    self.cacheURLUsed = nil;
	BMHTTPRequest *theRequest = [self requestForServiceWithError:error];
    
    if (!theRequest) {
        if (error && *error == nil) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_NO_REQUEST description:@"Request could not be created"];
        }
        return NO;
    } else {
        BOOL foundInCache = NO;
        self.request = theRequest;
        theRequest.delegate = self;

        if (self.readCacheEnabled) {
            foundInCache = [self loadCachedResultForRequest:theRequest];
        }
        if (!foundInCache) {
            [theRequest send];
        }
        return YES;
    }
}


- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
	return nil;
}

- (id)resultFromRequest:(BMHTTPRequest *)theRequest {
	return nil;
}

- (NSError *)errorFromRequest:(BMHTTPRequest *)theRequest {
	return theRequest.lastError;
}

- (void)failedWithError:(NSError *)error {
	[self.delegate service:self failedWithError:error];
}

- (void)serviceSucceededWithRawResult:(id)result {
	self.request.delegate = nil;
	self.request = nil;
	[super serviceSucceededWithRawResult:result];
}

- (void)serviceFailedWithRawError:(NSError *)error {
	self.request.delegate = nil;
	self.request = nil;
	[super serviceFailedWithRawError:error];
}

#pragma mark -
#pragma mark RequestDelegate implementation

- (void)requestSucceeded:(BMHTTPRequest *)theRequest {
	//Parse
    if (self.parseInBackgroundThread && [NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(handleResponseFromRequest:) withObject:theRequest];
    } else {
        [self handleResponseFromRequest:theRequest];
    }
}

- (void)requestFailed:(BMHTTPRequest *)theRequest {
    if (self.parseInBackgroundThread && [NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(handleErrorFromRequest:) withObject:theRequest];
    } else {
        [self handleErrorFromRequest:theRequest];
    }
}

#pragma mark - Caching

- (void)setCachingEnabled:(BOOL)enabled {
    self.readCacheEnabled = enabled;
    self.writeCacheEnabled = enabled || self.writeCacheEnabled;
    self.loadCachedResultOnError = enabled;
}

/**
 * Gets the result from the cache, if it exists.
 */
- (id)resultFromCache {
    BMHTTPRequest *theRequest = [self requestForServiceWithError:nil];
    return [self cachedResultForRequest:theRequest];
}

/**
 * Should return the url cache to use for caching data.
 * Default is the shared instance.
 */
+ (BMURLCache *)urlCache {
    return [BMURLCache sharedCache];
}

- (NSString *)URLFromRequest:(BMHTTPRequest *)theRequest {
	return [theRequest.url absoluteString];
}

- (BOOL)ignoreCacheForRequest:(BMHTTPRequest *)theRequest {
    return ![theRequest.request.HTTPMethod isEqual:BM_HTTP_METHOD_GET];
}

#pragma mark - Private

- (BOOL)hasCachedDataForRequest:(BMHTTPRequest *)theRequest withUrl:(NSString **)urlOut {
    BOOL ret = NO;
    NSString *url = nil;
    if (![self ignoreCacheForRequest:theRequest]) {
        url = [self URLFromRequest:theRequest];
        ret = [self.class.urlCache hasDataForURL:url];
    }
    if (urlOut) {
        *urlOut = ret ? url : nil;
    }
    return ret;
}

- (BOOL)loadCachedResultForRequest:(BMHTTPRequest *)theRequest {
    BOOL ret = [self hasCachedDataForRequest:theRequest withUrl:nil];
    if (ret) {
        if ([NSThread isMainThread]) {
            [self performSelectorInBackground:@selector(loadCachedResultAndNotifyForRequest:) withObject:theRequest];
        } else {
            [self loadCachedResultAndNotifyForRequest:theRequest];
        }
    }
    return ret;
}

- (void)loadCachedResultAndNotifyForRequest:(BMHTTPRequest *)theRequest {
    if (!self.isCancelled) {
        id result = [self cachedResultForRequest:theRequest];
        __typeof(self) __weak weakSelf = self;
        if (result) {
            self.cacheHit = YES;

            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf serviceSucceededWithRawResult:result];
                }];
            } else {
                [self serviceSucceededWithRawResult:result];
            }
        } else {
            //Result is not valid: revert to loading the data remotely
            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf.request send];
                }];
            } else {
                [self.request send];
            }
        }
    }
}

- (id)cachedResultForRequest:(BMHTTPRequest *)theRequest {
    @synchronized(self) {
        id result = nil;
        NSString *key = nil;
        BOOL hasCachedData = [self hasCachedDataForRequest:theRequest withUrl:&key];
        
        if (hasCachedData) {
            BMURLCache *cache = self.class.urlCache;
            NSData *data = [cache dataForURL:key];
            @try {
                result = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
                if (result == nil && data != nil) {
                    LogWarn(@"Data from cache could not be deserialized: removing");
                    [cache removeURL:key fromDisk:YES];
                }
            }
            @catch (NSException *exception) {
                LogWarn(@"Could not unarchive data from cache: %@", exception);
                [cache removeURL:key fromDisk:YES];
            }
        }
        
        if (result) {
            self.cacheURLUsed = key;
        }
        return result;
    }
}

- (void)setCachedResult:(id)result forRequest:(BMHTTPRequest *)theRequest {
    @synchronized(self) {
        if (result && [result conformsToProtocol:@protocol(NSCoding)] && ![self ignoreCacheForRequest:theRequest]) {
            NSString *key = [self URLFromRequest:theRequest];
            
            NSData *data = nil;
            @try {
                data = [NSKeyedArchiver archivedDataWithRootObject:result];
            }
            @catch (NSException *exception) {
                LogWarn(@"Could not archive data for caching: %@", exception);
            }
            if (key && data) {
                self.cacheURLUsed = key;
            }
            if (data) {
                [self.class.urlCache storeData:data forURL:key];
            }
        }
    }
}

- (void)handleResponseFromRequest:(BMHTTPRequest *)theRequest {
    if (!self.isCancelled) {
        id result = [self resultFromRequest:theRequest];
        NSError *error = nil;
        if (!result) {
            //Check if there is an error
            error = [self errorFromRequest:theRequest];
        }

        __typeof(self) __weak weakSelf = self;
        if (error) {
            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf serviceFailedWithRawError:error];
                }];
            } else {
                [self serviceFailedWithRawError:error];
            }
        } else {
            if (self.writeCacheEnabled && result && [result conformsToProtocol:@protocol(NSCoding)] && theRequest && ![self ignoreCacheForRequest:theRequest]) {
                if ([NSThread isMainThread]) {
                    [self performSelectorInBackground:@selector(storeCachedResult:) withObject:@[result, theRequest]];
                } else {
                    [self setCachedResult:result forRequest:theRequest];
                }
            }

            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf serviceSucceededWithRawResult:result];
                }];
            } else {
                [self serviceSucceededWithRawResult:result];
            }
        }
    }
}

- (void)storeCachedResult:(NSArray *)params {
    if (!self.isCancelled) {
        id result = [params objectAtIndex:0];
        BMHTTPRequest *theRequest = [params objectAtIndex:1];
        [self setCachedResult:result forRequest:theRequest];
    }
}

- (void)handleErrorFromRequest:(BMHTTPRequest *)theRequest {
    if (!self.isCancelled) {
        //Return
        id result = nil;
        if (self.loadCachedResultOnError) {
            result = [self cachedResultForRequest:theRequest];
        }
        __typeof(self) __weak weakSelf = self;
        if (result) {
            self.cacheHit = YES;
            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf serviceSucceededWithRawResult:result];
                }];
            } else {
                [self serviceSucceededWithRawResult:result];
            }

        } else {
            NSError *error = [self errorFromRequest:theRequest];
            if (self.startedFromMainThread) {
                [NSObject bmPerformBlockOnMainThread:^{
                    [weakSelf serviceFailedWithRawError:error];
                }];
            } else {
                [self serviceFailedWithRawError:error];
            }
        }
    }
}

@end



