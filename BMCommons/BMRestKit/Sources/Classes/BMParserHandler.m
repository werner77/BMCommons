//
//  BMParserHandler.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/12/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMParserHandler.h"
#import <BMRestKit/BMRestKit.h>

@implementation BMParserHandler

@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        BMRestKitCheckLicense();
    }
    return self;
}

- (void)parser:(BMParser *)parser didStartDocumentOfType:(NSString *)documentType {
}

- (void)parserDidEndDocument:(BMParser *)parser {
}

- (void)parser:(BMParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (void)parser:(BMParser *)parser foundCharacters:(NSString *)string {
}

- (void)parser:(BMParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
}

- (void)parser:(BMParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}

- (id)result {
	return nil;
}

- (NSError *)error {
	return nil;
}

@end
