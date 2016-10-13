//
//  BMObjectMappingParserService.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMObjectMappingParserService.h"
#import "BMObjectMappingParserHandler.h"
#import <BMCommons/BMRestKit.h>

@implementation BMObjectMappingParserService

@synthesize rootXPath, errorXPath, rootElementClass, errorElementClass;

- (id)init {
    if ((self = [super init])) {
        BMRestKitCheckLicense();
    }
    return self;
}


- (BMParserHandler *)handlerForService {
	BMObjectMappingParserHandler *theHandler = [[BMObjectMappingParserHandler alloc] initWithXPath:self.rootXPath
																							   rootElementClass:self.rootElementClass 
													 												 errorXPath:self.errorXPath 
																						  errorRootElementClass:self.errorElementClass
																									   delegate:nil];
	return theHandler;
}

- (BMParserHandler *)errorHandlerForService {
    BMObjectMappingParserHandler *theHandler = [[BMObjectMappingParserHandler alloc] initWithXPath:nil
                                                                                  rootElementClass:nil
                                                                                        errorXPath:self.errorXPath
                                                                             errorRootElementClass:self.errorElementClass
                                                                                          delegate:nil];
	return theHandler;
}

- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)configureParser:(BMParser *)theParser {
	//Default don't do anything
}


@end
