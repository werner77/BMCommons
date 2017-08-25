//
//  BMServiceManager.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMServiceManager.h>
#import <BMCommons/BMProxy.h>
#import <BMCommons/BMAbstractService.h>
#import "NSDictionary+BMCommons.h"
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMDataRecorder.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/BMBlockServiceDelegate.h>
#import <Foundation/Foundation.h>

@interface BMServiceManager()

@property (strong) BMDataRecorder *recorder;

@end

typedef enum ServiceMatchType {
    ServiceMatchTypeNone,
    ServiceMatchTypeInstance,
    ServiceMatchTypeClass,
    ServiceMatchTypeGlobal
} ServiceMatchType;

@interface BMServiceDelegateContainer : BMCoreObject {
}

@property (nonatomic, weak, readonly) id <BMServiceDelegate> delegate;
@property (nonatomic, assign, getter = isPrimary, readonly) BOOL primary;
@property (nonatomic, strong, readonly) NSString *serviceClassIdentifier;
@property (nonatomic, strong, readonly) NSString *serviceInstanceIdentifier;

- (instancetype)initWithDelegate:(id <BMServiceDelegate>)delegate primary:(BOOL)primary serviceClassIdentifier:(NSString *)serviceClassIdentifier serviceInstanceIdentifier:(NSString *)serviceInstanceIdentifier;
- (BOOL)matchesService:(id <BMService>)service  matchType:(ServiceMatchType *)matchType;
- (NSInteger)priorityForService:(id <BMService>)service;

@end

@implementation BMServiceDelegateContainer

- (instancetype)initWithDelegate:(id <BMServiceDelegate>)delegate primary:(BOOL)primary serviceClassIdentifier:(NSString *)serviceClassIdentifier serviceInstanceIdentifier:(NSString *)serviceInstanceIdentifier {
    if ((self = [super init])) {
        _delegate = delegate;
        _primary = primary;
        _serviceClassIdentifier = serviceClassIdentifier;
        _serviceInstanceIdentifier = serviceInstanceIdentifier;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    BMServiceDelegateContainer *other = (BMServiceDelegateContainer *)object;

    if (self.delegate != other.delegate) {
        return NO;
    }

    NSString *classIdentifier = self.serviceClassIdentifier;
    NSString *otherClassIdentifier = other.serviceClassIdentifier;
    if (!(classIdentifier == otherClassIdentifier || [classIdentifier isEqual:otherClassIdentifier])) {
        return NO;
    }

    NSString *instanceIdentifier = self.serviceInstanceIdentifier;
    NSString *otherInstanceIdentifier = other.serviceInstanceIdentifier;
    if (!(instanceIdentifier == otherInstanceIdentifier || [instanceIdentifier isEqual:otherInstanceIdentifier])) {
        return NO;
    }

    return YES;
}

- (NSInteger)priorityForService:(id <BMService>)service {
    NSInteger ret = 0;
    id <BMServiceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(delegatePriorityForService:)]) {
        ret = [delegate delegatePriorityForService:service];
    }
    return ret;
}

- (BOOL)matchesService:(id <BMService>)service matchType:(ServiceMatchType *)matchType {

    if ([[BMServiceManager sharedInstance] instanceIdentifier:_serviceInstanceIdentifier matchesIdentifier:service.instanceIdentifier]) {
        if (matchType) {
            *matchType = ServiceMatchTypeInstance;
        }
        return YES;
    }

    if ([[BMServiceManager sharedInstance] classIdentifier:_serviceClassIdentifier matchesIdentifier:service.classIdentifier]) {
        if (matchType) {
            *matchType = ServiceMatchTypeClass;
        }
        return YES;
    }

    if (_serviceInstanceIdentifier == nil && _serviceClassIdentifier == nil) {
        if (matchType) {
            *matchType = ServiceMatchTypeGlobal;
        }
        return YES;
    }

    if (matchType) {
        *matchType = ServiceMatchTypeNone;
    }

    return NO;
}

@end

