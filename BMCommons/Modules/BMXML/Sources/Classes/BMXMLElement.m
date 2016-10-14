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
 
 File: XMLElement.m
 Abstract: An element in an XML document.
 
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

#import <BMCommons/BMXMLElement.h>
#import <libxml/xmlmemory.h>
#import <libxml/xpath.h>
#import <libxml/globals.h>
#import <libxml/xmlerror.h>
#import <libxml/parserInternals.h>
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>
#import <libxml/xpathInternals.h>
#import "BMXMLUtilities.h"
#import <BMCommons/BMOrderedDictionary.h>
#import "BMXMLElement_Private.h"

typedef NS_ENUM(NSUInteger, JSONElementType) {
    JSONElementTypeSingle = 0,
    JSONElementTypeArray = 1,
    JSONElementTypeFirst = 2,
    JSONElementTypeLast = 4,
    JSONElementTypeEmpty = 8
};

@interface BMXMLElement()
- (NSArray *)_nodesForXPath:(NSString *)XPath error:(NSError **)outError;
- (void)appendJSONString:(NSMutableString *)descriptionString withAttributePrefix:(NSString *)attributePrefix textContentIdentifier:(NSString *)textContentIdentifier elementType:(JSONElementType)elementType;
@end

@implementation BMXMLElement  {
    xmlXPathContextPtr _XPathContext;
}

static NSArray * childElementsOf(xmlNodePtr a_node, BMXMLElement *contextElement);
static NSDictionary *getElementAttributes(xmlNode *node, BOOL jsonMode);

- (BMXMLElement *)initWithXMLNode:(xmlNode *)node
{
    self = [super init];
	
	if (node->type != XML_ELEMENT_NODE) {
        return nil;
    }
    
    // Everything about an element is computed on demand, including its name,
    // children, and attributes. That saves precious memory. By storing references
    // to the original libxml document and node, we can determine everything else
    // about the node.
    
    self.libXMLNode = node;
    self.libXMLDocument = node->doc;
    
    return self;
}

- (BMXMLElement *)initWithName:(NSString *)name {
	NSAssert(name != nil, @"-[XMLElement elementWithName:] argument is nil.");
	if (name == nil) {
		return nil;
	}
	xmlNode *newElement = xmlNewNode(NULL, [name xmlChar]);
	return [self initWithXMLNode:newElement];
}

+ (BMXMLElement *)elementWithXMLNode:(xmlNode *)node
{
    BMXMLElement *element = [[[self class] alloc] initWithXMLNode:node];
    return element;
}

// Creates and returns an XMLElement with 'name'.
+ (BMXMLElement *)elementWithName:(NSString *)name
{
    BMXMLElement *element = [[[self class] alloc] initWithName:name];
    return element;
}

- (void)setArrayElement:(BOOL)arrayElement {
    if (arrayElement) {
        self.libXMLNode->extra |= XMLExtraInfoArrayElement;
    } else {
        self.libXMLNode->extra &= ~XMLExtraInfoArrayElement;
    }
}

- (BOOL)isArrayElement {
    return (self.libXMLNode->extra & XMLExtraInfoArrayElement) == XMLExtraInfoArrayElement;
}

- (void)setEmptyElement:(BOOL)emptyElement {
    if (emptyElement) {
        self.libXMLNode->extra |= XMLExtraInfoEmptyElement;
    } else {
        self.libXMLNode->extra &= ~XMLExtraInfoEmptyElement;
    }
}

- (BOOL)isEmptyElement {
    return (self.libXMLNode->extra & XMLExtraInfoEmptyElement) == XMLExtraInfoEmptyElement;
}

- (NSString *)description
{
    return [self XMLString];
}

- (void)dealloc {
    if (_XPathContext) {
        xmlXPathFreeContext(_XPathContext);
        _XPathContext = nil;
    }
}

#pragma mark -
#pragma mark    Element Info
#pragma mark -

