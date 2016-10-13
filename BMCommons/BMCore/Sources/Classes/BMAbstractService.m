//
//  BMAbstractService.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/2/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMAbstractService.h"
#import "BMStringHelper.h"
#import <BMCore/BMCore.h>

@implementation BMAbstractService {
    NSString *_instanceIdentifier;
    __weak id <BMServiceDelegate> _delegate;
    id _context;
    BOOL _backgroundService;
    BOOL _sendToBackgroundSupported;
    BOOL _userCancellable;
    BOOL _started;
    BOOL _cancelled;
    BOOL _errorHandled;
    BOOL _finished;
    BOOL _executing;
    NSString *_loadingMessage;
#if TARGET_OS_IPHONE
    UIBackgroundTaskIdentifier _bgTaskIdentifier;
#endif
}

@synthesize context = _context, delegate = _delegate, backgroundService = _backgroundService, userCancellable = _userCancellable, errorHandled = _errorHandled, sendToBackgroundSupported = _sendToBackgroundSupported, resultTransformer = _resultTransformer, errorTransformer = _errorTransformer, cancelled = _cancelled, loadingMessage = _loadingMessage, finished = _finished, executing = _executing;

#if TARGET_OS_IPHONE
@synthesize bgTaskIdentifier = _bgTaskIdentifier;
#endif

- (id)init {
	if ((self = [super init])) {
#if TARGET_OS_IPHONE
        _bgTaskIdentifier = UIBackgroundTaskInvalid;
#endif
		_instanceIdentifier = [BMStringHelper stringWithUUID];
        _userCancellable = YES;
	}
	return self;
}

- (void)dealloc {
	self.delegate = nil;
	[self cancel];
	BM_RELEASE_SAFELY(_instanceIdentifier);
}

- (void)reset {
    _errorHandled = NO;
    _started = NO;
    _cancelled = NO;
    _finished = NO;
    _executing = YES;
}

- (NSString *)classIdentifier {
	return [[self class] classIdentifier];
}

+ (NSString *)classIdentifier {
    return NSStringFromClass(self);
}

- (NSString *)instanceIdentifier {
	return _instanceIdentifier;
}

- (void)cancel {
    if (_executing) {
        //Default implementation does nothing
        _cancelled = YES;
        [self serviceWasCancelled];
    }
}

- (void)execute {
	NSError *error = nil;
    [self reset];
	[self serviceDidStart];
	if (![self executeWithError:&error]) {
    	[self performSelector:@selector(serviceFailedWithError:) withObject:error afterDelay:0.0];
    }
}

- (void)mockExecuteWithResult:(id)result isRaw:(BOOL)isRaw {
    [self reset];
    [self serviceDidStart];
    if (isRaw) {
        if ([result isKindOfClass:[NSError class]]) {
            [self performSelector:@selector(serviceFailedWithRawError:) withObject:result afterDelay:0.0];
        } else {
            [self performSelector:@selector(serviceSucceededWithRawResult:) withObject:result afterDelay:0.0];
        }
    } else {
        if ([result isKindOfClass:[NSError class]]) {
            [self performSelector:@selector(serviceFailedWithError:) withObject:result afterDelay:0.0];
        } else {
            [self performSelector:@selector(serviceSucceededWithResult:) withObject:result afterDelay:0.0];
        }
    }
}

#pragma mark -
#pragma mark Helper methods

- (BOOL)sendToBackground {
    if (self.isSendToBackgroundSupported && !self.isBackgroundService) {
        self.backgroundService = YES;
        [self serviceWasSentToBackground];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)sendToForeground {
    if (self.isBackgroundService) {
        self.backgroundService = NO;
        [self serviceWasSentToForeground];
        return YES;
    } else {
        return NO;
    }
}

- (void)startBackgroundTask {
#if TARGET_OS_IPHONE
    if (self.bgTaskIdentifier == UIBackgroundTaskInvalid && (self.isBackgroundService || self.isSendToBackgroundSupported)) {
        __weak __block BMAbstractService *bSelf = self;
        self.bgTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bSelf.isExecuting) {
                    [bSelf cancel];
                }
            });
        }];
    }
#endif
}

- (void)endBackgroundTask {
#if TARGET_OS_IPHONE
    if (self.bgTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskIdentifier];
        self.bgTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)serviceDidStart {
    if (!self.isCancelled) {
        if (!_started) {
            _started = YES;
            [self startBackgroundTask];
            if ([self.delegate respondsToSelector:@selector(serviceDidStart:)]) {
                [self.delegate serviceDidStart:self];
            }
        }
    }
}

- (void)serviceWasCancelled {
    _executing = NO;
    if ([self.delegate respondsToSelector:@selector(serviceWasCancelled:)]) {
        [self.delegate serviceWasCancelled:self];
    }
    [self endBackgroundTask];
}

- (void)serviceWasSentToBackground {
    if (!self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(serviceWasSentToBackground:)]) {
            [self.delegate serviceWasSentToBackground:self];
        }
    }
}

- (void)serviceWasSentToForeground {
    if (!self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(serviceWasSentToForeground:)]) {
            [self.delegate serviceWasSentToForeground:self];
        }
    }
}

- (void)serviceSucceededWithRawResult:(id)result {
    if (!self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(service:succeededWithRawResult:)]) {
            [self.delegate service:self succeededWithRawResult:result];
        }
        result = [self resultOrErrorByConvertingRawResult:result];
        if ([result isKindOfClass:[NSError class]]) {
            [self serviceFailedWithError:result];
        } else {
            [self serviceSucceededWithResult:result];
        }
    } else {
        _finished = YES;
        _executing = NO;
        [self endBackgroundTask];
    }
}

- (void)serviceSucceededWithResult:(id)result {
    _finished = YES;
    _executing = NO;
    if (!self.isCancelled) {
        [self.delegate service:self succeededWithResult:result];
    }
    [self endBackgroundTask];
}

- (void)serviceFailedWithRawError:(NSError *)error {
    if (!self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(service:failedWithRawError:)]) {
            [self.delegate service:self failedWithRawError:error];
        }
        error = [self errorByConvertingRawError:error];
        [self serviceFailedWithError:error];
    } else {
        _finished = YES;
        _executing = NO;
        [self endBackgroundTask];
    }
}

- (void)serviceFailedWithError:(NSError *)error {
    _finished = YES;
    _executing = NO;
    if (!self.isCancelled) {
        [self.delegate service:self failedWithError:error];
    }
    [self endBackgroundTask];
}

- (NSInteger)delegatePriority {
    NSInteger priority = 0;
	if ([self.delegate respondsToSelector:@selector(delegatePriorityForService:)]) {
		priority = [self.delegate delegatePriorityForService:self];
	}
	return priority;
}

- (void)updateProgress:(double)progressPercentage withMessage:(NSString *)message {
	if ([self.delegate respondsToSelector:@selector(service:updatedProgress:withMessage:)]) {
		[self.delegate service:self updatedProgress:progressPercentage withMessage:message];
	}
}

- (id)resultOrErrorByConvertingRawResult:(id)result {
    if (self.resultTransformer) {
        result = [self.resultTransformer transformedValue:result];
    }
    return result;
}

- (NSError *)errorByConvertingRawError:(NSError *)error {
    if (self.errorTransformer) {
        error = [self.errorTransformer transformedValue:error];
    }
    return error;
}

#pragma mark -
#pragma mark Methods to be implemented by sub classes

- (BOOL)executeWithError:(NSError **)error {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSString *)digest {
    return nil;
}

@end
