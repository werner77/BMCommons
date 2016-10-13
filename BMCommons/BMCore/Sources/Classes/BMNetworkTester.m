//
//  BMNetworkTester.m
//
//  Created by Werner Altewischer on 1/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMNetworkTester.h"

@implementation BMNetworkTester 

@synthesize testHostName = _testHostName, delegate = _delegate, networkStatus = _networkStatus;

- (void)testNetworkInBackground {
    @autoreleasepool { // Top-level pool
    
        BMReachability *r =  [BMReachability reachabilityWithHostName:self.testHostName];
        
        _networkStatus = [r currentReachabilityStatus];
        
        [self.delegate performSelectorOnMainThread:@selector(networkTesterDidFinish:) withObject:self waitUntilDone:NO];
    }  // Release the objects in the pool.	    
}

- (void)testNetwork {
    [self performSelectorInBackground:@selector(testNetworkInBackground) withObject:nil];
}

- (id)init {
    if ((self = [super init])) {
        self.testHostName = BM_NETWORKTESTER_DEFAULT_TEST_HOSTNAME;
    }
    return self;
}


@end
