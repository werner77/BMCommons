//
//  BMURLProtocol.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/05/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCachingURLProtocol.h>
#import "BMCachingURLProtocol.h"
#import "NSObject+BMCommons.h"
#import "NSDateFormatter+BMCommons.h"
#import "BMLogging.h"
#import "BMDateHelper.h"
#import "BMHTTPRequest.h"
#import "BMCore.h"
#import "BMCache.h"
#import "NSDictionary+BMCommons.h"
#import "BMDataRecorder.h"
#import "NSData+BMEncryption.h"
#import "BMErrorHelper.h"
#import "NSCondition+BMCommons.h"
#import "NSHTTPURLResponse+BMCommons.h"

@interface BMCachedURLResponse : NSObject <NSCoding, NSCopying>

- (instancetype)initWithResponse:(NSURLResponse *)response data:(NSData *)data timeout:(NSTimeInterval)timeout;

- (NSString *)description;

@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, strong) NSData *data;

@end


@implementation BMCachedURLResponse

static NSString* const kBMURLCachingEnabledKey = @"BMURLCachingEnabled";
static NSString* const kBMURLProtocolEnabledKey = @"BMURLProtocolEnabled";

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        self.response = [coder decodeObjectForKey:@"response"];
        self.data = [coder decodeObjectForKey:@"data"];
        self.timeout = [coder decodeDoubleForKey:@"timeout"];
    }
    return self;
}

- (instancetype)initWithResponse:(NSURLResponse *)response data:(NSData *)data timeout:(NSTimeInterval)timeout {
    if ((self = [self init])) {
        self.response = response;
        self.data = data;
        self.timeout = timeout;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BMCachedURLResponse *copy = [[self class] allocWithZone:zone];
    copy.response = [self.response copy];
    copy.data = [self.data copy];
    copy.timeout = self.timeout;
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.response forKey:@"response"];
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeDouble:self.timeout forKey:@"timeout"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    NSStringEncoding contentEncoding = [[self.response bmCastSafely:NSHTTPURLResponse.class] bmContentCharacterEncoding];
    id dataValue = contentEncoding == 0 ? self.data : [[NSString alloc] initWithData:self.data encoding:contentEncoding];
    [description appendFormat:@"\nself.response=%@", [self.response bmPrettyDescription]];
    [description appendFormat:@"\nself.timeout=%lf", self.timeout];
    [description appendFormat:@"\nself.data=%@", [dataValue bmPrettyDescription]];
    [description appendString:@"\n>"];
    return description;
}

@end


@interface BMCachingURLProtocol()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;

@end

@implementation BMCachingURLProtocol

static NSString * const kBMURLProtocolHandledKey = @"BMURLProtocolHandledKey";
static NSString * const kBMURLProtocolHashParameter = @"BMURLHash";

static NSArray *includedHeaderKeysForCacheEquivalence = nil;
static NSArray *excludedHeaderKeysForCacheEquivalence = nil;
static BOOL includeBodyForCacheEquivalence = YES;
static BOOL defaultCachingEnabled = YES;
static BOOL honorHTTPCacheHeaders = YES;
static NSInteger connectionCount = 0;
static BOOL mockConnectionFailureIfPlaybackFails = YES;
static BMCachingURLProtocolPredicateBlock canInitWithProtocolBlock = nil;
static BMCachingURLProtocolPredicateBlock cachingEnabledBlock = nil;

NSString * const BMCachingURLProtocolWillSendURLRequestNotification = @"BMCachingURLProtocolWillSendURLRequestNotification";
NSString * const BMCachingURLProtocolDidSendURLRequestNotification = @"BMCachingURLProtocolDidSendURLRequestNotification";
NSString * const BMCachingURLProtocolDidReceiveURLResponseNotification = @"BMCachingURLProtocolDidReceiveURLResponseNotification";
NSString * const BMCachingURLProtocolURLRequestKey = @"BMCachingURLProtocolURLRequestKey";
NSString * const BMCachingURLProtocolURLResponseKey = @"BMCachingURLProtocolURLResponseKey";

+ (void)setProtocolEnabledPredicateBlock:(BMCachingURLProtocolPredicateBlock)block {
    @synchronized([BMCachingURLProtocol class]) {
        canInitWithProtocolBlock = [block copy];
    }
}

+ (BMCachingURLProtocolPredicateBlock)protocolEnabledPredicateBlock {
    @synchronized([BMCachingURLProtocol class]) {
        return canInitWithProtocolBlock;
    }
}

+ (void)setCachingEnabledPredicateBlock:(BMCachingURLProtocolPredicateBlock)block {
    @synchronized([BMCachingURLProtocol class]) {
        cachingEnabledBlock = [block copy];
    }
}

