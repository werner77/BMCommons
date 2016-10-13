//
//  BMServiceModelTableViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMServiceModelTableViewController.h"
#import <BMCore/BMApplicationHelper.h>
#import <BMCore/BMServiceManager.h>

@implementation BMServiceModelTableViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];	
}

- (void)viewDidUnload {
	[[BMServiceManager sharedInstance] cancelServiceInstancesForDelegate:self];
    [[BMServiceManager sharedInstance] removeServiceDelegate:self];
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Service

- (void)performService:(id <BMService>)service {
	[[BMServiceManager sharedInstance] performService:service withDelegate:self];
}

#pragma mark -
#pragma mark BMServiceDelegate implementation

/**
 * Implement to act on successful completion of a service. 
 */
- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    [self handleResult:result forService:service];
    [self finishedLoadingWithSuccess:YES];
}

/**
 * Implement to act on failure of a service. 
 */
- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    [self finishedLoadingWithSuccess:NO];
}

- (NSInteger)delegatePriorityForService:(id <BMService>)service {
    return NSIntegerMax;
}

- (void)serviceDidStart:(id <BMService>)service {
    [self startedLoading];
}

- (void)serviceWasCancelled:(id <BMService>)service {
    [self finishedLoadingWithSuccess:NO];
}

#pragma mark -
#pragma mark Overridden methods from super class

- (IBAction)reset {
    [[BMServiceManager sharedInstance] cancelServiceInstancesForDelegate:self];
    [super reset];
}

@end

@implementation BMServiceModelTableViewController(Protected)

- (void)handleResult:(id)result forService:(id<BMService>)service {
    
}

@end
