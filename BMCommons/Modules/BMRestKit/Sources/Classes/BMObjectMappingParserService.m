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
#import "BMJSONParser.h"

@implementation BMObjectMappingParserService

static NSString * const kJSONPrefix = @"json";

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
	BMObjectMappingParserHandler *theHandler = [[BMObjectMappingParserHandler alloc] initWithXPath:[self modifiedXPathForXPath:self.rootXPath]
																							   rootElementClass:self.rootElementClass 
													 												 errorXPath:[self modifiedXPathForXPath:self.errorXPath]
																						  errorRootElementClass:self.errorElementClass
																									   delegate:nil];
	return theHandler;
}

- (BMParserHandler *)errorHandlerForService {
    BMObjectMappingParserHandler *theHandler = [[BMObjectMappingParserHandler alloc] initWithXPath:nil
                                                                                  rootElementClass:nil
                                                                                        errorXPath:[self modifiedXPathForXPath:self.errorXPath]
                                                                             errorRootElementClass:self.errorElementClass
                                                                                          delegate:nil];
	return theHandler;
}

- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)modifiedXPathForXPath:(NSString *)xPath {
	if ([self.parserClass isKindOfClass:BMJSONParser.class]) {
		return [NSString stringWithFormat:@"/%@%@%@", kJSONPrefix, [xPath hasPrefix:@"/"] ? @"" : @"/", xPath];
	} else {
		return xPath;
	}
}

- (void)configureParser:(BMParser *)theParser {
	if ([theParser isKindOfClass:[BMJSONParser class]]) {
		BMJSONParser *jsonParser = (BMJSONParser *)theParser;
		jsonParser.jsonRootElementName = kJSONPrefix;
	}
}


@end
