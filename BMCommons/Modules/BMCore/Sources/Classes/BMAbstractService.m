//
//  BMAbstractService.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/2/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractService.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCore.h>

@interface BMAbstractService()

@property (assign, getter=isStarted) BOOL started;
@property (assign, getter = isCancelled) BOOL cancelled;
@property (assign, getter = isFinished) BOOL finished;
@property (assign, getter = isExecuting) BOOL executing;
@property (strong) NSString *instanceIdentifier;

@end

@implementation BMAbstractService {
}

@synthesize context = _context, delegate = _delegate, backgroundService = _backgroundService, userCancellable = _userCancellable, errorHandled = _errorHandled, sendToBackgroundSupported = _sendToBackgroundSupported, resultTransformer = _resultTransformer, errorTransformer = _errorTransformer, cancelled = _cancelled, loadingMessage = _loadingMessage, finished = _finished, executing = _executing;
@synthesize instanceIdentifier = _instanceIdentifier;

#if TARGET_OS_IPHONE
@synthesize bgTaskIdentifier = _bgTaskIdentifier;
#endif

- (id)init {
	if ((self = [super init])) {
#if TARGET_OS_IPHONE
        self.bgTaskIdentifier = UIBackgroundTaskInvalid;
#endif
		self.instanceIdentifier = [BMStringHelper stringWithUUID];
        self.userCancellable = YES;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
}

- (void)reset {
    self.errorHandled = NO;
    self.started = NO;
    self.cancelled = NO;
    self.finished = NO;
    self.executing = YES;
}

- (NSString *)classIdentifier {
	return [[self class] classIdentifier];
}

+ (NSString *)classIdentifier {
    return NSStringFromClass(self);
}

- (void)cancel {
    if (self.isExecuting) {
        //Default implementation does nothing
        self.cancelled = YES;
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
        __typeof(self) __weak weakSelf = self;
        self.bgTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.isExecuting) {
                    [weakSelf cancel];
                }
            });
        }];
    }
#endif
}

- (void)endBackgroundTask {
#if TARGET_OS_IPHONE
    UIBackgroundTaskIdentifier bgTaskIdentifier = self.bgTaskIdentifier;
    if (bgTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskIdentifier];
        self.bgTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)serviceDidStart {
    if (!self.isCancelled) {
        if (!self.isStarted) {
            self.started = YES;
            [self startBackgroundTask];
            id <BMServiceDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(serviceDidStart:)]) {
                [delegate serviceDidStart:self];
            }
        }
    }
}

- (void)serviceWasCancelled {
    self.executing = NO;
    id <BMServiceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(serviceWasCancelled:)]) {
        [delegate serviceWasCancelled:self];
    }
    [self endBackgroundTask];
}

- (void)serviceWasSentToBackground {
    if (!self.isCancelled) {
        id <BMServiceDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(serviceWasSentToBackground:)]) {
            [delegate serviceWasSentToBackground:self];
        }
    }
}

- (void)serviceWasSentToForeground {
    if (!self.isCancelled) {
        id <BMServiceDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(serviceWasSentToForeground:)]) {
            [delegate serviceWasSentToForeground:self];
        }
    }
}

- (void)serviceSucceededWithRawResult:(id)result {
    if (!self.isCancelled) {
        id <BMServiceDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(service:succeededWithRawResult:)]) {
            [delegate service:self succeededWithRawResult:result];
        }
        result = [self resultOrErrorByConvertingRawResult:result];
        if ([result isKindOfClass:[NSError class]]) {
            [self serviceFailedWithError:result];
        } else {
            [self serviceSucceededWithResult:result];
        }
    } else {
        self.finished = YES;
        self.executing = NO;
        [self endBackgroundTask];
    }
}

- (void)serviceSucceededWithResult:(id)result {
    self.finished = YES;
    self.executing = NO;
    [self endBackgroundTask];
    if (!self.isCancelled) {
        [self.delegate service:self succeededWithResult:result];
    }
}

- (void)serviceFailedWithRawError:(NSError *)error {
    if (!self.isCancelled) {
        id <BMServiceDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(service:failedWithRawError:)]) {
            [delegate service:self failedWithRawError:error];
        }
        error = [self errorByConvertingRawError:error];
        [self serviceFailedWithError:error];
    } else {
        self.finished = YES;
        self.executing = NO;
        [self endBackgroundTask];
    }
}

- (void)serviceFailedWithError:(NSError *)error {
    self.finished = YES;
    self.executing = NO;
    [self endBackgroundTask];
    if (!self.isCancelled) {
        [self.delegate service:self failedWithError:error];
    }
}

- (NSInteger)delegatePriority {
    NSInteger priority = 0;
    id <BMServiceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(delegatePriorityForService:)]) {
		priority = [delegate delegatePriorityForService:self];
	}
	return priority;
}

- (void)updateProgress:(double)progressPercentage withMessage:(NSString *)message {
    id <BMServiceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(service:updatedProgress:withMessage:)]) {
		[delegate service:self updatedProgress:progressPercentage withMessage:message];
	}
}

- (id)resultOrErrorByConvertingRawResult:(id)result {
    NSValueTransformer *resultTransformer = self.resultTransformer;
    if (resultTransformer) {
        result = [resultTransformer transformedValue:result];
    }
    return result;
}

- (NSError *)errorByConvertingRawError:(NSError *)error {
    NSValueTransformer *errorTransformer = self.errorTransformer;
    if (errorTransformer) {
        error = [errorTransformer transformedValue:error];
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
