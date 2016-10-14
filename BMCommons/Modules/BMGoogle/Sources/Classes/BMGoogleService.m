//
//  BMGoogleService.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMGoogleService.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMGoogle/BMGoogle.h>

@interface BMGoogleService(Private)

@end

@implementation BMGoogleService {
    GTLRServiceTicket *currentTicket;
    GTLRService *googleService;
}

@synthesize authorizer, googleService, currentTicket;

- (id)init {
    if ((self = [super init])) {
        googleService = [[self googleServiceClass] new];
    }
    return self;
}


#pragma mark - Overridden methods

- (void)cancel {
    [self setCurrentTicket:nil];
    [super cancel];
}

- (BOOL)executeWithError:(NSError **)error {
    
    if (![self validateWithError:error]) {
        return NO;
    }
    
    [self configureService:googleService];
    
    GTLRServiceTicket *ticket = [self initiateService:googleService withError:error];
    
    [self setCurrentTicket:ticket];
    
    BOOL succesful = (currentTicket != nil);
    
    if (!succesful && *error == nil) {
        *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVICE
                                          code:BM_ERROR_NO_REQUEST
                                   description:BMLocalizedString(@"Could not initialize Google service", nil)];
    }
    return succesful;
}

@end

@implementation BMGoogleService(Protected)

#pragma mark - Protected methods

- (void)configureService:(GTLRService *)theService {
    if (self.authorizer) {
        [theService setAuthorizer:self.authorizer];
    }
}

- (GTLRServiceTicket *)initiateService:(GTLRService *)theService withError:(NSError **)error {
    
    if (error) {
        *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVICE code:BM_ERROR_NOT_IMPLEMENTED description:BMLocalizedString(@"Method not implemented", nil)];
    }
    
    return nil;
}

- (Class)googleServiceClass {
    return nil;
}

- (void)setCurrentTicket:(GTLRServiceTicket *)ticket {
    if (ticket != currentTicket) {
        [currentTicket cancelTicket];
        currentTicket = ticket;
    }
}

- (BOOL)validateWithError:(NSError **)error {
    return YES;
}

@end
