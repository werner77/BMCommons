//
//  BMGoogleService.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCore/BMAbstractService.h>
#import <GData/GTMOAuth2Authentication.h>

@class GDataServiceTicket;
@class GDataServiceGoogle;

@interface BMGoogleService : BMAbstractService

/**
 Implementation service.
 */
@property (nonatomic, readonly) id googleService;

@property (strong, nonatomic, readonly) GDataServiceTicket *currentTicket;

/**
 OAuth authentication token.
 
 Either supply oauth authentication or username/password. OAuthtoken will take precedence
 */
@property (nonatomic, strong) GTMOAuth2Authentication *authentication;

/**
 Username for authentication.
 
 @see authentication.
 */
@property (nonatomic, strong) NSString *username;

/**
 Password for authentication.
 
 @see authentication.
 */
@property (nonatomic, strong) NSString *password;

@end

@interface BMGoogleService(Protected)

- (Class)googleServiceClass;
- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error;
- (void)configureService:(GDataServiceGoogle *)theService;
- (void)setCurrentTicket:(GDataServiceTicket *)ticket;
- (BOOL)validateWithError:(NSError **)error;

@end