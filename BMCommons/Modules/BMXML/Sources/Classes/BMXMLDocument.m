/***

Important:

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not 
final. Apple is supplying this information to help you plan for the adoption of 
the technologies and programming interfaces described herein. This information 
is subject to change, and software implemented based on this sample code should 
be tested with final operating system software and final documentation. Newer 
versions of this sample code may be provided with future seeds of the API or 
technology. For information about updates to this and other developer 
documentation, view the New & Updated sidebars in subsequent documentation seeds.

***/

/*

File: XMLDocument.m
Abstract: Creates an XMLDocument from an NSString or NSURL.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc.
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <BMCommons/BMXMLDocument.h>
#import <BMCommons/BMXMLReader.h>
#import <libxml/globals.h>
#import "BMXMLDocument_Private.h"
#import "BMXMLNode_Private.h"

@implementation BMXMLDocument {
@private
    xmlDocPtr _xmlDocument;
    BMXMLElement *_rootElement;
}

@synthesize xmlDocument = _xmlDocument;
@synthesize rootElement = _rootElement;

- (instancetype)initWithXMLDocument:(xmlDocPtr)doc {
    self = [super init];

    if (self) {
        if (doc == nil) {
            return nil;
        }
        self.xmlDocument = doc;
        xmlNode *root_element = xmlDocGetRootElement(doc);

        if (root_element == nil) {
            return nil;
        }
        BMXMLElement *element = [BMXMLElement instanceWithXMLNode:root_element];
        self.rootElement = element;
    }
    return self;
}

- (instancetype)initWithRootElement:(BMXMLElement *)theRootElement {
    xmlChar * version = (xmlChar *)"1.0";
    xmlDocPtr theDoc = xmlNewDoc(version);
    xmlDocSetRootElement(theDoc, theRootElement.libXMLNode);
    theRootElement.libXMLDocument = theDoc;
    return [self initWithXMLDocument:theDoc];
}

- (id)init {
    BMXMLElement *rootElement = [BMXMLElement elementWithName:@""];
    return [self initWithRootElement:rootElement];
}

+ (BMXMLDocument *)documentWithXMLDocument:(xmlDocPtr)doc
{
    return [[self alloc] initWithXMLDocument:doc];
}

+ (BMXMLDocument *)documentWithData:(NSData *)data error:(NSError **)error
{
	return [BMXMLReader parseXMLData:data parseError:error];
}

+ (BMXMLDocument *)documentWithXMLString:(NSString *)string error:(NSError **)error
{
    return [BMXMLReader parseXMLString:string parseError:error];
}

+ (BMXMLDocument *)documentWithContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    return [BMXMLReader parseXMLFileAtURL:URL parseError:error];
}

+ (BMXMLDocument *)documentWithRootElement:(BMXMLElement *)theRootElement {
	return [[self alloc] initWithRootElement:theRootElement];
}

- (NSString *)XMLString
{
    return [self XMLStringWithFormatting:NO];
}

- (NSString *)XMLStringWithFormatting:(BOOL)format
{
    xmlChar *XMLStr;
    xmlDocDumpFormatMemoryEnc    (self.xmlDocument, &XMLStr, NULL, "UTF-8", format ? 1 : 0);

    if (XMLStr) {
        NSString *nsxmlStr = [NSString stringWithUTF8String:(const char *)XMLStr];
        xmlFree(XMLStr);
        return nsxmlStr;
    }
    return nil;
}


- (void)dealloc
{
	if (self.xmlDocument) {
		xmlFreeDoc(self.xmlDocument);
	}

}

@end