- (NSString *)XMLString
{
    NSMutableString *descriptionString = [NSMutableString string];
    if (self.namespacePrefix) {
        [descriptionString appendFormat:@"<%@", [self qualifiedName]];
    } else {
        [descriptionString appendFormat:@"<%@", self.name];
    }
    if (self.attributes && [[self.attributes allKeys] count]) {
        [descriptionString appendFormat:@"%@", [self attributesString]];
    }
    
    [descriptionString appendString:@">"];
    
    for (BMXMLElement *child in self.children) {
        NSString *s = [child XMLString];
        if (s) {
            [descriptionString appendString:s];
        }
    }
    
    if (self.namespacePrefix) {
        [descriptionString appendFormat:@"</%@>", [self qualifiedName]];
    } else {
        [descriptionString appendFormat:@"</%@>", self.name];
    }
    
    return descriptionString;
}

- (NSString *)JSONStringWithAttributePrefix:(NSString *)attributePrefix textContentIdentifier:(NSString *)textContentIdentifier {
    
    NSMutableString *buffer = [NSMutableString string];
    
    [buffer appendString:@"{\n"];
    
    [self appendJSONString:buffer withAttributePrefix:attributePrefix textContentIdentifier:textContentIdentifier elementType:JSONElementTypeSingle];
    
    [buffer appendString:@"\n}"];
    
    return buffer;
    
}

- (NSUInteger)childCount
{
    return [self.children count];
}

- (NSString *)qualifiedName
{
    return self.namespacePrefix ? [NSString stringWithFormat:@"%@:%@", self.namespacePrefix, self.name] : self.name;
}

- (NSString *)name
{
    return [BMXMLUtilities stringWithXMLChar:self.libXMLNode->name];
}

- (NSString *)namespacePrefix
{
    if (self.libXMLNode->ns && self.libXMLNode->ns->prefix) {
        return [BMXMLUtilities stringWithXMLChar:self.libXMLNode->ns->prefix];
    }
    return nil;
}

- (XMLNodeKind)kind
{
    return XMLNodeElementKind;
}

#pragma mark -
#pragma mark    Subtree Access
#pragma mark -

- (NSArray *)children
{
    return childElementsOf(self.libXMLNode, self);
}

- (NSArray *)descendants
{
    NSMutableArray *descendants = [NSMutableArray array];
    NSArray *children = [self children];
    
    for (BMXMLNode *nextChild in children) {
        
        [descendants addObject:nextChild];
        if (nextChild.isElementNode) {
            [descendants addObjectsFromArray:[(BMXMLElement *)nextChild descendants]];
        }
    }
    
    return descendants;
}

#pragma mark -
#pragma mark    Navigation and Queries
#pragma mark -

- (BMXMLNode *)nextNode
{
    // Given this XML: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><document><title>A Title.</title><chapter></section><section><para/></section></chapter></document>";
    // If the title element is the context node, nextNode should return its child, which is the text node 'A Title.'
    BMXMLNode *firstChild = [self firstChild];
    if (firstChild) {
        return firstChild;
    }
    return [self nextSibling];
}

- (BMXMLNode *)firstChild
{
    if (self.children && [self.children count]) {
        return [self.children objectAtIndex:0];
    }
    return nil;
}

- (BMXMLNode *)lastChild
{
    return [BMXMLNode nodeWithXMLNode:xmlGetLastChild(self.libXMLNode)];
}

- (BMXMLNode *)childAtIndex:(NSUInteger)index
{
    return [self.children objectAtIndex:index];
}

- (BMXMLElement *)firstChildNamed:(NSString *)matchName
{
    NSArray *allChildrenNamed = [self childrenNamed:matchName];
    if (allChildrenNamed && [allChildrenNamed count]) {
        return [allChildrenNamed objectAtIndex:0];
    }
    return nil;
}

