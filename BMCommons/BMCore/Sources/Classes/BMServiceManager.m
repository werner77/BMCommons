//
//  BMServiceManager.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMServiceManager.h"
#import "BMProxy.h"
#import "BMAbstractService.h"
#import "NSDictionary+BMCommons.h"
#import "BMObjectHelper.h"
#import "BMDataRecorder.h"
#import <BMCore/BMErrorHelper.h>
#import <BMCore/BMFileHelper.h>
#import <BMCore/BMStringHelper.h>
#import <BMCore/BMCoreObject.h>
#import <BMCore/BMCore.h>
#import <BMCore/NSObject+BMCommons.h>
#import <BMCore/BMBlockServiceDelegate.h>
#import <Foundation/Foundation.h>

@interface BMServiceManager()

@property (nonatomic, strong) BMDataRecorder *recorder;

@end

typedef enum ServiceMatchType {
	ServiceMatchTypeNone,
	ServiceMatchTypeInstance,
	ServiceMatchTypeClass,
	ServiceMatchTypeGlobal
} ServiceMatchType;

@interface BMServiceDelegateContainer : BMCoreObject {
	id <BMServiceDelegate> __weak _delegate;
	NSString *_serviceClassIdentifier;
	NSString *_serviceInstanceIdentifier;
    BOOL _primary;
}

@property (nonatomic, weak) id <BMServiceDelegate> delegate;
@property (nonatomic, assign, getter = isPrimary) BOOL primary;
@property (nonatomic, strong) NSString *serviceClassIdentifier;
@property (nonatomic, strong) NSString *serviceInstanceIdentifier;

- (BOOL)matchesService:(id <BMService>)service  matchType:(ServiceMatchType *)matchType;
- (NSInteger)priorityForService:(id <BMService>)service;

@end

@implementation BMServiceDelegateContainer

@synthesize delegate = _delegate, serviceClassIdentifier = _serviceClassIdentifier, serviceInstanceIdentifier = _serviceInstanceIdentifier, primary = _primary;

- (void)dealloc {
	self.delegate = nil;
}

- (BOOL)isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}	
	BMServiceDelegateContainer *other = (BMServiceDelegateContainer *)object;
	
	if (self.delegate != other.delegate) {
		return NO;
	}
	
	if (!(self.serviceClassIdentifier == other.serviceClassIdentifier || [self.serviceClassIdentifier isEqual:other.serviceClassIdentifier])) {
		return NO;
	}
	
	if (!(self.serviceInstanceIdentifier == other.serviceInstanceIdentifier || [self.serviceInstanceIdentifier isEqual:other.serviceInstanceIdentifier])) {
		return NO;
	}
	
	return YES;
}

- (NSInteger)priorityForService:(id <BMService>)service {
	if ([_delegate respondsToSelector:@selector(delegatePriorityForService:)]) {
		return [_delegate delegatePriorityForService:service];
	} else {
		return 0;
	}
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

- (void)releaseService:(id <BMService>)theService;
- (void)notifyDelegatesWithSelector:(SEL)selector service:(id <BMService>)service object:(id)object;
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
}

@synthesize serviceTransformer = _serviceTransformer;

//Public

static BMServiceManager *sharedInstance = nil;

