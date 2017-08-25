//
//  BMNetworkTester.h
//
//  Created by Werner Altewischer on 1/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMReachability.h>
#import <BMCommons/BMCoreObject.h>

#define BM_NETWORKTESTER_DEFAULT_TEST_HOSTNAME @"www.google.com"

NS_ASSUME_NONNULL_BEGIN

@class BMNetworkTester;

/**
 Delegate protocol for BMNetworkTester.
 */
@protocol BMNetworkTesterDelegate <NSObject>

/**
 Message sent when the BMNetworkTester finished checking.
 */
- (void)networkTesterDidFinish:(BMNetworkTester *)networkTester;

@end

/**
Class for testing network availability asynchronously
*/
@interface BMNetworkTester : BMCoreObject

/**
 The hostname to use for testing. 
 
 In case none is supplied the BMNETWORKTESTER_DEFAULT_TEST_HOSTNAME is used.
 */
@property(strong) NSString *testHostName;

/**
 The delegate to receive response.
 */
@property(nullable, weak) NSObject <BMNetworkTesterDelegate> *delegate;

/**
 The tested network status.
 
 @see BMNetworkStatus
 */
@property(readonly) BMNetworkStatus networkStatus;

/**
 Starts testing network connection asynchronously.
 
 [BMNetworkTesterDelegate networkTesterDidFinish] will be called when done.
 */
- (void)testNetwork;


@end

NS_ASSUME_NONNULL_END