+ (BMCachingURLProtocolPredicateBlock)cachingEnabledPredicateBlock {
    @synchronized([BMCachingURLProtocol class]) {
        return cachingEnabledBlock;
    }
}


+ (void)setCachingEnabledByDefault:(BOOL)defaultEnabled {
    @synchronized([BMCachingURLProtocol class]) {
        defaultCachingEnabled = defaultEnabled;
    }
}

+ (BOOL)isCachingEnabledByDefault {
    @synchronized([BMCachingURLProtocol class]) {
        return defaultCachingEnabled;
    }
}

+ (void)setIncludedHeaderKeysForCacheEquivalence:(NSArray *)headerKeys {
    @synchronized([BMCachingURLProtocol class]) {
        includedHeaderKeysForCacheEquivalence = [headerKeys copy];
    }
}

+ (void)setExcludedHeaderKeysForCacheEquivalence:(NSArray *)headerKeys {
    @synchronized([BMCachingURLProtocol class]) {
        excludedHeaderKeysForCacheEquivalence = [headerKeys copy];
    }
}

+ (void)setIncludeBodyForCacheEquivalence:(BOOL)includeBody {
    @synchronized([BMCachingURLProtocol class]) {
        includeBodyForCacheEquivalence = includeBody;
    }
}

+ (NSArray *)includedHeaderKeysForCacheEquivalence {
    @synchronized([BMCachingURLProtocol class]) {
        return includedHeaderKeysForCacheEquivalence;
    }
}

+ (NSArray *)excludedHeaderKeysForCacheEquivalence {
    @synchronized([BMCachingURLProtocol class]) {
        return excludedHeaderKeysForCacheEquivalence;
    }
}

+ (BOOL)includeBodyForCacheEquivalence {
    @synchronized([BMCachingURLProtocol class]) {
        return includeBodyForCacheEquivalence;
    }
}

+ (void)setHonorHTTPCacheHeaders:(BOOL)honorCacheHeaders {
    @synchronized([BMCachingURLProtocol class]) {
        honorHTTPCacheHeaders = honorCacheHeaders;
    }
}

