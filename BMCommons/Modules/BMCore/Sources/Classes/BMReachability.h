//
//  BMReachability.h
//
//  Created by Werner Altewischer on 4/30/10.
//  Copyright 2010 BehindMedia All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 File: Reachability.h
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 
 Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */


#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <BMCommons/BMCoreObject.h>

typedef NS_ENUM(NSUInteger, BMNetworkStatus) {
    BMNetworkStatusNotReachable = 0,
    BMNetworkStatusReachableViaWiFi,
    BMNetworkStatusReachableViaWWAN
};

NS_ASSUME_NONNULL_BEGIN

#define BMReachabilityChangedNotification @"BMNetworkReachabilityChangedNotification"

typedef struct sockaddr_in BMSockAddressIn;

/**
 Network reachability tester.
 
 Use BMNetworkTester to perform the actual testing instead. The latter class will ensure proper threading.
 
 @see BMNetworkTester
 */
@interface BMReachability: BMCoreObject

/**
 * Checks the reachability of a particular host name.
 * @param hostName The host name to check for.
 */
+ (nullable BMReachability*) reachabilityWithHostName: (NSString*) hostName;

/**
 * Checks the reachability of a particular IP address.
 * @param hostAddress the ip address
 */
+ (nullable BMReachability*) reachabilityWithAddress: (const BMSockAddressIn*) hostAddress;

/**
 * Checks whether the default internet route is available.
 * Should be used by applications that do not connect to a particular host
 */
+ (nullable BMReachability*) reachabilityForInternetConnection;

/**
 * Checks whether a local wifi connection is available.
 */
+ (nullable BMReachability*) reachabilityForLocalWiFi;

/**
 * Starts listening for reachability notifications on the current run loop
 *
 * @return true if successful, false otherwise
 */
- (BOOL)startNotifier;

/**
 * Stops listening for reachability notifications.
 */
- (void)stopNotifier;

/**
 * The current reachability status.
 */
- (BMNetworkStatus) currentReachabilityStatus;

/**
 * Whether or not a connection is required.
 */
- (BOOL) connectionRequired;

@end

NS_ASSUME_NONNULL_END
