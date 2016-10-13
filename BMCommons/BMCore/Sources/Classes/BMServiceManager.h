//
//  BMServiceManager.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <BMCommons/BMService.h>
#import <BMCommons/BMCoreObject.h>

@class BMServiceManager;
@class BMDataRecorder;

@protocol BMServiceManagerDelegate<NSObject>

@optional

/**
 * If implemented and a non-nil result is returned, this result is used to mock the service execution instead of actually executing the service.
 *
 * If an NSError is returned the service will mock-fail with this error.
 *
 * The isRaw boolean may be set to notify the service manager that the mocked result is a raw result instead of a converted result.
 * Defaults to NO.
 */
- (id)serviceManager:(BMServiceManager *)serviceManager mockResultForService:(id <BMService>)service isRaw:(BOOL *)isRaw;

/**
 * If implemented with a non-nil result, the transformed service will be used instead of the actual service when executing the supplied service.
 *
 * Use this for example when wrapping a service to add error handling, retry, etc.
 * Note that for seamless working the classIdentifier of the transformed service should be equal to the classIdentifier of the original service!
 * Preferably the instanceIdentifiers match too.
 *
 * If nil is returned or not implemented, the BMServiceManager.serviceTransformer is used (if set) to transform a service back and forth.
 *
 * Implement this in tandem with the delegate method [BMServiceManagerDelegate serviceManager:reverseTransformedServiceForService:] to transform the service back to the actual service upon completion.
 *
 * @see BMWrapperService
 * @see [BMServiceManagerDelegate serviceManager:reverseTransformedServiceForService:]
 * @see BMServiceManager.serviceTransformer
 */
- (id <BMService>)serviceManager:(BMServiceManager *)serviceManager transformedServiceForService:(id <BMService>)service;

/**
 * Reverse transforms a service back that was previously transformed.
 *
 * Implement this in tandem with the delegate method [BMServiceManagerDelegate serviceManager:transformedServiceForService:]
 *
 * @see BMWrapperService
 * @see [BMServiceManagerDelegate serviceManager:transformedServiceForService:]
 * @see BMServiceManager.serviceTransformer
 */
- (id <BMService>)serviceManager:(BMServiceManager *)serviceManager reverseTransformedServiceForService:(id <BMService>)service;

@end

/**
 Class that manages the execution of services and acts as a registry for delegates that listen to service events.
 
 Although possible to execute BMService instances directly (using [BMService execute]) using this class is the prefered way of executing services.
 Use performService:withDelegate: to execute any service and register it with this instance.
 */
@interface BMServiceManager : BMCoreObject<BMServiceDelegate> {
@private
	NSMutableDictionary *_serviceDictionary;
	NSMutableArray *_serviceDelegates;
	NSValueTransformer *_serviceTransformer;
}

@property (nonatomic, weak) id <BMServiceManagerDelegate> delegate;

/**
 * Access this object for recording/playback functionality.
 */
@property (nonatomic, readonly) BMDataRecorder *recorder;

/**
 An optional transformer that is used to transform the supplied service before executing it
 (performService, forward transformation)
  and to transform it back (reverse tranformation) if automaticallyReverseTransformServices is set to true.

  The classIdentifier of the tranformed service should be equal to the classIdentifier of the original service for seamless integration.
  Preferably the instanceIdentifiers match also.

  @see [BMServiceManagerDelegate serviceManager:transformedServiceForService:]
 */
@property (nonatomic, strong) NSValueTransformer *serviceTransformer;

/**
 * If set to true a transformed service is automatically reverse transformed before it is handed to the delegates.
 * This allows for fully transparent transformation to add functionality to existing services.
 *
 * Default is true.
 */
@property (nonatomic, assign) BOOL automaticallyReverseTransformServices;

/**
 Add/Remove delegate to receive all service events
 */
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate;
- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate;

/**
 Add/Remove delegate for service class specific events
 
 @see [BMService classIdentifier]
 */
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier;
- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forClassIdentifier:(NSString *)classIdentifier;

/**
 Add/Remove delegate for service instance specific events
 
 @see [BMService instanceIdentifier]
 */
- (void)addServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier;
- (void)removeServiceDelegate:(id <BMServiceDelegate>)theDelegate forInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Removes all delegates for the specified service instance.
 
 @see [BMService instanceIdentifier]
 */
- (void)removeServiceDelegatesForInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Returns the primary delegate for the specified service instance. 
 
 The primary delegate is the delegate that was supplied to the method performService:withDelegate:.
 
 @see [BMService instanceIdentifier]
 */
- (id <BMServiceDelegate>)primaryServiceDelegateForInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 * Returns the primary delegate or owner of the BMBlockServiceDelegate in case the primary delegate is a BMBlockServiceDelegate instance.
 */
