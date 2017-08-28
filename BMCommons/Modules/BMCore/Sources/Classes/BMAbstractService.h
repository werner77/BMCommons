//
//  BMAbstractService.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/2/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMService.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract implementation of the BMService protocol.
 
 This class implements common functionality needed for all services. Normally concrete services extend from this class.
 */
@interface BMAbstractService : BMCoreObject<BMService>

/**
 * Defaults to the service class converted to a NSString as class identifier
 */
+ (NSString *)classIdentifier;

@end

@interface BMAbstractService(Protected)

/**
 Called internally when service is started.
 
 Sends [BMServiceDelegate serviceDidStart:] to its delegate.
 
 @see [BMService execute]
 */
- (void)serviceDidStart;

/**
 Called internally when service is cancelled.
 
 Sends [BMServiceDelegate serviceWasCancelled:] to its delegate.
 
 @see [BMService cancel]
 */
- (void)serviceWasCancelled;

/**
 Called internally when service is sent to background.
 
 Sends [BMServiceDelegate serviceWasSentToBackground:] to its delegate.
 
 @see [BMService sendToBackground]
 */
- (void)serviceWasSentToBackground;

/**
 Called internally when service is sent to background.
 
 Sends [BMServiceDelegate serviceWasSentToForeground:] to its delegate.
 
 @see [BMService sendToForeground]
 */
- (void)serviceWasSentToForeground;

/**
 Sends [BMServiceDelegate service:succeededWithResult:] to its delegate.
 */
- (void)serviceSucceededWithResult:(id)result;

/**
 * Should be called by sub classes when the service succeeds.

 Transforms the raw result to the actual result using [BMAbstractService resultOrErrorByConvertingRawResult:] and subsequently calls
 serviceSucceededWithResult: or serviceFailedWithError: using the converter result or error.

 Sends [BMServiceDelegate service:succeededWithRawResult:] to its delegate.
 */
- (void)serviceSucceededWithRawResult:(id)result;

/**
 Sends [BMServiceDelegate service:failedWithError:] to its delegate.
 */
- (void)serviceFailedWithError:(NSError *)error;

/**
 * Should be called by sub classes when the service fails with the specified raw error.
 *
 * Transforms the error subsequently using [BMAbstractService errorByConvertingError:] and calls serviceFailedWithError: with the transformed error.
 *
 * Sends [BMServiceDelegate service:failedWithRawError:] to its delegate.
 */
- (void)serviceFailedWithRawError:(NSError *)error;

/**
 Should be called by sub classes to signal process.
 
 Sends [BMServiceDelegate service:updatedProgress:withMessage] to its delegate.
 */
- (void)updateProgress:(double)progressPercentage withMessage:(nullable NSString *)message;

/**
 Returns the delegate priority by asking the delegate for its priority using [BMServiceDelegate delegatePriorityForService:].
 
 Default is 0.
 */
- (NSInteger)delegatePriority;

/**
 Override this method to start the execution of the service.
 
 Return YES in case the service started successfully with nil error, or NO in case of error in which case the error pointer should be filled with a meaningful error.
 Don't override the [BMService execute] method. This class implements it by calling this method.
 */
- (BOOL)executeWithError:(NSError * _Nullable * _Nullable)error;

/**
 * Override with custom converting logic to convert the raw result to the final result or error.
 *
 * By default the resultTransformer is used.
 */
- (id)resultOrErrorByConvertingRawResult:(id)result;

/**
 * Override with custom logic to convert the raw error to the actual error as is to be returned by this service.
 *
 * By default the errorTransformer is used.
 */
- (NSError *)errorByConvertingRawError:(NSError *)error;

/**
 * Resets the internal state, is called automatically upon execution.
 */
- (void)reset;

@end


NS_ASSUME_NONNULL_END