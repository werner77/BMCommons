//
//  BMBlockServiceDelegate.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <BMCommons/BMService.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Success block for service.
 */
typedef void (^BMServiceSuccessBlock)(id result);

/**
 Failure block for service.
 
 In case of error the error is non-nil, in case of cancel the error is nil and the boolean cancelled is true.
 */
typedef void (^BMServiceFailureBlock)(BOOL cancelled, NSError * _Nullable error);

/**
 Implementation of BMServiceDelegate that allows the use of blocks for the callbacks
 
 [BMServiceDelegate service:succeededWithResult:] and
 [BMServiceDelegate service:failedWithError:]
 */
@interface BMBlockServiceDelegate : BMCoreObject<BMServiceDelegate>

+ (BMBlockServiceDelegate *)delegateWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure;
+ (BMBlockServiceDelegate *)delegateWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure owner:(id)owner;

/**
 Returns an array of all running BMBlockDelegates (that are delegates for a service in progress) for the specified owner reference.
 */
+ (NSArray *)activeBlockDelegatesForOwner:(id)owner;

/**
 Optional reference to the owner of the block.
 
 If the owner is deallocated the service will automatically be cancelled.
 */
@property (weak, nullable) id owner;

/**
 The service for which this object is a delegate. 
 
 This property is only non-nil when the service is active.
 */
@property (weak, readonly, nullable) id<BMService> service;

- (id)initWithSuccess:(nullable BMServiceSuccessBlock)success failure:(nullable BMServiceFailureBlock)failure;
- (id)initWithSuccess:(nullable BMServiceSuccessBlock)success failure:(nullable BMServiceFailureBlock)failure owner:(nullable id)owner NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END