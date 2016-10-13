//
//  BMServiceModel.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMServiceModel.h"
#import <BMCore/BMServiceManager.h>
#import <BMCore/BMURLCache.h>
#import <BMCore/BMErrorHelper.h>
#import <BMMedia/BMMedia.h>

@implementation BMServiceModel {
    NSDate *_loadedTime;
    NSString *_cacheKey;
    id <BMService> _service;
    
    BOOL _isLoadingMore;
    BOOL _isLoading;
    
    float _progressPercentage;
}

@synthesize loadedTime = _loadedTime;
@synthesize cacheKey = _cacheKey;
@synthesize service = _service;

- (BMServiceManager *)serviceManager {
    return [BMServiceManager sharedInstance];
}

- (id)init {
    if ((self = [super init])) {
        BMMediaCheckLicense();
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [self.serviceManager cancelServiceInstancesForDelegate:self];
    [self.serviceManager removeServiceDelegate:self];
    BM_RELEASE_SAFELY(_loadedTime);
    BM_RELEASE_SAFELY(_cacheKey);
    BM_RELEASE_SAFELY(_service);
}

#pragma mark-
#pragma mark BMServiceDelegate

- (void)serviceDidStart:(id <BMService>)service {
    _progressPercentage = 0.0f;
    _isLoading = YES;
    [self didStartLoad];
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    _isLoading = NO;
    [self didFailLoadWithError:error];
}

- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    if (!self.isLoadingMore) {
        _loadedTime = [NSDate date];
        if ([service conformsToProtocol:@protocol(BMCachedService)]) {
            self.cacheKey = [(id <BMCachedService>) service cacheURLUsed];
        } else {
            self.cacheKey = nil;
        }
    }

    _isLoading = NO;
    [self didFinishLoad];
}

- (void)serviceWasCancelled:(id <BMService>)service {
    _isLoading = NO;
    [self didCancelLoad];
}

- (void)service:(id <BMService>)service updatedProgress:(double)progressPercentage withMessage:(NSString *)message {
    _progressPercentage = (float) progressPercentage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
    return !!_loadedTime;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
    return _isLoading;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
    return _isLoading && _isLoadingMore;
}

- (BOOL)canLoad:(BOOL)more {
    return self.service != nil && !self.isLoading;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
    if (nil == _cacheKey) {
        return nil == _loadedTime;
    } else {
        NSDate *loadedTime = self.loadedTime;
        if (nil != loadedTime) {
            return ![[BMURLCache sharedCache] hasDataForURL:_cacheKey];
        } else {
            return YES;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(BMTTURLRequestCachePolicy)cachePolicy more:(BOOL)more {

    if (!self.service) {
        LogWarn(@"No service set, cannot load");
    } else if (_isLoading) {
        LogWarn(@"Already performing service, ignoring request");
    } else {
        //TODO: support the other enum values of TTURLRequestCachePolicy
        if ([self.service conformsToProtocol:@protocol(BMCachedService)]) {
            id <BMCachedService> parserService = (id <BMCachedService>)self.service;
            parserService.readCacheEnabled = (cachePolicy & BMTTURLRequestCachePolicyMemory) ||
                    (cachePolicy & BMTTURLRequestCachePolicyDisk);
            parserService.writeCacheEnabled = !(cachePolicy & BMTTURLRequestCachePolicyNoCache);
        }
        _isLoadingMore = more;

        [self prepareService:self.service forLoadingWithMoreResults:more];

        [self.serviceManager performService:self.service withDelegate:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
    if (_isLoading && self.service) {
        [self.serviceManager cancelServiceWithInstanceIdentifier:self.service.instanceIdentifier];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
    if (nil != _cacheKey) {
        if (erase) {
            [[BMURLCache sharedCache] removeURL:_cacheKey fromDisk:YES];

        } else {
            [[BMURLCache sharedCache] invalidateURL:_cacheKey];
        }

        BM_RELEASE_SAFELY(_cacheKey);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reset {
    BM_RELEASE_SAFELY(_cacheKey);
    BM_RELEASE_SAFELY(_loadedTime);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (float)downloadProgress {
    if ([self isLoading]) {
        return _progressPercentage;
    }
    return 0.0f;
}

- (void)setService:(id <BMService>)theService {
    if (_service != theService) {
        [self cancel];
        _service = theService;
    }
}

@end

@implementation BMServiceModel(Protected)

#pragma mark -
#pragma mark Protected methods

- (void)prepareService:(id <BMService>)theService forLoadingWithMoreResults:(BOOL)more {
    
}

@end