static NSInteger prioritySort(id container1, id container2, void *service)
{
    NSInteger v1 = [container1 priorityForService:(__bridge id<BMService>)(service)];
    NSInteger v2 = [container2 priorityForService:(__bridge id<BMService>)(service)];
    if (v1 < v2)
        return NSOrderedDescending;
    else if (v1 > v2)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}


@interface BMServiceManager(Private)

- (NSArray *)serviceDelegates;
- (void)releaseService:(id <BMService>)theService;
- (void)notifyDelegatesWithSelector:(SEL)selector service:(id <BMService>)service object:(id)object releaseWhenDone:(BOOL)releaseWhenDone;
- (void)notifyDelegatesForService:(id <BMService>)service withInvocationBlock:(void (^)(id <BMServiceDelegate> delegate, id <BMService> delegateService))invocationBlock releaseWhenDone:(BOOL)releaseWhenDone;
- (void)addDelegateContainer:(BMServiceDelegateContainer *)dc;
- (void)removeDelegateContainer:(BMServiceDelegateContainer *)dc;
- (id <BMService>)transformedService:(id <BMService>)service;
- (id <BMService>)reverseTransformedService:(id <BMService>)service;
- (void)addDelegate:(id <BMServiceDelegate>)theDelegate forServiceInstance:(NSString *)instanceIdentifier primary:(BOOL)primary;
- (NSArray *)sortedDelegatesForService:(id <BMService>)service;
- (void)executeService:(id <BMService>)theService;
- (void)recordResult:(id)result forService:(id <BMService>)service;
- (id <BMService>)serviceWithInstanceIdentifier:(NSString *)instanceIdentifier;
- (NSArray<id <BMService>> *)allServices;
- (NSArray<NSString *> *)allServiceInstanceIdentifiers;
- (void)removeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier;
- (void)addService:(id <BMService>)service;

@end

@implementation BMServiceManager {
    NSMutableDictionary *_serviceDictionary;
    NSMutableArray *_serviceDelegates;
}

//Public

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (BOOL)service:(id <BMService>)service matchesClassIdentifier:(NSString *)serviceClassIdentifier {
    return [self classIdentifier:serviceClassIdentifier matchesIdentifier:service.classIdentifier];
}

- (BOOL)service:(id <BMService>)service matchesInstanceIdentifier:(NSString *)instanceIdentifier {
    return [self instanceIdentifier:instanceIdentifier matchesIdentifier:service.instanceIdentifier];
}

- (BOOL)instanceIdentifier:(NSString *)identifier matchesIdentifier:(NSString *)otherIdentifier {
    return identifier == otherIdentifier || [identifier isEqual:otherIdentifier];
}

- (BOOL)classIdentifier:(NSString *)classIdentifier matchesIdentifier:(NSString *)otherClassIdentifier {
    return [self classIdentifier:classIdentifier matchesIdentifier:otherClassIdentifier nilMatchesAll:NO];
}

- (BOOL)classIdentifier:(NSString *)classIdentifier matchesIdentifier:(NSString *)otherClassIdentifier nilMatchesAll:(BOOL)nilMatchesAll {
    if (nilMatchesAll && (classIdentifier == nil || otherClassIdentifier == nil)) {
        return YES;
    }
    return classIdentifier == otherClassIdentifier || [classIdentifier isEqual:otherClassIdentifier];
}


- (id)init {
    if ((self = [super init])) {
        self.automaticallyReverseTransformServices = YES;
        _serviceDictionary = [NSMutableDictionary new];
        _serviceDelegates = [NSMutableArray new];
        self.recorder = [BMDataRecorder new];
    }
    return self;
}

- (void)dealloc {
    for (id <BMService> s in _serviceDictionary.allValues) {
        s.delegate = nil;
    }
    [self cancelServices];
}