+ (BOOL)honorHTTPCacheHeaders {
    @synchronized([BMCachingURLProtocol class]) {
        return honorHTTPCacheHeaders;
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL enabled = [NSURLProtocol propertyForKey:kBMURLProtocolHandledKey inRequest:request] == nil;
    if (enabled) {
        enabled = [self isProtocolEnabledForRequest:request];
    }
    return enabled;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)setProtocolEnabled:(BOOL)protocolEnabled forRequest:(NSMutableURLRequest *)request {
    [NSURLProtocol setProperty:@(protocolEnabled) forKey:kBMURLProtocolEnabledKey inRequest:request];
}

+ (BOOL)isProtocolEnabledForRequest:(NSURLRequest *)request {
    //Default is enabled
    BOOL enabled = YES;
    NSNumber *n = [NSURLProtocol propertyForKey:kBMURLProtocolEnabledKey inRequest:request];
    BMCachingURLProtocolPredicateBlock block = [self protocolEnabledPredicateBlock];
    if (n) {
        enabled = [n boolValue];
    } else if (block) {
        BMCachingURLProtocolPredicateValue predicateValue = block(request);
        if (predicateValue == BMCachingURLProtocolPredicateValueYES) {
            enabled = YES;
        } else if (predicateValue == BMCachingURLProtocolPredicateValueNO) {
            enabled = NO;
        }
    }
    return enabled;
}

+ (void)setCachingEnabled:(BOOL)enabled forRequest:(NSMutableURLRequest *)request {
    [NSURLProtocol setProperty:@(enabled) forKey:kBMURLCachingEnabledKey inRequest:request];
}

+ (BOOL)isCachingEnabledForRequest:(NSURLRequest *)request {
    NSNumber *n = [NSURLProtocol propertyForKey:kBMURLCachingEnabledKey inRequest:request];
    BOOL enabled = [self isCachingEnabledByDefault];
    BMCachingURLProtocolPredicateBlock block = [self cachingEnabledPredicateBlock];
    if (n) {
        enabled = [n boolValue];
    } else if (block) {
        BMCachingURLProtocolPredicateValue predicateValue = block(request);
        if (predicateValue == BMCachingURLProtocolPredicateValueYES) {
            enabled = YES;
        } else if (predicateValue == BMCachingURLProtocolPredicateValueNO) {
            enabled = NO;
        }
    }
    return enabled;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    if (a == b) {
        return YES;
    }

    NSString *hash1 = [self digestForRequest:a];
    NSString *hash2 = [self digestForRequest:b];
    return hash1 == hash2 || [hash1 isEqual:hash2];
}

+ (BOOL)isCachedResponseValid:(BMCachedURLResponse *)cachedResponse withAttributes:(BMFileAttributes *)attributes {
    BOOL valid = cachedResponse.data != nil;
    valid = valid && attributes != nil && ![attributes isExpiredWithInterval:cachedResponse.timeout];
    return valid;
}

+ (NSString *)digestForRequest:(NSURLRequest *)request {
    NSString *hash = nil;
    if (request != nil) {
        NSArray *includeKeys = [self.class includedHeaderKeysForCacheEquivalence];
        NSArray *excludeKeys = [self.class excludedHeaderKeysForCacheEquivalence];
        BOOL includeBody = [self.class includeBodyForCacheEquivalence];
        if (includeKeys != nil) {
            hash = [request bmDigestByIncludingHeaders:includeKeys includeBody:includeBody];
        } else {
            hash = [request bmDigestByExcludingHeaders:excludeKeys includeBody:includeBody];
        }
    }
    return hash;
}

- (void)startLoading {
    if (![self loadCachedResponse]) {
        BMDataRecorder *recorder = self.class.recorder;
        if (recorder.isPlayingBack && [self.class mockConnectionFailureIfPlaybackFails]) {
            //Fake connection error in this case
            NSError *mockError = [BMErrorHelper errorForDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost description:@"Mock error generated by playback mode of BMCachingURLProtocol"];
            [self.client URLProtocol:self didFailWithError:mockError];
        } else {
            NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
            if (mutableRequest != nil) {
                [NSURLProtocol setProperty:@YES forKey:kBMURLProtocolHandledKey inRequest:mutableRequest];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:mutableRequest forKey:BMCachingURLProtocolURLRequestKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:BMCachingURLProtocolWillSendURLRequestNotification object:self
                                                                  userInfo:userInfo];
                self.connection = [NSURLConnection connectionWithRequest:mutableRequest delegate:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:BMCachingURLProtocolDidSendURLRequestNotification object:self
                                                                  userInfo:userInfo];
            }
        }
    }
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
    self.response = nil;
    self.mutableData = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    self.response = response;
    self.mutableData = [NSMutableData new];

    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo bmSafeSetObject:self.request forKey:BMCachingURLProtocolURLRequestKey];
    [userInfo bmSafeSetObject:self.response forKey:BMCachingURLProtocolURLResponseKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:BMCachingURLProtocolDidReceiveURLResponseNotification object:self
                                                      userInfo:userInfo];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    [self saveCachedResponse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    NSURLRequest *ret = request;

    if (response != nil) {
        NSMutableURLRequest *redirect = [request mutableCopy];
        [NSURLProtocol removePropertyForKey:kBMURLProtocolHandledKey inRequest:redirect];
        [self.client URLProtocol:self wasRedirectedToRequest:redirect redirectResponse:response];
        ret = nil;
    }

    return ret;
}

#pragma mark - Private

- (void)setConnection:(NSURLConnection *)connection {
    if (_connection != connection) {
        NSURLConnection *oldConnection = _connection;
        _connection = connection;
        if (oldConnection == nil) {
            [self.class incrementConnectionCount];
        } else if (connection == nil) {
            [self.class decrementConnectionCount];
        }
    }
}

+ (void)incrementConnectionCount {
    @synchronized (BMCachingURLProtocol.class) {
        [[self loadingCondition] bmBroadcastForPredicateModification:^{
            connectionCount++;
        }];
    }
}

+ (void)decrementConnectionCount {
    @synchronized (BMCachingURLProtocol.class) {
        [[self loadingCondition] bmBroadcastForPredicateModification:^{
            if (connectionCount > 0) {
                connectionCount--;
            }
        }];
    }
}

+ (NSInteger)connectionCount {
    @synchronized (BMCachingURLProtocol.class) {
        return connectionCount;
    }
}

+ (BOOL)isLoading {
    return [self connectionCount] > 0;
}

+ (NSCondition *)loadingCondition {
    static NSCondition *loadingCondition = nil;
    BM_DISPATCH_ONCE(^{
        loadingCondition = [NSCondition new];
    });
    return loadingCondition;
}

+ (void)waitUntilLoadingFinishedWithCompletion:(void (^)(BOOL loadingFinished, BOOL waited))completion timeout:(NSTimeInterval)timeout {
    NSCondition *loadingCondition = [self loadingCondition];
    [loadingCondition bmWaitForPredicate:^BOOL {
        return ![self isLoading];
    } timeout:timeout completion:completion];
}

