//
//  BMErrorHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMErrorHelper.h>

@implementation BMErrorHelper

+ (NSString *)stringForErrorCode:(OSStatus)errorCode {
	
	char resultString[4];
	for (int i = 0; i < 4; ++i) {
		resultString[i] = (errorCode >> (8 * (3 - i))) & 0xFF;
	}
	
	return [NSString stringWithCString:resultString encoding:[NSString defaultCStringEncoding]];
}

+ (NSError *)errorForDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description {
    return [self errorForDomain:domain code:code description:description underlyingError:nil];
}

+ (NSError *)errorForDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description underlyingError:(NSError *)underlyingError {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (description) {
        [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    }
    
    if (underlyingError) {
        [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    }
    
    NSError *error = [NSError errorWithDomain:domain code:code
                                     userInfo:userInfo];
    return error;
    
}

+ (NSError *)genericErrorWithDescription:(NSString *)description underlyingError:(NSError *)underlyingError {
    return [self errorForDomain:BM_ERROR_DOMAIN_OTHER code:BM_ERROR_UNKNOWN_ERROR description:description underlyingError:underlyingError];
}

+ (NSError *)genericErrorWithDescription:(NSString *)description {
	return [self genericErrorWithDescription:description underlyingError:nil];
}

@end

@implementation NSError(BMCommons)

/**
 Underlying error for this error.
 */
- (NSError *)underlyingError {
    return self.userInfo[NSUnderlyingErrorKey];
}

@end