- (BMXMLElement *)lastChildNamed:(NSString *)matchName {
	NSArray *allChildrenNamed = [self childrenNamed:matchName];
    if (allChildrenNamed && [allChildrenNamed count]) {
        return [allChildrenNamed lastObject];
    }
    return nil;
}

- (BMXMLElement *)firstDescendantNamed:(NSString *)matchName
{
    NSArray *allDescendantsNamed = [self descendantsNamed:matchName];
    if (allDescendantsNamed && [allDescendantsNamed count]) {
        return [allDescendantsNamed objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)childrenNamed:(NSString *)matchName
{
    NSString *XPathForQuery = [NSString stringWithFormat:@"%@", matchName];
    return [self elementsForXPath:XPathForQuery prepareNamespaces:[NSArray arrayWithObject:matchName] error:nil];
}

- (NSArray *)descendantsNamed:(NSString *)matchName
{
    NSString *XPathForQuery = [NSString stringWithFormat:@"//%@", matchName];
    return [self elementsForXPath:XPathForQuery prepareNamespaces:[NSArray arrayWithObject:matchName] error:nil];
}

- (NSArray *)elementsWithAttributeNamed:(NSString *)attributeName
{
    NSString *XPathForQuery = [NSString stringWithFormat:@"//*[@%@]", attributeName];
    return [self elementsForXPath:XPathForQuery prepareNamespaces:nil error:nil];
}

- (NSArray *)elementsWithAttributeNamed:(NSString *)attributeName attributeValue:(NSString *)attributeValue
{
    NSString *XPathForQuery = [NSString stringWithFormat:@"//*[@%@='%@']", attributeName, attributeValue];
    return [self elementsForXPath:XPathForQuery prepareNamespaces:nil error:nil];
}

- (NSArray *)elementsForXPath:(NSString *)XPath error:(NSError **)outError
{
	return [self elementsForXPath:XPath prepareNamespaces:nil error:nil];
}

- (NSArray *)elementsForXPath:(NSString *)XPath namespaces:(NSDictionary *)namespaces error:(NSError **)outError
{
    if (!_XPathContext) {
        _XPathContext = xmlXPathNewContext(self.libXMLDocument);
    }
    
	for (NSString *prefix in namespaces) {
        
        const xmlChar *namespacePrefix = (xmlChar *)[prefix cStringUsingEncoding:NSUTF8StringEncoding];
        const xmlChar *namespace = (xmlChar *)[[namespaces objectForKey:prefix] cStringUsingEncoding:NSUTF8StringEncoding];
        
        // When performing a query for a qualified element name such as geo:lat, libxml
        // requires you to register the namespace. We do so here and pass an empty string
        // as the URL that defines the namespace prefix because there's no way to know
        // what it is given the current API.
        if(xmlXPathRegisterNs(_XPathContext, namespacePrefix, namespace) != 0) {
            
            if (_XPathContext) {
                xmlXPathFreeContext(_XPathContext);
                _XPathContext = nil;
            }
        }
	}
	
    return [self _nodesForXPath:XPath error:outError];
}

- (NSArray *)elementsForXPath:(NSString *)XPath prepareNamespaces:(NSArray *)elementNames error:(NSError **)outError
{
    NSMutableDictionary *namespaces = [NSMutableDictionary new];
	for (NSString *elementName in elementNames) {
        
		// Pull out the namespace prefix from elementName and set the xpath context.
		NSString *prefix = nil;
		NSRange colonRange = [elementName rangeOfString:@":"];
		if (colonRange.location != NSNotFound) {
			prefix = [elementName substringToIndex:colonRange.location];
            [namespaces setObject:@"" forKey:prefix];
        }
	}

    return [self elementsForXPath:XPath namespaces:namespaces error:outError];
}

static NSArray * childElementsOf(xmlNodePtr a_node, BMXMLElement *contextElement)
{
    NSMutableArray *childElements = [NSMutableArray array];
    
    xmlNodePtr childrenHeadPtr = a_node->children;
    
    if (!childrenHeadPtr) {
        return childElements;
    }
    
    xmlNode *currentNode = childrenHeadPtr;
    
    while (currentNode) {
        
        if (currentNode->type == XML_ELEMENT_NODE) {
            BMXMLElement *childElement = [BMXMLElement elementWithXMLNode:currentNode];
            if (childElement) {
                [childElements addObject:childElement];
            }
        } else if (currentNode->type == XML_TEXT_NODE) {
            BMXMLNode *childNode = [BMXMLNode nodeWithXMLNode:currentNode];
            [childElements addObject:childNode];
        }
        
        currentNode = currentNode->next;
    }
    
    return childElements;
}

static NSDictionary *getElementAttributes(xmlNode *node, BOOL jsonMode)
{
    if (node->type != XML_ELEMENT_NODE) {
        return nil;
    }
    
    NSMutableDictionary *elementAttributes = [NSMutableDictionary dictionary];
    
    xmlAttr *attributes = node->properties;
    
    while (attributes) {
        
        const xmlChar *attName = attributes->name;
        xmlChar *attValue = xmlGetProp(node, attName);
        
        NSString *attributeName = [BMXMLUtilities stringWithXMLChar:attName];
        NSString *attributeValue;
        if (jsonMode) {
            attributeValue = [BMXMLUtilities jsonStringWithXMLChar:attValue];
        } else {
            attributeValue = [BMXMLUtilities stringWithXMLChar:attValue];
        }
        
        xmlFree(attValue);
        if (attributeName && attributeValue) {
            [elementAttributes setValue:attributeValue forKey:attributeName];
        }
        
        attributes = attributes->next;
    }
    
	return elementAttributes;
}

#pragma mark -
#pragma mark    XPath Support
#pragma mark -

- (NSArray *)_nodesForXPath:(NSString *)XPath error:(NSError **)outError
{
	xmlDocPtr document = self.libXMLDocument;
	xmlNode *contextNode = self.libXMLNode;
	
	const xmlChar *XPathQuery = (const xmlChar *)[XPath UTF8String];
	
	if (!XPathQuery) {
		if (outError) {
            *outError = [NSError errorWithDomain:XMLParsingErrorDomainString code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"-[XMLElement _nodesForXPath:] XPath argument is nil.", NSLocalizedFailureReasonErrorKey, nil]];
        }
		return nil;
	}
	
	// To execute an XPath query, first create a new XPath context.
	// If the query includes namespace-prefixed elements,
	// elementsForXPath:prepareNamespaces: might have already set the context.
	
	if (!_XPathContext) {
		_XPathContext = xmlXPathNewContext(document);
	}
	
	if (!_XPathContext) {
		if (outError) {
            *outError = [NSError errorWithDomain:XMLParsingErrorDomainString code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"-[XMLElement _nodesForXPath:] couldn't create an xmlXPathContext.", NSLocalizedFailureReasonErrorKey, nil]];
        }
        
		return nil;
	}
	
	_XPathContext->node = contextNode;
	
	// Holds the results of the XPath query.
	xmlXPathObjectPtr queryResults = xmlXPathEvalExpression(XPathQuery, _XPathContext);
	if (!queryResults) {
		if (outError) {
            *outError = [NSError errorWithDomain:XMLParsingErrorDomainString code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"xmlXPathEvalExpression() failed.", NSLocalizedFailureReasonErrorKey, nil]];
        }
		return nil;
	}
    
	// libxml has returned results from the query.
	// Iterate through them and create XMLElement objects for each.
	NSMutableArray *resultElements = [NSMutableArray array];
    
    NSUInteger nodeCounter, size = (queryResults->nodesetval) ? queryResults->nodesetval->nodeNr : 0;
    
    for(nodeCounter = 0; nodeCounter < size; ++nodeCounter) {
        xmlNode *nextNode = queryResults->nodesetval->nodeTab[nodeCounter];
        if (!nextNode || nextNode->type != XML_ELEMENT_NODE) {
            continue;
        }
        BMXMLElement *nextResult = [BMXMLElement elementWithXMLNode:nextNode];
        [resultElements addObject:nextResult];
    }
    
    xmlXPathFreeObject(queryResults);
    if (_XPathContext) {
        xmlXPathFreeContext(_XPathContext);
        _XPathContext = nil;
    }
	return resultElements;
}