- (BOOL)loadCachedResponse {
    BOOL ret = NO;
    BOOL cachingEnabled = [self.class isCachingEnabledForRequest:self.request];
    BOOL playbackEnabled = self.class.recorder.isPlayingBack;

    if (cachingEnabled || playbackEnabled) {
        NSString *cacheKey = self.cacheKey;
        BMURLCache *urlCache = self.urlCache;
        BMFileAttributes *dataFileAttributes = nil;
        BMCachedURLResponse *cachedResponse = nil;
        BOOL playbackResponse = NO;

        if (playbackEnabled) {
            @try {
                cachedResponse = [self.class.recorder recordedResultForRecordingClass:[self.class recordingClassIdentifier] withDigest:cacheKey];
                playbackResponse = YES;
            } @catch (NSException *exception) {
                LogWarn(@"Could not load recorded response: %@", exception);
            }
        } else {
            NSData *data = [urlCache dataForKey:cacheKey];
            if (data != nil) {
                @try {
                    cachedResponse = [[NSKeyedUnarchiver unarchiveObjectWithData:data] bmCastSafely:[BMCachedURLResponse class]];
                }
                @catch (NSException *exception) {
                    LogWarn(@"Could not load cached response: %@", exception);
                    //Could not deserialze cachedResponse, remove it from cache
                    [urlCache removeKey:cacheKey fromDisk:YES];
                }
            }
        }

        if (cachedResponse) {
            dataFileAttributes = [urlCache fileAttributesForKey:cacheKey];
            if (playbackResponse || [self.class isCachedResponseValid:cachedResponse withAttributes:dataFileAttributes]) {
                ret = YES;

                NSData *responseData = cachedResponse.data;
                NSURLResponse *response = [cachedResponse response];

                [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self didLoadData:responseData];
                [self.client URLProtocolDidFinishLoading:self];
            } else {
                [urlCache removeKey:cacheKey fromDisk:YES];
            }
        } else if (playbackEnabled) {
            LogWarn(@"Could not load cached response with digest '%@' for following request:\n--------------------\n%@--------------------\n", cacheKey, [self fullDescriptionForRequest:self.request]);
        }
    }

    return ret;
}

- (NSString *)fullDescriptionForRequest:(NSURLRequest *)request {
    return [request bmRawDescription];
}

- (NSString *)cacheKey {
    return [self.class digestForRequest:self.request];
}

+ (BMURLCache *)cache {
    static BMURLCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [BMURLCache cacheWithName:NSStringFromClass([BMCachingURLProtocol class])];
        cache.imageCacheEnabled = NO;
        cache.diskCacheEnabled = YES;
        cache.maxDiskSpace = 100 * 1024 * 1024;
    });
    return cache;
}

- (BMURLCache *)urlCache {
    return [[self class] cache];
}

- (void)saveCachedResponse {
    BOOL cachingEnabled = [self.class isCachingEnabledForRequest:self.request];
    BMDataRecorder *recorder = self.class.recorder;
    BOOL recordingEnabled = recorder.isRecording;
    if (cachingEnabled || recordingEnabled) {
        NSURLResponse *response = self.response;
        BMURLCache *urlCache = self.urlCache;
        NSTimeInterval timeout = 0;
        NSString *httpMethod = [self.request.HTTPMethod uppercaseString];
        if ([self.class honorHTTPCacheHeaders]) {
            if ([httpMethod isEqualToString:BM_HTTP_METHOD_GET] || [httpMethod isEqualToString:BM_HTTP_METHOD_POST]) {
                timeout = [self.class expirationTimeForResponse:response];
            }
        } else if ([httpMethod isEqualToString:BM_HTTP_METHOD_GET]) {
            //Only allow caching of GET requests otherwise
            timeout = urlCache.invalidationAge;
        }

        BMCachedURLResponse *cachedResponse = nil;
        if (recordingEnabled || timeout > 0) {
            cachedResponse = [[BMCachedURLResponse alloc] initWithResponse:response data:self.mutableData timeout:timeout];
        }

        NSString *cacheKey = self.cacheKey;
        if (timeout > 0) {
            @try {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cachedResponse];
                [urlCache storeData:data forKey:cacheKey invalidationAge:timeout];
            }
            @catch (NSException *exception) {
                LogWarn(@"Could not save cached response: %@", exception);
            }
        }

        if (recordingEnabled) {
            @try {
                [recorder recordResult:cachedResponse forRecordingClass:[self.class recordingClassIdentifier] withDigest:cacheKey];

                LogDebug(@"Saved cached response with digest '%@' for following request:\n--------------------\n%@--------------------\n", cacheKey, [self fullDescriptionForRequest:self.request]);

                [recorder writeToRecordingLog:[NSString stringWithFormat:@"Recorded response for request with digest '%@':\n\nRequest:\n\n%@\nResponse:\n\n%@", cacheKey, [self fullDescriptionForRequest:self.request], cachedResponse]];

            } @catch (NSException *exception) {
                LogWarn(@"Could not save recorded response: %@", exception);
            }
        }
    }
}

