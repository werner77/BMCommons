//
//  BMGoogleService.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMGoogleService.h>
#import <BMCore/BMErrorHelper.h>
#import <BMGoogle/BMGoogle.h>

@interface BMGoogleService(Private)

@end

@implementation BMGoogleService {
    GDataServiceTicket *currentTicket;
    GDataServiceGoogle *googleService;
}

@synthesize authentication, username, password, googleService, currentTicket;

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
    
    GDataServiceTicket *ticket = [self initiateService:googleService withError:error];
    
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

- (void)configureService:(GDataServiceGoogle *)theService {
    [theService setShouldCacheResponseData:NO];
    [theService setServiceShouldFollowNextLinks:YES];
    [theService setIsServiceRetryEnabled:YES];
    if (self.authentication) {
        [theService setAuthorizer:self.authentication];
    } else {
        [theService setUserCredentialsWithUsername:self.username password:self.password];
    }
}

- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error {
    
    if (error) {
        *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVICE code:BM_ERROR_NOT_IMPLEMENTED description:BMLocalizedString(@"Method not implemented", nil)];
    }
    
    return nil;
}

- (Class)googleServiceClass {
    return nil;
}

- (void)setCurrentTicket:(GDataServiceTicket *)ticket {
    if (ticket != currentTicket) {
        [currentTicket cancelTicket];
        currentTicket = ticket;
    }
}

- (BOOL)validateWithError:(NSError **)error {
    return YES;
}

@end
