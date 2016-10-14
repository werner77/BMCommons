//
//  BMErrorCodes.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/27/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

// Error Domains

#import <BMCommons/BMHTTPStatusCodes.h>

//Error related to invalid/inconsistent settings
#define BM_ERROR_DOMAIN_SETTINGS @"BM_ERROR_DOMAIN_SETTINGS"

//Error related to data integrity
#define BM_ERROR_DOMAIN_DATA @"BM_ERROR_DOMAIN_DATA"

//Error setting up the client to connect to a service or set up an internal call (invalid URL, no request, no data, etc)
#define BM_ERROR_DOMAIN_CLIENT @"BM_ERROR_DOMAIN_CLIENT"

//Error returned from the service (connection was ok, but the data returned signalled an error)
#define BM_ERROR_DOMAIN_SERVICE @"BM_ERROR_DOMAIN_SERVICE"

//Invalid response from server (no response or unrecognized response)
#define BM_ERROR_DOMAIN_SERVER @"BM_ERROR_DOMAIN_SERVER"

//SOAP fault
#define BM_ERROR_DOMAIN_SOAP @"BM_ERROR_DOMAIN_SOAP"

//Other error
#define BM_ERROR_DOMAIN_OTHER @"BM_ERROR_DOMAIN_OTHER"

//<100 Are client error codes
#define BM_ERROR_UNKNOWN_ERROR 10
#define BM_ERROR_INVALID_URL 11
#define BM_ERROR_INVALID_DATA 12
#define BM_ERROR_VALIDATION_ERROR 13
#define BM_ERROR_ASSERTION 14
#define BM_ERROR_INVALID_RESPONSE 20
#define BM_ERROR_NO_CONNECTION 22
#define BM_ERROR_CONNECTION_FAILURE 23
#define BM_ERROR_NO_REQUEST 24
#define BM_ERROR_AUTHENTICATION 25
#define BM_ERROR_AUTHORIZATION 26
#define BM_ERROR_SECURITY 27
#define BM_ERROR_NOT_IMPLEMENTED 28

// > 100 are HTTP error codes

/**
 Helper class containing definitions for error codes/domains
 */
@interface BMErrorCodes : BMCoreObject  {
	
}

+ (NSString *)errorMessageForCodeAsString:(int)code;

@end
