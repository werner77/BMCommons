/*
 *  ServiceResponseContainer.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 12/09/09.
 *  Copyright 2009 BehindMedia. All rights reserved.
 *
 */

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol defining a response object containing a result.
 
 Useful for BMService implementations.
 
 @see [BMService service:succeededWithResult:]
 @see [BMService service:failedWithError:]
 */
@protocol BMResponseContainer<NSObject>

/**
 * Gets the result of the service request
 */
- (nullable id)result;

@end

NS_ASSUME_NONNULL_END
