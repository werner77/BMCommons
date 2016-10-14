//
//  BMGoogleService.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractService.h>
#import <GTMOAuth2/GTMOAuth2Authentication.h>
#import <GoogleAPIClientForREST/GTLRService.h>

@interface BMGoogleService : BMAbstractService

/**
 Implementation service.
 */
@property (nonatomic, readonly) id googleService;

@property (strong, nonatomic, readonly) GTLRServiceTicket *currentTicket;

/**
 Authorizer implementation.
 */
@property (nonatomic, strong) id <GTMFetcherAuthorizationProtocol> authorizer;

@end

@interface BMGoogleService(Protected)

- (Class)googleServiceClass;
- (GTLRServiceTicket *)initiateService:(GTLRService *)theService withError:(NSError **)error;
- (void)configureService:(GTLRService *)theService;
- (void)setCurrentTicket:(GTLRServiceTicket *)ticket;
- (BOOL)validateWithError:(NSError **)error;

@end