#pragma mark -
#pragma mark    Attributes
#pragma mark -

// Return an attribute in the element whose name matches the argument.
- (NSString *)attributeNamed:(NSString *)name
{
    NSAssert(name != nil, @"-[XMLElement attributeNamed:] 'name' argument is nil.");
    
    return [self.attributes objectForKey:name];
}

// Private method that returns the libxml attribute for the given name.
- (xmlAttr *)_getRawAttributeForName:(NSString *)name
{
    xmlAttr *attribute = xmlHasProp(self.libXMLNode, [name xmlChar]);
    
    return attribute;
}

// Adds to the element an attribute named 'attributeName' with the value 'attributeValue'.
- (BMXMLNode *)addAttribute:(NSString *)attributeName value:(NSString *)attributeValue
{
    NSAssert(attributeName != nil, @"-[XMLElement addAttribute:value:] attribute name parameter is nil.");
    NSAssert1([attributeName isKindOfClass:[NSString class]], @"-[XMLElement addAttribute:value:] attribute name is not an NSString.", attributeName);
    
    NSAssert(attributeValue != nil, @"-[XMLElement addAttribute:value:] attribute value parameter is nil.");
    NSAssert1([attributeValue isKindOfClass:[NSString class]], @"-[XMLElement addAttribute:value:] attribute value is not an NSString.", attributeValue);
    
    xmlAttr *newAttribute = xmlNewProp(self.libXMLNode, [attributeName xmlChar], [attributeValue xmlChar]);
    
    if (newAttribute) {
        return [BMXMLNode nodeWithXMLNode:(xmlNode *)newAttribute];
    }
    
    return nil;
}