+ (BMServiceManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (BOOL)service:(id <BMService>)service matchesClassIdentifier:(NSString *)serviceClassIdentifier {
    return service.classIdentifier == serviceClassIdentifier || [service.classIdentifier isEqual:serviceClassIdentifier];
}

- (BOOL)service:(id <BMService>)service matchesInstanceIdentifier:(NSString *)instanceIdentifier {
    return service.instanceIdentifier == instanceIdentifier || [service.instanceIdentifier isEqual:instanceIdentifier];
}

- (BOOL)instanceIdentifier:(NSString *)identifier matchesIdentifier:(NSString *)otherIdentifier {
    return identifier == otherIdentifier || [identifier isEqual:otherIdentifier];
}

- (BOOL)classIdentifier:(NSString *)classIdentifier matchesIdentifier:(NSString *)otherClassIdentifier {
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
	for (id <BMService> s in _serviceDictionary) {
		s.delegate = nil;
	}
    [self cancelServices];
	BM_RELEASE_SAFELY(_serviceDictionary);
	BM_RELEASE_SAFELY(_serviceTransformer);
}

//Add/Remove delegate to receive all service events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate {
	if (theDelegate) {
		BMServiceDelegateContainer *dc = [BMServiceDelegateContainer new];
		dc.delegate = theDelegate;
		[self addDelegateContainer:dc];
	}
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate {
    for (BMServiceDelegateContainer *delegateContainer in [NSArray arrayWithArray:_serviceDelegates]) {
        if (delegateContainer.delegate == theDelegate) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

//Add/Remove delegate for service class specific events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier {
	if (theDelegate) {
		BMServiceDelegateContainer *dc = [BMServiceDelegateContainer new];
		dc.delegate = theDelegate;
		dc.serviceClassIdentifier = classIdentifier;
		[self addDelegateContainer:dc];
	}
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier {
    for (BMServiceDelegateContainer *delegateContainer in [NSArray arrayWithArray:_serviceDelegates]) {
        if (delegateContainer.delegate == theDelegate && [self classIdentifier:delegateContainer.serviceClassIdentifier matchesIdentifier:classIdentifier]) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

//Add/Remove delegate for service instance specific events
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier {
	[self addDelegate:theDelegate forServiceInstance:instanceIdentifier primary:NO];
}

- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier {
    for (BMServiceDelegateContainer *delegateContainer in [NSArray arrayWithArray:_serviceDelegates]) {
        if (delegateContainer.delegate == theDelegate && [self instanceIdentifier:delegateContainer.serviceInstanceIdentifier matchesIdentifier:instanceIdentifier]) {
            [self removeDelegateContainer:delegateContainer];
        }
    }
}

- (void)removeServiceDelegatesForInstanceIdentifier:(NSString *)instanceIdentifier {
	NSArray *theDelegates = [NSArray arrayWithArray:_serviceDelegates];
	for (BMServiceDelegateContainer *dc in theDelegates) {
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
		if ([self classIdentifier:service.classIdentifier matchesIdentifier:classIdentifier]) {
            [service cancel];
		}
	}
}

- (void)cancelServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate {
    NSArray *allServices = [self allServices];
	for (id <BMService> service in allServices) {
        id primaryDelegate = [self primaryServiceDelegateForInstanceIdentifier:[service instanceIdentifier]];
        BMBlockServiceDelegate *blockDelegate = [primaryDelegate bmCastSafely:[BMBlockServiceDelegate class]];
		if ([self classIdentifier:service.classIdentifier matchesIdentifier:classIdentifier] &&
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
        BOOL classesMatch = (classIdentifier == nil || [self classIdentifier:classIdentifier matchesIdentifier:serviceClassIdentifier]);
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
    for (BMServiceDelegateContainer *dc in [NSArray arrayWithArray:_serviceDelegates]) {
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
	[self notifyDelegatesWithSelector:@selector(service:succeededWithResult:) service:service object:result];
	[self releaseService:service];
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    [self notifyDelegatesWithSelector:@selector(service:failedWithError:) service:service object:error];
	[self recordResult:error forService:service];
	[self releaseService:service];
}

- (void)service:(id <BMService>)service succeededWithRawResult:(id)rawResult {
	[self notifyDelegatesWithSelector:@selector(service:succeededWithRawResult:) service:service object:rawResult];
	[self recordResult:rawResult forService:service];
}

- (NSInteger)delegatePriorityForService:(id <BMService>)service {
	return 0;
}

- (void)serviceDidStart:(id <BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceDidStart:) service:service object:nil];    
}

- (void)service:(id <BMService>)service updatedProgress:(double)progressPercentage withMessage:(NSString *)message {

	NSArray *theDelegates = [self sortedDelegatesForService:service];

	id delegateService = service;
	if (self.automaticallyReverseTransformServices) {
		delegateService = [self reverseTransformedService:service];
	}
    
    for (BMServiceDelegateContainer *dc in theDelegates) {
		if ([dc matchesService:service matchType:nil] && [dc.delegate respondsToSelector:@selector(service:updatedProgress:withMessage:)]) {
			[dc.delegate service:delegateService updatedProgress:progressPercentage withMessage:message];
		}
	}	
}

- (void)serviceWasCancelled:(id <BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasCancelled:) service:service object:nil];    
    [self releaseService:service];
}

- (void)serviceWasSentToBackground:(id<BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasSentToBackground:) service:service object:nil];    
}

- (void)serviceWasSentToForeground:(id<BMService>)service {
    [self notifyDelegatesWithSelector:@selector(serviceWasSentToForeground:) service:service object:nil];
}

@end
		 
@implementation BMServiceManager(Private)

- (NSArray *)sortedDelegatesForService:(id <BMService>)service {
    NSMutableArray *theDelegates = [NSMutableArray arrayWithCapacity:_serviceDelegates.count];
    BMServiceDelegateContainer *primaryDelegate = nil;
    for (BMServiceDelegateContainer *dc in [NSArray arrayWithArray:_serviceDelegates]) {
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
	theService.delegate = nil;
	[self removeServiceDelegatesForInstanceIdentifier:theService.instanceIdentifier];
	[self removeServiceWithInstanceIdentifier:theService.instanceIdentifier];
}

- (void)notifyDelegatesWithSelector:(SEL)selector service:(id <BMService>)service object:(id)object {
    NSArray *theDelegates = [self sortedDelegatesForService:service];

	id <BMService> delegateService = service;
	if (self.automaticallyReverseTransformServices) {
		delegateService = [self reverseTransformedService:service];
	}

	for (BMServiceDelegateContainer *dc in theDelegates) {
		if ([dc matchesService:service matchType:nil] && [dc.delegate respondsToSelector:selector]) {
			[dc.delegate performSelector:selector withObject:delegateService withObject:object];
		}
	}
}

- (void)addDelegateContainer:(BMServiceDelegateContainer *)dc {
	if (![_serviceDelegates containsObject:dc]) {
		[_serviceDelegates addObject:dc];
	}
}

- (void)removeDelegateContainer:(BMServiceDelegateContainer *)dc {
	[_serviceDelegates removeObject:dc];
}

- (id <BMService>)transformedService:(id <BMService>)service {
    id <BMService> theService = service;
	id <BMService> transformedService = nil;
	if ([self.delegate respondsToSelector:@selector(serviceManager:transformedServiceForService:)]) {
		transformedService = [self.delegate serviceManager:self transformedServiceForService:service];
	}
    if (transformedService == nil && self.serviceTransformer != nil) {
		transformedService = [self.serviceTransformer transformedValue:theService];
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
    if (transformedService == nil && self.serviceTransformer != nil) {
		transformedService = [self.serviceTransformer reverseTransformedValue:theService];
	}
	if (transformedService != nil) {
		theService = transformedService;
	}
    return theService;
}

- (void)addDelegate:(id <BMServiceDelegate>)theDelegate forServiceInstance:(NSString *)instanceIdentifier primary:(BOOL)primary {
	if (theDelegate) {
		BMServiceDelegateContainer *dc = [BMServiceDelegateContainer new];
		dc.delegate = theDelegate;
		dc.serviceInstanceIdentifier = instanceIdentifier;
        dc.primary = primary;
		[self addDelegateContainer:dc];
	}
}

- (void)recordResult:(id)result forService:(id <BMService>)service {
	[self.recorder recordResult:result forRecordingClass:service.classIdentifier withDigest:service.digest];
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
	return _serviceDictionary[instanceIdentifier];
}

- (NSArray<id <BMService>> *)allServices {
	return [_serviceDictionary allValues];
}

- (NSArray<NSString *> *)allServiceInstanceIdentifiers {
	return [_serviceDictionary allKeys];
}

- (void)removeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier {
	[_serviceDictionary removeObjectForKey:instanceIdentifier];
}

- (void)addService:(id <BMService>)service {
	[_serviceDictionary bmSafeSetObject:service forKey:service.instanceIdentifier];
}

@end
