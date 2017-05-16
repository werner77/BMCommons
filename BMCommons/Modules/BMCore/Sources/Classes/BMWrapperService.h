//
// Created by Werner Altewischer on 31/08/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCompositeService.h>

/**
 * Service which wraps another service to possibly add functionality to it such as retry, error handling, etc.
 *
 * This service is fully transparant in the sense that it forwards the classIdentifier, instanceIdentifier, raw result/error and final result/error of the wrapped service.
 * Result transformation by this service on top of the wrapped service is not supported, so the resultTransformer/errorTransformer properties have no effect.
 */
@interface BMWrapperService : BMCompositeService

/**
 * The wrapped service.
 */
@property (readonly) id<BMService> wrappedService;

/**
 * Initializes with the specified wrapped service.
 *
 * @param wrappedService The wrapped service
 */
- (instancetype)initWithWrappedService:(id<BMService>)wrappedService;

@end

@interface BMWrapperService(Protected)

/**
 * Executes the wrapped service.
 */
- (void)executeWrappedService;

/**
 * Mocks execution of the wrapped service with the specified result, specifying wether the result is a raw result
 * (before transformation) or a final result (after transformation).
 *
 * @param result The result
 * @param isRaw Specifies wether the mocked result is raw or converted.
 */
- (void)mockExecuteWrappedServiceWithResult:(id)result isRaw:(BOOL)isRaw;

/**
 * In case service != self.wrappedService this method is called.
 * Should be implemented by sub classes to override result handling for other services than the wrapped service.
 *
 * @param result The result as returned by the specified service
 * @param service The service
 * @return YES to automatically retry the wrapped service, NO otherwise (which is the default).
 */
- (BOOL)handleResult:(id)result forService:(id <BMService>)service;

/**
 * In case of a service failure this method is called (also in case of a failure for the wrapped service).
 * Implement error handling and return YES. If NO is returned the error is forwarded.
 *
 * @param error The error as returned by the specified service
 * @param service The service
 * @return YES to signal the error could be handled (error is suppressed). If NO is returned (which is the default) the error is forwarded as failure for this service.
 */
- (BOOL)handleError:(NSError *)error forService:(id <BMService>)service;

@end