// Deletes from the element the attribute named 'attributeName'.
- (void)deleteAttributeNamed:(NSString *)attributeName
{
    xmlAttr *attribute = [self _getRawAttributeForName:attributeName];
    if (attribute) {
        xmlRemoveProp(attribute);
    }
}

- (NSDictionary *)jsonAttributes
{
    return getElementAttributes(self.libXMLNode, YES);
}

- (NSDictionary *)attributes
{
    return getElementAttributes(self.libXMLNode, NO);
}

// Returns a string representation of the receiver's attributes and their values.
- (NSString *)attributesString
{
    NSMutableString *attributesString = [NSMutableString string];
    for (NSString *attribute in self.attributes) {
        [attributesString appendFormat:@" %@=\"%@\"", attribute, [self.attributes valueForKey:attribute]];
    }
    return attributesString;
}

#pragma mark -
#pragma mark    Mutation
#pragma mark -

// Look at the receiver's children and merge consecutive text nodes into a single node.
- (void)consolidateConsecutiveTextNodes
{
    NSArray *children = self.children;
    
    for (BMXMLNode *child in children) {
        
        BMXMLNode *nextSibling = child.nextSibling;
        if (!nextSibling) {
            break;
        }
        if (child.isTextNode && nextSibling.isTextNode) {
            
            xmlNode *mergedTextNode = xmlTextMerge(child.libXMLNode, nextSibling.libXMLNode);
            
            /*XMLNode *merged = */
			[BMXMLNode nodeWithXMLNode:mergedTextNode];
            [self consolidateConsecutiveTextNodes];
            return;
        }
    }
}