+ (NSTimeInterval)expirationTimeForResponse:(NSURLResponse *)response {
    NSTimeInterval expirationTime = 0;

    BOOL parsed = NO;
    NSHTTPURLResponse *httpResponse = [response bmCastSafely:[NSHTTPURLResponse class]];

    NSDictionary *cacheHeaderDictionary = [self valuesForHTTPHeaderKey:@"Cache-Control" fromResponse:httpResponse];
    for (NSString *key in @[@"no-cache", @"no-store", @"s-maxage", @"max-age"]) {
        id value = [cacheHeaderDictionary objectForKey:key];

        BOOL present = value != nil;
        if (value == [NSNull null]) {
            value = nil;
        }

        if ([key isEqualToString:@"no-cache"] && present) {
            //No caching
            parsed = YES;
        } else if ([key isEqualToString:@"no-store"] && present) {
            //No caching
            parsed = YES;
        } else if ([key isEqualToString:@"s-maxage"] && value != nil) {
            expirationTime = [value doubleValue];
            parsed = YES;
        } else if ([key isEqualToString:@"max-age"] && value != nil) {
            expirationTime = [value doubleValue];
            parsed = YES;
        }

        if (parsed) {
            break;
        }
    }

    if (!parsed) {
        NSString *expiresValue = [self valueForHTTPHeaderKey:@"Expires" fromResponse:httpResponse];

        if (expiresValue) {
            @try {
                NSDate *expiryDate = [[BMDateHelper rfc1123DateFormatter] bmDateByParsingFromString:expiresValue];
                if (expiryDate) {
                    expirationTime = [expiryDate timeIntervalSinceNow];
                    parsed = YES;
                }
            } @catch(NSException *exception) {
                LogDebug(@"Could not parse expiration date: %@", exception);
            }
        }
    }
    return expirationTime;
}

+ (NSString *)valueForHTTPHeaderKey:(NSString *)headerKey fromResponse:(NSHTTPURLResponse *)response {
    if (headerKey == nil) {
        return nil;
    }

    NSDictionary *headerFields = [response allHeaderFields];
    NSString *headerValue = [headerFields objectForKey:headerKey];
    if (headerValue == nil) {
        headerValue = [headerFields objectForKey:[headerKey lowercaseString]];
    }
    return headerValue;
}

+ (NSDictionary *)valuesForHTTPHeaderKey:(NSString *)headerKey fromResponse:(NSHTTPURLResponse *)response {

    NSString *headerValue = [self valueForHTTPHeaderKey:headerKey fromResponse:response];

    if (headerValue == nil) {
        return nil;
    }

    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *components = [headerValue componentsSeparatedByString:@","];
    for (NSString *component in components) {
        NSArray *valueComponents = [component componentsSeparatedByString:@"="];

        NSString *key = [[[valueComponents firstObject] lowercaseString] stringByTrimmingCharactersInSet:whitespaceSet];
        NSString *valueString = valueComponents.count > 1 ? valueComponents[1] : nil;
        id value = [[valueString lowercaseString] stringByTrimmingCharactersInSet:whitespaceSet];

        if (value == nil) {
            value = [NSNull null];
        }
        if (key != nil && value != nil && [ret objectForKey:key] == nil) {
            [ret setObject:value forKey:key];
        }
    }
    return ret;
}

#pragma mark - Recording/Playback

+ (BMDataRecorder *)recorder {
    static BMDataRecorder *recorder = nil;
    BM_DISPATCH_ONCE(^{
        recorder = [BMDataRecorder new];
    });
    return recorder;
}

+ (BOOL)mockConnectionFailureIfPlaybackFails {
    @synchronized([BMCachingURLProtocol class]) {
        return mockConnectionFailureIfPlaybackFails;
    }
}

+ (void)setMockConnectionFailureIfPlaybackFails:(BOOL)b {
    @synchronized([BMCachingURLProtocol class]) {
        mockConnectionFailureIfPlaybackFails = b;
    }
}

+ (NSString *)recordingClassIdentifier {
    return @"BMCachedURLResponse";
}

@end