//Add/Remove delegate to receive all service events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate {
    if (theDelegate) {
        BMServiceDelegateContainer *dc = [[BMServiceDelegateContainer alloc] initWithDelegate:theDelegate primary:NO serviceClassIdentifier:nil serviceInstanceIdentifier:nil];
        [self addDelegateContainer:dc];
    }
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate {
    for (BMServiceDelegateContainer *delegateContainer in self.serviceDelegates) {
        if (delegateContainer.delegate == theDelegate) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

//Add/Remove delegate for service class specific events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier {
    if (theDelegate) {
        BMServiceDelegateContainer *dc = [[BMServiceDelegateContainer alloc] initWithDelegate:theDelegate primary:NO serviceClassIdentifier:classIdentifier serviceInstanceIdentifier:nil];
        [self addDelegateContainer:dc];
    }
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier {
    for (BMServiceDelegateContainer *delegateContainer in self.serviceDelegates) {
        if (delegateContainer.delegate == theDelegate && [self classIdentifier:delegateContainer.serviceClassIdentifier matchesIdentifier:classIdentifier nilMatchesAll:YES]) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

//Add/Remove delegate for service instance specific events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier {
    [self addDelegate:theDelegate forServiceInstance:instanceIdentifier primary:NO];
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier {
    for (BMServiceDelegateContainer *delegateContainer in self.serviceDelegates) {
        if (delegateContainer.delegate == theDelegate && [self instanceIdentifier:delegateContainer.serviceInstanceIdentifier matchesIdentifier:instanceIdentifier]) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

- (void)removeServiceDelegatesForInstanceIdentifier:(NSString *)instanceIdentifier {
    for (BMServiceDelegateContainer *dc in self.serviceDelegates) {
        if ([self instanceIdentifier:dc.serviceInstanceIdentifier matchesIdentifier:instanceIdentifier]) {
            [self removeDelegateContainer:dc];
        }
    }
}

- (void)cancelServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    if (instanceIdentifier) {
        id <BMService> service = [self serviceWithInstanceIdentifier:instanceIdentifier];
        [service cancel];
    }
}

- (BOOL)sendServiceToBackgroundWithInstanceIdentifier:(NSString *)instanceIdentifier {
    if (instanceIdentifier) {
        id <BMService> service = [self serviceWithInstanceIdentifier:instanceIdentifier];
        return [service sendToBackground];
    }
    return NO;
}

- (void)cancelServicesWithClassIdentifier:(NSString *)classIdentifier {
    NSArray *allServices = [self allServices];
    for (id <BMService> service in allServices) {
        if ([self classIdentifier:service.classIdentifier matchesIdentifier:classIdentifier nilMatchesAll:YES]) {
            [service cancel];
        }
    }
}

- (void)cancelServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate {
    NSArray *allServices = [self allServices];
    for (id <BMService> service in allServices) {
        id primaryDelegate = [self primaryServiceDelegateForInstanceIdentifier:[service instanceIdentifier]];
        BMBlockServiceDelegate *blockDelegate = [primaryDelegate bmCastSafely:[BMBlockServiceDelegate class]];
        if ([self classIdentifier:service.classIdentifier matchesIdentifier:classIdentifier nilMatchesAll:YES] &&
                (primaryDelegate == theDelegate ||
                        blockDelegate.owner == theDelegate
                )) {
            [service cancel];
        }
    }
}

- (void)cancelServices {
    NSArray *allServices = [self allServices];
    for (id <BMService> service in allServices) {
        [service cancel];
    }
}

- (void)cancelServiceInstancesForDelegate:(id)theDelegate {
    NSArray *allServices = [self allServices];
    for (id <BMService> service in allServices) {
        id primaryDelegate = [self primaryServiceDelegateForInstanceIdentifier:[service instanceIdentifier]];
        BMBlockServiceDelegate *blockDelegate = [primaryDelegate bmCastSafely:[BMBlockServiceDelegate class]];
        if (primaryDelegate == theDelegate || blockDelegate.owner == theDelegate) {
            [service cancel];
        }
    }
}

- (NSString *)performService:(id <BMService>)theService withDelegate:(id <BMServiceDelegate>)theDelegate {
    theService = [self transformedService:theService];
    theService.delegate = self;
    [self addDelegate:theDelegate forServiceInstance:theService.instanceIdentifier primary:YES];
    [self addService:theService];
    [self executeService:theService];
    return theService.instanceIdentifier;
}

- (BOOL)isPerformingServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    id<BMService> service = [self serviceWithInstanceIdentifier:instanceIdentifier];
    return service != nil && !service.isCancelled;
}

- (BOOL)isPerformingServiceForDelegate:(id)theDelegate {
    return [self isPerformingServiceWithClassIdentifier:nil forDelegate:theDelegate];
}

- (BOOL)isPerformingServiceWithClassIdentifier:(NSString *)classIdentifier
                                   forDelegate:(id)theDelegate {
    return [self activeServicesWithClassIdentifier:classIdentifier forDelegate:theDelegate performReverseTransformation:NO].count > 0;
}

- (NSArray *)activeServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate performReverseTransformation:(BOOL)performReverseTransformation {
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *instanceIdentifier in [self allServiceInstanceIdentifiers]) {
        id <BMService> theService = [self serviceWithInstanceIdentifier:instanceIdentifier];
        NSString *serviceClassIdentifier = [theService classIdentifier];
        id <BMServiceDelegate> primaryDelegate = [self primaryServiceDelegateForInstanceIdentifier:instanceIdentifier];
        BMBlockServiceDelegate *blockDelegate = [(NSObject *) primaryDelegate bmCastSafely:[BMBlockServiceDelegate class]];

        BOOL delegatesMatch = (theDelegate == nil || theDelegate == primaryDelegate || [theDelegate isEqual:blockDelegate.owner]);
        BOOL classesMatch = [self classIdentifier:classIdentifier matchesIdentifier:serviceClassIdentifier nilMatchesAll:YES];
        if (delegatesMatch && classesMatch && !theService.isCancelled) {
            if (performReverseTransformation) {
                theService = [self reverseTransformedService:theService];
            }
            [ret addObject:theService];
        }
    }
    return ret;
}

- (NSArray *)activeServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate {
    return [self activeServicesWithClassIdentifier:classIdentifier forDelegate:theDelegate performReverseTransformation:self.automaticallyReverseTransformServices];
}

- (id <BMService>)activeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier performReverseTransformation:(BOOL)performReverseTransformation {
    id <BMService> service = [self serviceWithInstanceIdentifier:instanceIdentifier];
    if (service.isCancelled) {
        service = nil;
    }
    if (performReverseTransformation && service != nil) {
        service = [self reverseTransformedService:service];
    }
    return service;
}

- (id <BMService>)activeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    return [self activeServiceWithInstanceIdentifier:instanceIdentifier performReverseTransformation:self.automaticallyReverseTransformServices];
}

- (BOOL)isPerformingServiceWithClassIdentifier:(NSString *)classIdentifier {
    return [self isPerformingServiceWithClassIdentifier:classIdentifier forDelegate:nil];
}

- (id <BMServiceDelegate>)primaryServiceDelegateForInstanceIdentifier:(NSString *)instanceIdentifier {
    for (BMServiceDelegateContainer *dc in self.serviceDelegates) {
        if ([self instanceIdentifier:dc.serviceInstanceIdentifier matchesIdentifier:instanceIdentifier] && dc.isPrimary) {
            return dc.delegate;
        }
    }
    return nil;
}

- (id <BMServiceDelegate>)ownerForServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    id <BMServiceDelegate>owner = [self primaryServiceDelegateForInstanceIdentifier:instanceIdentifier];
    if ([owner isKindOfClass:[BMBlockServiceDelegate class]]) {
        owner = [(BMBlockServiceDelegate *)owner owner];
    }
    return owner;
}

#pragma mark -
#pragma mark BMServiceDelegate

- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    [self notifyDelegatesWithSelector:@selector(service:succeededWithResult:) service:service object:result releaseWhenDone:YES];
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    [self recordResult:error forService:service];
    [self notifyDelegatesWithSelector:@selector(service:failedWithError:) service:service object:error releaseWhenDone:YES];
}