// Add a child to the receiver. It will be added as the last child.
- (BMXMLNode *)addChild:(BMXMLNode *)node
{
    //   NSAssert1(node.parent == nil, @"Cannot add a child that already has a parent.", node);
    
    xmlNode *newNode = xmlAddChild(self.libXMLNode, node.libXMLNode);
    return [BMXMLNode nodeWithXMLNode:newNode];
}

// Insert a child node at the specified index in the receiver.
- (void)insertChild:(BMXMLNode *)node atIndex:(NSUInteger)index
{
    NSAssert1(index <= [self childCount], @"-[XMLElement insertChild:atIndex:] index beyond bounds.", [NSNumber numberWithUnsignedInteger:index]);
    
    BMXMLNode *nodeAtIndex = [self childAtIndex:index];
    [nodeAtIndex addNodeAsPreviousSibling:node];
}

// Private method that adds the libxml node to the receiver's children list.
- (BMXMLNode *)_addRawChild:(xmlNode *)node
{
    NSAssert1(node->parent == NULL, @"Cannot add a child that already has a parent.", node);
    
    xmlNode *newNode = xmlAddChild(self.libXMLNode, node);
    return [BMXMLNode nodeWithXMLNode:newNode];
}

// Add the string as a text node of the receiver.
- (BMXMLNode *)addTextChild:(NSString *)text
{
    xmlNode *newTextNode = xmlNewText([text xmlChar]);
    
    if (newTextNode) {
        return [self _addRawChild:newTextNode];
    }
    
    return nil;
}

// Add to the receiver an element named 'childName'.
- (BMXMLElement *)addChildNamed:(NSString *)childName
{
    return [self addChildNamed:childName withTextContent:nil];
}

- (BMXMLElement *)addChildNamed:(NSString *)childName withTextContent:(NSString *)nodeContent {
	return [self addChildNamed:childName withTextContent:nodeContent cdata:NO];
}

// Add to the receiver an element named 'childName' and set the content of the new element to 'nodeContent'.
- (BMXMLElement *)addChildNamed:(NSString *)childName withTextContent:(NSString *)nodeContent cdata:(BOOL)cdata
{
    NSAssert1(childName != nil && [childName length] != 0, @"childName is nil or empty", childName);
	
	if (cdata) {
		nodeContent = [NSString stringWithFormat:@"<![CDATA[%@]]>", nodeContent];
	}
    
    xmlNode *newNode = xmlNewTextChild(self.libXMLNode, NULL, [childName xmlChar], [nodeContent xmlChar]);
    
    return [BMXMLElement elementWithXMLNode:newNode];
}

- (NSString *)attributeNamed:(NSString *)attributeName ofFirstChildNodeNamed:(NSString *)childName {
	NSString *value = nil;
	BMXMLElement *child = [self firstChildNamed:childName];
	if (child) {
		value = [child attributeNamed:attributeName];
	}
	return value;
}

- (NSString *)nodeTextOfFirstChildNodeNamed:(NSString *)childName {
	NSString *value = nil;
	BMXMLElement *child = [self firstChildNamed:childName];
	if (child) {
		BMXMLNode *node = [child firstChild];
		if ([node isTextNode]) {
			value = [node stringValue];
		}
	}
	return value;
}

