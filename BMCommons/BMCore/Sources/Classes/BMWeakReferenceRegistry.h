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

@interface BMWeakReferenceRegistry : BMCoreObject

BM_DECLARE_DEFAULT_SINGLETON

typedef void(^BMWeakReferenceCleanupBlock)(void);

- (void)registerReference:(id)reference withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup;
- (void)deregisterReference:(id)reference;

@end
