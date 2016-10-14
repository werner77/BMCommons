//
//  BMSOAPFault.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSOAPFault.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMRestKit.h>

@implementation BMSOAPFault

@synthesize faultCode;
@synthesize faultString;

+ (NSArray *)fieldMappingFormatArray {
	return [NSArray arrayWithObjects:
			@"faultCode;faultcode",
			@"faultString;faultstring",
			nil];
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}

- (NSError *)error {
    
    int code = [faultCode intValue];
    
    if (code == 0) {
        code = BM_ERROR_UNKNOWN_ERROR;
    }
    
	return [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SOAP code:code description:faultString];
}

@end
