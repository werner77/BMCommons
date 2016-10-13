//
//  BMXMLParser.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMParser.h>

@class _BMXMLParserInternal;
@class BMXMLParser;

/**
 XMLParser delegate protocol. 
 
 See NSXMLParserDelegate documentation for more details as these methods have the exact same contract.
 */
@protocol BMXMLParserDelegate <BMParserDelegate>

@optional

// DTD handling methods for various declarations.
- (void)parser:(BMXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;

- (void)parser:(BMXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;

- (void)parser:(BMXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;

- (void)parser:(BMXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;

- (void)parser:(BMXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;

- (void)parser:(BMXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;

- (void)parser:(BMXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;
// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"

- (void)parser:(BMXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;
// sent when the namespace prefix in question goes out of scope.

- (void)parser:(BMXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;
// The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"

- (void)parser:(BMXMLParser *)parser foundCDATA:(NSData *)CDATABlock;
// this reports a CDATA block to the delegate as an NSData.

- (NSData *)parser:(BMXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;
// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.

@end

/**
BMParser implementation for parsing XML documents.
*/
@interface BMXMLParser : BMParser
{
    @private
	void * _parser;
	_BMXMLParserInternal * _internal;
}

/**
 Whether to process namespaces. Defaults to true: strips namespaces from elements.
 */
@property (nonatomic, assign) BOOL shouldProcessNamespaces;

/**
 If true namespace prefixes are reported to the delegate
 */
@property (nonatomic, assign) BOOL shouldReportNamespacePrefixes;

/**
 Whether to resolve external entities.
 */
@property (nonatomic, assign) BOOL shouldResolveExternalEntities;

/**
 Whether to parse in HTML mode or XML mode.
 */
@property (nonatomic, assign, getter=isInHTMLMode) BOOL HTMLMode;

/**
 Don't throw parser errors, just continue parsing (work around for some invalid XMLs).
 */
@property (nonatomic, assign) BOOL ignoreParseErrors;

/**
 The delegate.
 */
@property (nonatomic, weak) id<BMXMLParserDelegate> delegate;

@end

@interface BMXMLParser (BMXMLParserLocatorAdditions)
@property (nonatomic, readonly, retain) NSString * publicID;
@property (nonatomic, readonly, retain) NSString * systemID;
@property (nonatomic, readonly) NSInteger lineNumber;
@property (nonatomic, readonly) NSInteger columnNumber;
@end