- (void)service:(id <BMService>)service succeededWithRawResult:(id)rawResult {
    [self recordResult:rawResult forService:service];
    [self notifyDelegatesWithSelector:@selector(service:succeededWithRawResult:) service:service object:rawResult releaseWhenDone:NO];
}

- (NSInteger)delegatePriorityForService:(id <BMService>)service {
    return 0;
}

- (void)serviceDidStart:(id <BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceDidStart:) service:service object:nil releaseWhenDone:NO];
}

- (void)service:(id <BMService>)service updatedProgress:(double)progressPercentage withMessage:(NSString *)message {
    [self notifyDelegatesForService:service withInvocationBlock:^(id <BMServiceDelegate> delegate, id <BMService> delegateService) {
        if (@selector(service:updatedProgress:withMessage:)) {
            [delegate service:delegateService updatedProgress:progressPercentage withMessage:message];
        }
    } releaseWhenDone:NO];
}

- (void)serviceWasCancelled:(id <BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasCancelled:) service:service object:nil releaseWhenDone:YES];
}

- (void)serviceWasSentToBackground:(id<BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasSentToBackground:) service:service object:nil releaseWhenDone:NO];
}

- (void)serviceWasSentToForeground:(id<BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasSentToForeground:) service:service object:nil releaseWhenDone:NO];
}

