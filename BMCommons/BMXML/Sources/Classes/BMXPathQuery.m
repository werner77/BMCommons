//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "BMXPathQuery.h"
#import "BMLogging.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <BMCommons/BMCore.h>
#import "BMXMLElement.h"

@implementation BMXPathQuery

@synthesize doc;

- (id)initWithXMLDocument:(NSData *)document {
	if (self == [super init]) {  //TODO: should be only one = ?
		
		/* Load XML document */
		self.doc = xmlReadMemory([document bytes], BMShortenUIntToIntSafely([document length], nil), "", NULL,
								 XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_DTDATTR | XML_PARSE_NOCDATA);
		if (self.doc == NULL) {
			LogError(@"Unable to parse document");
			return nil;
		}
		shouldFreeDoc = YES;
	}
	return self;
}

- (id)initWithHTMLDocument:(NSData *)document {
	if (self == [super init]) {  //TODO: should be only one = ?
		
		/* Load XML document */
		self.doc = htmlReadMemory([document bytes], BMShortenUIntToIntSafely([document length], nil), "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
		
		if (self.doc == NULL) {
			LogError(@"Unable to parse document");
			return nil;
		}
		shouldFreeDoc = YES;
	}
	return self;
}

- (id)initWithDoc:(xmlDocPtr)theDoc {
	if ((self = [super init])) {
		self.doc = theDoc;
		shouldFreeDoc = NO;
	}
	return self;
}


- (void)dealloc {
	if (shouldFreeDoc) {
		xmlFreeDoc(self.doc); 
	}
}

- (NSArray *)performXPathQuery:(NSString *)query
{
    xmlXPathContextPtr xpathCtx = nil; 
    xmlXPathObjectPtr xpathObj = nil; 
	NSMutableArray *resultNodes = nil;
	
	LogDebug(@"Performing XPath query: %@", query);
	
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(self.doc);
    if(xpathCtx == NULL)
	{
		LogError(@"Unable to create XPath context.");		
    } else {
		/* Evaluate xpath expression */
		xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
		if(xpathObj == NULL) {
			LogError(@"Unable to evaluate XPath.");
		} else {
			xmlNodeSetPtr nodes = xpathObj->nodesetval;
			if (nodes) {
				resultNodes = [NSMutableArray array];
				for (NSInteger i = 0; i < nodes->nodeNr; i++)
				{
					xmlNode *nodePtr = nodes->nodeTab[i];
					BMXMLNode *node = nil;
					if (nodePtr->type == XML_TEXT_NODE) {
						node = [BMXMLNode nodeWithXMLNode:nodePtr];
					} else if (nodePtr->type == XML_ELEMENT_NODE) {
						node = [BMXMLElement elementWithXMLNode:nodePtr];
					} 		
					if (node) {
						[resultNodes addObject:node];
					}
				}
			}
		}
	}
    
    /* Cleanup */
    if (xpathObj) xmlXPathFreeObject(xpathObj);
    if (xpathCtx) xmlXPathFreeContext(xpathCtx); 
	
	LogDebug(@"Found nodes: %@", resultNodes);
	
    return resultNodes;
}

@end
