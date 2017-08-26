//
// Created by Werner Altewischer on 31/08/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <BMCommons/BMWrapperService.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMCore.h>

@interface BMWrapperService()

@property (strong) id<BMService> wrappedService;

@end

@implementation BMWrapperService {

}

+ (NSArray *)keyPathsToObserve {
    static NSArray *ret = nil;
    BM_DISPATCH_ONCE((^{
        ret = @[@"backgroundService", @"sendToBackgroundSupported", @"userCancellable", @"errorHandled", @"loadingMessage"];
    }));
    return ret;
}

- (instancetype)init {
    return [self initWithWrappedService:[BMAbstractService new]];
}

- (instancetype)initWithWrappedService:(id<BMService>)wrappedService {
    if ((self = [super init])) {
        if (!wrappedService) {
            return nil;
        }
        self.wrappedService = wrappedService;

        for (NSString *keyPath in self.class.keyPathsToObserve) {
            id value = [(NSObject *)self.wrappedService valueForKeyPath:keyPath];
            [self setValue:value forKeyPath:keyPath];
            [(NSObject *)wrappedService addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    return self;
}

- (void)dealloc {
    for (NSString *keyPath in self.class.keyPathsToObserve) {
        [(NSObject *)self.wrappedService removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    [self setValue:newValue forKeyPath:keyPath];
}

- (BOOL)executeWithError:(NSError **)error {
    BOOL valid = (self.wrappedService != nil);
    if (valid) {
        [self executeWrappedService];
    } else {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_ASSERTION description:@"Wrapped service is mandatory"];
        }
    }
    return valid;
}

- (void)executeWrappedService {
    [self executeService:self.wrappedService];
}

- (void)mockExecuteWithResult:(id)result isRaw:(BOOL)isRaw {
    [self reset];
    [self serviceDidStart];
    [self mockExecuteWrappedServiceWithResult:result isRaw:isRaw];
}

- (void)mockExecuteWrappedServiceWithResult:(id)result isRaw:(BOOL)isRaw {
    [self mockExecuteService:self.wrappedService withResult:result isRaw:isRaw];
}

- (BOOL)handleResult:(id)result forService:(id <BMService>)service {
    return NO;
}

- (BOOL)handleError:(NSError *)error forService:(id <BMService>)service {
    return NO;
}

#pragma mark - Overridden methods from BMAbstractService

- (NSString *)digest {
    return self.wrappedService.digest;
}

- (NSString *)classIdentifier {
    return self.wrappedService.classIdentifier;
}

- (NSString *)instanceIdentifier {
    return self.wrappedService.instanceIdentifier;
}

- (void)serviceSucceededWithRawResult:(id)rawResult {
    //Result transformation not supported for the wrapper service itself, because we already send the delegate the raw result of the wrapped service.
    [self serviceSucceededWithResult:rawResult];
}

- (void)serviceFailedWithRawError:(NSError *)error {
    [self serviceFailedWithError:error];
}

#pragma mark - BMServiceDelegate implementation

- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    if (service == self.wrappedService) {
        [self serviceSucceededWithRawResult:result];
    } else {
        if ([self handleResult:result forService:service]) {
            [self executeWrappedService];
        }
    }
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    if (![self handleError:error forService:service]) {
        [self serviceFailedWithRawError:error];
    }
}

- (void)service:(id <BMService>)service succeededWithRawResult:(id)rawResult {
    if (service == self.wrappedService && ![self isCancelled]) {
        //Raw result of wrapped service: notify delegates
        if ([self.delegate respondsToSelector:@selector(service:succeededWithRawResult:)]) {
            [self.delegate service:self succeededWithRawResult:rawResult];
        }
    }
}

- (void)service:(id <BMService>)service failedWithRawError:(NSError *)error {
    if (service == self.wrappedService && ![self isCancelled]) {
        //Raw error of wrapped service: notify delegates
        if ([self.delegate respondsToSelector:@selector(service:failedWithRawError:)]) {
            [self.delegate service:self failedWithRawError:error];
        }
    }
}

@end