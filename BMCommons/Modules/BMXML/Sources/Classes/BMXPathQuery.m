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

#import <BMCommons/BMXPathQuery.h>
#import <BMCommons/BMLogging.h>
#import <libxml/globals.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMXMLElement.h>
#import "BMXPathQuery_Private.h"
#import "BMXMLNode_Private.h"

@implementation BMXPathQuery {
	xmlDocPtr doc;
	BOOL shouldFreeDoc;
}

@synthesize doc;

- (id)initWithXMLDocument:(NSData *)document {
	return [self initWithDoc:xmlReadMemory([document bytes], BMShortenUIntToIntSafely([document length], nil), "", NULL,
			XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_DTDATTR | XML_PARSE_NOCDATA) freeWhenDone:YES];
}

- (id)initWithHTMLDocument:(NSData *)document {
	return [self initWithDoc:htmlReadMemory([document bytes], BMShortenUIntToIntSafely([document length], nil), "", NULL,
			HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR) freeWhenDone:YES];
}

- (id)init {
	xmlChar * version = (xmlChar *)"1.0";
	xmlDocPtr theDoc = xmlNewDoc(version);
	return [self initWithDoc:theDoc freeWhenDone:YES];
}

- (id)initWithDoc:(xmlDocPtr)theDoc freeWhenDone:(BOOL)freeWhenDone {
	if ((self = [super init])) {
		self.doc = theDoc;
		shouldFreeDoc = freeWhenDone;
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
						node = [BMXMLNode instanceWithXMLNode:nodePtr];
					} else if (nodePtr->type == XML_ELEMENT_NODE) {
						node = [BMXMLElement instanceWithXMLNode:nodePtr];
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