@end

@implementation BMServiceManager(Private)

- (NSArray *)sortedDelegatesForService:(id <BMService>)service {
    NSArray *serviceDelegates = self.serviceDelegates;
    NSMutableArray *theDelegates = [NSMutableArray arrayWithCapacity:serviceDelegates.count];
    BMServiceDelegateContainer *primaryDelegate = nil;
    for (BMServiceDelegateContainer *dc in serviceDelegates) {
        if ([self instanceIdentifier:dc.serviceInstanceIdentifier matchesIdentifier:service.instanceIdentifier] && dc.isPrimary) {
            primaryDelegate = dc;
        } else {
            [theDelegates addObject:dc];
        }
    }
    [theDelegates sortUsingFunction:prioritySort context:(__bridge void *)(service)];
    if (primaryDelegate) {
        [theDelegates insertObject:primaryDelegate atIndex:0];
    }
    return theDelegates;
}

- (void)releaseService:(id <BMService>)theService {
    id <BMService> __autoreleasing autoReleasingService = theService;
    autoReleasingService.delegate = nil;
    [self removeServiceDelegatesForInstanceIdentifier:autoReleasingService.instanceIdentifier];
    [self removeServiceWithInstanceIdentifier:autoReleasingService.instanceIdentifier];
}

- (void)notifyDelegatesWithSelector:(SEL)selector service:(id <BMService>)service object:(id)object releaseWhenDone:(BOOL)releaseWhenDone {
    [self notifyDelegatesForService:service withInvocationBlock:^(id <BMServiceDelegate> delegate, id <BMService> delegateService) {
        if ([delegate respondsToSelector:selector]) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [delegate performSelector:selector withObject:delegateService withObject:object];
            )
        }
    } releaseWhenDone:releaseWhenDone];
}

- (void)notifyDelegatesForService:(id <BMService>)service withInvocationBlock:(void (^)(id <BMServiceDelegate> delegate, id <BMService> delegateService))invocationBlock releaseWhenDone:(BOOL)releaseWhenDone {
    id <BMService> delegateService = service;
    if (self.automaticallyReverseTransformServices) {
        delegateService = [self reverseTransformedService:service];
    }

    __typeof(self) __weak weakSelf = self;
    void (^block)(void) =^ {
        NSArray *theDelegates = [weakSelf sortedDelegatesForService:service];

        for (BMServiceDelegateContainer *dc in theDelegates) {
            if ([dc matchesService:service matchType:nil]) {
                invocationBlock(dc.delegate, delegateService);
            }
        }

        if (releaseWhenDone) {
            [weakSelf releaseService:service];
        }
    };

    if (self.delegateQueue != nil) {
        [self.delegateQueue addOperationWithBlock:block];
    } else {
        [self bmPerformBlockOnMainThread:block];
    }
}

