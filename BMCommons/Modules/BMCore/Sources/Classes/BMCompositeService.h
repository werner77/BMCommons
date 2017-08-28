//
//  BMCompositeService.h
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMAbstractService.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Service that acts as a facade for 2 or more other services that are executed in succession.
 */
@interface BMCompositeService : BMAbstractService<BMServiceDelegate>

/**
 Reference to the currently active underlying service.
 */
@property(nullable, readonly) id <BMService> currentService;

/**
 * Initializes with the specified delegate
 */
- (id)initWithDelegate:(nullable id <BMServiceDelegate>)theDelegate;

@end

@interface BMCompositeService(Protected)

/**
 Executes an underlying service.
 */
- (void)executeService:(id <BMService>)nextService;

/**
 * Mock execute an underlying service.
 */
- (void)mockExecuteService:(id <BMService>)nextService withResult:(id)result isRaw:(BOOL)isRaw;

@end

NS_ASSUME_NONNULL_END
