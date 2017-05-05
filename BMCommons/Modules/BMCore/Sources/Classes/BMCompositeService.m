//
//  BMCompositeService.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCompositeService.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMCore.h>

@interface BMCompositeService()

@property(strong) id <BMService> currentService;

@end

@implementation BMCompositeService {
}

- (id)initWithDelegate:(id <BMServiceDelegate>)theDelegate {
	if ((self = [super init])) {
		self.delegate = theDelegate;
	}
	return self;	
}

- (void)dealloc {
	self.currentService.delegate = nil;
}

#pragma mark -
#pragma mark BMServiceDelegate

- (void)service:(id)service succeededWithResult:(id)result {
	[self serviceSucceededWithRawResult:result];
}

- (void)service:(id)theService failedWithError:(NSError *)error {
	[self serviceFailedWithRawError:error];
}

- (void)serviceWasCancelled:(id <BMService>)theService {
    [self serviceWasCancelled];
}

#pragma mark -
#pragma mark Overridden methods

- (void)reset {
    [super reset];
    self.currentService = nil;
}

- (BOOL)executeWithError:(NSError **)error {
    if (error) {
        *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_ASSERTION description:BMLocalizedString(@"Not implemented", nil)];
    }
	return NO;
}

- (void)executeService:(id <BMService>)nextService {
	if (nextService != self.currentService) {
		self.currentService = nextService;
	}
	nextService.delegate = self;
	[nextService execute];
}

- (void)mockExecuteService:(id <BMService>)nextService withResult:(id)result isRaw:(BOOL)isRaw {
    if (nextService != self.currentService) {
        self.currentService = nextService;
    }
    nextService.delegate = self;
	[nextService mockExecuteWithResult:result isRaw:isRaw];
}

- (void)cancel {
	if (self.currentService) {
		[self.currentService cancel];
	} else {
		[super cancel];	
	}
}

@end
