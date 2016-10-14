//
//  BMJSONParserTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMJSONParserTestCase.h"
#import <BMCommons/BMJSONParser.h>
#import <BMCommons/BMCore.h>

@implementation BMJSONParserTestCase

- (void)setUp {
}

- (void)tearDown {
}

- (void)testParseJSON {
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
	
	
	BMJSONParser *parser = [[BMJSONParser alloc] initWithData:jsonData];
	parser.delegate = self;
	parser.progressDelegate = self;
	
	BOOL result = [parser parse];
	
	[parser release];
	
	NSLog(@"Result: %d", result);
	
}

- (void)testParseEmptyJSON {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test_empty" ofType:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
	
	
	BMJSONParser *parser = [[BMJSONParser alloc] initWithData:jsonData];
	parser.delegate = self;
	parser.progressDelegate = self;
	
	BOOL result = [parser parse];
	
	[parser release];
	
	NSLog(@"Result: %d", result);
    
    
}


#pragma mark -
#pragma mark BMParserDelegate implementation

// Document handling methods
- (void)parserDidStartDocument:(BMParser *)parser {
	LogDebug(@"Started document");
}


// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(BMParser *)parser {
	LogDebug(@"Ended document");
}

- (void)parser:(BMParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	
	
	NSMutableString *attributeString = [NSMutableString string];
	
	for (NSString *attribute in attributeDict) {
		[attributeString appendFormat:@" %@=\"%@\"", attribute, [attributeDict objectForKey:attribute]];
	}
	
	LogDebug(@"<%@%@>", elementName, attributeString);
}


- (void)parser:(BMParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	LogDebug(@"</%@>", elementName);
}

- (void)parser:(BMParser *)parser foundCharacters:(NSString *)string {
	LogDebug(@"%@", string);
}

- (void)parser:(BMParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    LogTrace();
}


- (void)parser:(BMParser *)parser foundComment:(NSString *)comment {
    LogTrace();
}

- (void)parser:(BMParser *)parser parseErrorOccurred:(NSError *)error {
	LogDebug(@"Parser error occured: %@", error);
}

- (void)parser:(BMParser *)parser validationErrorOccurred:(NSError *)validationError {
	LogTrace();
}

#pragma mark -
#pragma mark BMParserProgressDelegate implementation

- (void) parser: (BMParser *) parser updateProgress: (float) progress {
	LogDebug(@"Update progress: %f", progress);
}

@end
