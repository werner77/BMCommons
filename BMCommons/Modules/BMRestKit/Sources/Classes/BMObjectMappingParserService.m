//
//  BMObjectMappingParserService.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectMappingParserService.h>
#import <BMCommons/BMObjectMappingParserHandler.h>
#import <BMCommons/BMRestKit.h>
#import "BMAbstractMappableObject.h"

@implementation BMObjectMappingParserService

- (instancetype)initWithRootXPath:(NSString *)rootXPath rootElementClass:(Class<BMMappableObject>)rootElementClass
					   errorXPath:(NSString *)errorXPath errorElementClass:(Class<BMMappableObject>)errorElementClass {
	if ((self = [super init])) {
		self.rootXPath = rootXPath;
		self.errorXPath = errorXPath;
		self.rootElementClass = rootElementClass;
		self.errorElementClass = errorElementClass;
	}
	return self;
}

- (id)init {
	return [self initWithRootXPath:nil rootElementClass:[BMAbstractMappableObject class] errorXPath:nil errorElementClass:nil];
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