- (id <BMService>)transformedService:(id <BMService>)service {
    id <BMService> theService = service;
    id <BMService> transformedService = nil;
    if ([self.delegate respondsToSelector:@selector(serviceManager:transformedServiceForService:)]) {
        transformedService = [self.delegate serviceManager:self transformedServiceForService:service];
    }
    NSValueTransformer *serviceTransformer = self.serviceTransformer;
    if (transformedService == nil && serviceTransformer != nil) {
        transformedService = [serviceTransformer transformedValue:theService];
    }
    if (transformedService != nil) {
        theService = transformedService;
    }
    return theService;
}

- (id <BMService>)reverseTransformedService:(id <BMService>)service {
    id <BMService> theService = service;
    id <BMService> transformedService = nil;
    if ([self.delegate respondsToSelector:@selector(serviceManager:reverseTransformedServiceForService:)]) {
        transformedService = [self.delegate serviceManager:self reverseTransformedServiceForService:service];
    }
    NSValueTransformer *serviceTransformer = self.serviceTransformer;
    if (transformedService == nil && serviceTransformer != nil) {
        transformedService = [serviceTransformer reverseTransformedValue:theService];
    }
    if (transformedService != nil) {
        theService = transformedService;
    }
    return theService;
}

- (void)addDelegate:(id <BMServiceDelegate>)theDelegate forServiceInstance:(NSString *)instanceIdentifier primary:(BOOL)primary {
    if (theDelegate) {
        BMServiceDelegateContainer *dc = [[BMServiceDelegateContainer alloc] initWithDelegate:theDelegate primary:primary serviceClassIdentifier:nil serviceInstanceIdentifier:instanceIdentifier];
        [self addDelegateContainer:dc];
    }
}

- (void)recordResult:(id)result forService:(id <BMService>)service {
    if (self.recorder.isRecording) {
        [self.recorder recordResult:result forRecordingClass:service.classIdentifier withDigest:service.digest];
    }
}

- (void)executeService:(id <BMService>)theService {

    id mockResult = nil;
    BOOL rawResult = NO;

    id <BMService> delegateService = theService;
    if (self.automaticallyReverseTransformServices) {
        delegateService = [self reverseTransformedService:theService];
    }

    if ([self.delegate respondsToSelector:@selector(serviceManager:mockResultForService:isRaw:)]) {
        mockResult = [self.delegate serviceManager:self mockResultForService:delegateService isRaw:&rawResult];
    }

    if (mockResult == nil && self.recorder.isPlayingBack) {
        mockResult = [self.recorder recordedResultForRecordingClass:theService.classIdentifier withDigest:theService.digest];
        if (mockResult == nil) {
            mockResult = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION description:[NSString stringWithFormat:@"No valid mock response exists for service: %@", [theService classIdentifier]]];
            rawResult = NO;
        } else {
            rawResult = YES;
        }
    }

    if (mockResult == nil) {
        [theService execute];
    } else {
        [theService mockExecuteWithResult:mockResult isRaw:rawResult];
    }
}

- (id <BMService>)serviceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    @synchronized(self) {
        return _serviceDictionary[instanceIdentifier];
    }
}

- (NSArray<id <BMService>> *)allServices {
    @synchronized(self) {
        return [_serviceDictionary allValues];
    }
}

- (NSArray<NSString *> *)allServiceInstanceIdentifiers {
    @synchronized (self) {
        return [_serviceDictionary allKeys];
    }
}

- (void)removeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
    @synchronized (self) {
        [_serviceDictionary removeObjectForKey:instanceIdentifier];
    }
}

- (void)addService:(id <BMService>)service {
    @synchronized (self) {
        [_serviceDictionary bmSafeSetObject:service forKey:service.instanceIdentifier];
    }
}

- (void)addDelegateContainer:(BMServiceDelegateContainer *)dc {
    @synchronized (self) {
        if (![_serviceDelegates containsObject:dc]) {
            [_serviceDelegates addObject:dc];
        }
    }
}

- (void)removeDelegateContainer:(BMServiceDelegateContainer *)dc {
    @synchronized(self) {
        [_serviceDelegates removeObject:dc];
    }
}

- (NSArray *)serviceDelegates {
    @synchronized(self) {
        return [NSArray arrayWithArray:_serviceDelegates];
    }
}

@end
