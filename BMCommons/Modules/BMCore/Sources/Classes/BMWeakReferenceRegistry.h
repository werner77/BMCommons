//
//  BMWeakReferenceRegistry.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/3/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMCoreObject.h>

/**
 * Registry for monitoring the deallocation of objects of interest to perform cleanup logic once they are released.
 */
@interface BMWeakReferenceRegistry : BMCoreObject

BM_DECLARE_DEFAULT_SINGLETON

/**
 * Cleanup block definition
 */
typedef void(^BMWeakReferenceCleanupBlock)(void);

/**
 * Registers a reference for monitoring with the supplied cleanup block.
 * The cleanup block gets called once the reference object gets deallocated.
 *
 * It is possible to register the same reference multiple times with different cleanup blocks (even if owner is the same).
 * If this is not intended behavior, check hasRegisteredReference:forOwner: before calling this method.
 *
 * @param reference The object to monitor
 * @param owner An optional owner (may be specified to selectively deregister references)
 * @param cleanup The cleanup block
 */
- (void)registerReference:(id)reference forOwner:(id)owner withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup;

/**
 * Deregisters the specified reference for monitoring. If owner is not nil, only the monitor(s) for the specified owner is/are removed.
 *
 * @param reference The monitored reference
 * @param owner The optional owner of the reference
 */
- (void)deregisterReference:(id)reference forOwner:(id)owner;

/**
 * Checks whether a monitor already exists for the specified reference/owner. If the owner parameter is nil all owners are checked.
 *
 * @param reference The monitored reference
 * @param owner The optional owner
 * @return True if registered, false otherwise.
 */
- (BOOL)hasRegisteredReference:(id)reference forOwner:(id)owner;

@end
