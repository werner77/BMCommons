//
//  BMErrorHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCore/BMErrorCodes.h>

/**
 Utility methods for creating/manipulating NSError objects.
 */
@interface BMErrorHelper : BMCoreObject {

}

/**
 Returns a string representing the specified Mac error code
 */
+ (NSString *)stringForErrorCode:(OSStatus)errorCode;

/**
 Returns an NSError object for the specified domain, code and localized description
 */
+ (NSError *)errorForDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;

/**
 Returns an error for the specified domain, code, localized description and underlying error.
 
 @param domain The domain for the error
 @param code The error code
 @param description The description for the error
 @param underlyingError The underlying NSError object.
 @return The error object
 */
+ (NSError *)errorForDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description underlyingError:(NSError *)underlyingError;

/**
 Returns an NSError object with domain ERROR_DOMAIN_OTHER and code ERROR_CODE_UNKNOWN with the specified description.
 */
+ (NSError *)genericErrorWithDescription:(NSString *)description;

/**
 Returns an NSError object with domain ERROR_DOMAIN_OTHER and code ERROR_CODE_UNKNOWN with the specified description.
 
 @param description The description for the error
 @param underlyingError The underlying NSError object.
 @return The error object
 */
+ (NSError *)genericErrorWithDescription:(NSString *)description underlyingError:(NSError *)underlyingError;

@end

@interface NSError(BMCommons)

/**
 Underlying error for this error.
 */
- (NSError *)underlyingError;

@end