- (id <BMServiceDelegate>)ownerForServiceWithInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Cancels the service instance and removes all delegates for that specific instance
 
 @see [BMService cancel]
 */
- (void)cancelServiceWithInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Sends the specified service instance to background.
 
 @see [BMService sendToBackground]
 */
- (BOOL)sendServiceToBackgroundWithInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Cancels the service instances with same instance identifier as for which the primary delegate was registered and removes the delegate for these instances. The primary delegate is the delegate that was supplied to the method performService:withDelegate:.
 
 This method will also cancel services the have a BMBlockServiceDelegate for which the specified delegate is the owner.
 
 @param delegate The primary delegate for which to cancel the service
 @see [BMService cancel]
 */
- (void)cancelServiceInstancesForDelegate:(id)delegate;

/**
 Cancels services of the specified class (does not affect delegates)
 
 @see [BMService cancel]
 @see [BMService classIdentifier]
 */
- (void)cancelServicesWithClassIdentifier:(NSString *)classIdentifier;

/**
 Cancels services of the specified class that have the specified primary delegate.
 
 @see [BMService cancel]
 @see [BMService classIdentifier]
 */
- (void)cancelServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate;

/**
 Cancels all services (does not affect delegates)
 */
- (void)cancelServices;

/**
 Call to perform the service (calls [BMService execute])
 
 @param service The service to execute
 @param delegate The primary delegate to register for this service
 @see [BMService execute]
 */
- (NSString *)performService:(id <BMService>)service withDelegate:(id <BMServiceDelegate>)delegate;

/**
 Checks whether a service is active with the specified instance identifier.
 
 @see [BMService instanceIdentifier]
 */
- (BOOL)isPerformingServiceWithInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Checks whether a service is active for the specified service class and primary delegate.
 
 Also checks BMBlockServiceDelegates by matching the owner against the specified delegate.
 If one of the arguments (classIdentifier, delegate) is nil, that argument is ignored.
 */
- (BOOL)isPerformingServiceWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)theDelegate;

/**
 Checks whether a service is active for the specified primary delegate.
 
 Also checks BMBlockServiceDelegates by matching the owner against the specified delegate.
 */
- (BOOL)isPerformingServiceForDelegate:(id)theDelegate;

/**
 Checks whether a service is active for the specified class.
 
 @see [BMService classIdentifier]
 */
- (BOOL)isPerformingServiceWithClassIdentifier:(NSString *)classIdentifier;

/**
 Returns the active services for the specified class and primary delegate.
 If the delegate supplied is nil all active services of the supplied class are returned.
 If the classIdentifier is nil all active services are returned.
 Also returns services that use BMBlockDelegates for which the specified delegate is owner.

 This method returns the reverse transformed service if transformation has been done by either the delegate or the serviceTransformer and the boolean performReverseTransformation is set to true.
 
 @see [BMService classIdentifier]
 */
- (NSArray *)activeServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)delegate performReverseTransformation:(BOOL)performReverseTransformation;

/**
 * Returns the active services for the specified class and delegate, defaulting performReverseTransformation with the value set in the property [BMServiceManager automaticallyReverseTransformServices].
 *
 * @see [BMServiceManager activeServicesWithClassIdentifier:forDelegate:performReverseTransformation:]
 */
- (NSArray *)activeServicesWithClassIdentifier:(NSString *)classIdentifier forDelegate:(id)delegate;

/**
 Returns the active service with the specified instance identifier or nil if not found.

 This method returns the reverse transformed service if transformation has been done by either the delegate or the serviceTransformer and the boolean performReverseTransformation is set to true.
 
 @see [BMService instanceIdentifier]
 */
- (id <BMService>)activeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier performReverseTransformation:(BOOL)performReverseTransformation;

/**
 Returns the active service with the specified instance identifier or nil if not found.

 This method defaults performReverseTransformation with the value set in the property [BMServiceManager automaticallyReverseTransformServices].

 @see [BMServiceManager activeServiceWithInstanceIdentifier:performReverseTransformation:]
 */
- (id <BMService>)activeServiceWithInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 The singleton service manager instance.
 */
+ (BMServiceManager *)sharedInstance;

/**
 Returns true iff the classIdentifier of the supplied service matches the supplied service class identifier.
 */
- (BOOL)service:(id <BMService>)service matchesClassIdentifier:(NSString *)serviceClassIdentifier;

/**
 Returns true iff the supplied service matches the supplied instance identifier.
 */
- (BOOL)service:(id <BMService>)service matchesInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Returns true iff the two supplied instance identifiers match.
 */
- (BOOL)instanceIdentifier:(NSString *)identifier matchesIdentifier:(NSString *)otherIdentifier;

/**
 Returns true iff the two supplied class identifiers match.
 */
- (BOOL)classIdentifier:(NSString *)classIdentifier matchesIdentifier:(NSString *)otherClassIdentifier;

@end