- (void)appendJSONString:(NSMutableString *)descriptionString withAttributePrefix:(NSString *)attributePrefix textContentIdentifier:(NSString *)textContentIdentifier elementType:(JSONElementType)elementType {
    
    NSDictionary *theAttributes = self.jsonAttributes;
    if (self.childCount == 1 && theAttributes.count == 0) {
        BMXMLNode *child = [self firstChild];
        if ([child isTextNode]) {
            
            if ((elementType & JSONElementTypeArray)) {
                if ((elementType & JSONElementTypeFirst)) {
                    [descriptionString appendFormat:@"\"%@\":[", self.name];
                }
            } else {
                [descriptionString appendFormat:@"\"%@\":", self.name];
            }
            
            if ([child isJsonQuotedValueType]) {
                [descriptionString appendFormat:@"\"%@\"", [child jsonStringValue]];
            } else {
                [descriptionString appendString:[child jsonStringValue]];
            }
            
            if ((elementType & JSONElementTypeArray)) {
                if ((elementType & JSONElementTypeLast)) {
                    [descriptionString appendString:@"]"];
                }
            }
            return;
        }
    }
    
    //Empty is special for empty arrays
    BOOL isEmpty = (elementType & JSONElementTypeEmpty);
    
    if ((elementType & JSONElementTypeArray)) {
        if (isEmpty) {
            [descriptionString appendFormat:@"\"%@\":[]", self.name];
        } else if ((elementType & JSONElementTypeFirst)) {
            [descriptionString appendFormat:@"\"%@\":[{", self.name];
        } else {
            [descriptionString appendString:@"{"];
        }
    } else {
        if (isEmpty) {
            [descriptionString appendFormat:@"\"%@\":{}", self.name];
        } else {
            [descriptionString appendFormat:@"\"%@\":{", self.name];
        }
    }
    
    if (!isEmpty) {
        BOOL first = YES;
        
        for (NSString *attributeName in theAttributes) {
            if (first) {
                first = NO;
            } else {
                [descriptionString appendString:@","];
            }
            NSString *attributeValue = [theAttributes objectForKey:attributeName];
            [descriptionString appendFormat:@"\"%@%@\":\"%@\"", attributePrefix, attributeName, attributeValue];
        }
        
        BMXMLNode *textNode = nil;
        int count = 0;
        
        //Order the children by name
        BMOrderedDictionary *childrenDictionary = [BMOrderedDictionary new];
        for (BMXMLNode *child in self.children) {
            if ([child isTextNode]) {
                textNode = child;
            } else {
                BMXMLElement *childElement = (BMXMLElement *)child;
                
                if (childElement.name) {
                    NSMutableArray *groupedElements = [childrenDictionary objectForKey:childElement.name];
                    if (groupedElements == nil) {
                        groupedElements = [NSMutableArray array];
                        [childrenDictionary setObject:groupedElements forKey:childElement.name];
                    }
                    [groupedElements addObject:childElement];
                }
            }
        }
        
        for (NSString *elementName in childrenDictionary) {
            NSArray *groupedChildren = [childrenDictionary objectForKey:elementName];
            for (NSUInteger i = 0; i < groupedChildren.count; ++i) {
                BMXMLElement *element = [groupedChildren objectAtIndex:i];
                if (first) {
                    first = NO;
                } else {
                    [descriptionString appendString:@","];
                }
                
                JSONElementType elementType = JSONElementTypeSingle;
                
                if (element.isArrayElement) {
                    elementType |= JSONElementTypeArray;
                }
                
                if (element.isEmptyElement) {
                    elementType |= JSONElementTypeEmpty;
                }
                
                if (i == 0) {
                    elementType |= JSONElementTypeFirst;
                }
                
                if (i == groupedChildren.count - 1) {
                    elementType |= JSONElementTypeLast;
                }
                
                [element appendJSONString:descriptionString withAttributePrefix:attributePrefix textContentIdentifier:textContentIdentifier elementType:elementType];
            }
            count++;
        }
        
        
        if (textNode) {
            NSString *textString = [textNode jsonStringValue];
            if (count > 1) {
                textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            if (textString && (count == 1 || ![textString isEqual:@""])) {
                if (first) {
                    first = NO;
                } else {
                    [descriptionString appendString:@","];
                }
                [descriptionString appendFormat:@"\"%@\":\"%@\"", textContentIdentifier, textString];
            }
        }
        
        if ((elementType & JSONElementTypeArray)) {
            if ((elementType & JSONElementTypeLast)) {
                [descriptionString appendString:@"}]"];
            } else {
                [descriptionString appendString:@"}"];
            }
        } else {
            [descriptionString appendString:@"}"];
        }
    }
}

@end
