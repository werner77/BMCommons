//
//  BMXMLParser.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMXMLParser.h>

#import <libxml/parser.h> // add -I/usr/include/libxml2 -lxml2 if you have No such file or directory errors
#import <libxml/HTMLparser.h>
#import <libxml/parserInternals.h>
#import <libxml/SAX2.h>
#import <libxml/xmlerror.h>
#import <libxml/encoding.h>
#import <libxml/entities.h>

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#else
//#import <CoreServices/../Frameworks/CFNetwork.framework/Headers/CFNetwork.h>
#endif

#import <BMCommons/BMRestKit.h>

@interface _BMXMLParserInternal : NSObject
{
@public
    // parser structures -- these are actually the same for both XML & HTML
	xmlSAXHandlerPtr saxHandler;
	xmlParserCtxtPtr parserContext;
	
    // internal stuff
    NSUInteger parserFlags;
	NSMutableArray * namespaces;
}
@property (nonatomic, readonly) xmlSAXHandlerPtr xmlSaxHandler;
@property (nonatomic, readonly) xmlParserCtxtPtr xmlParserContext;
@property (nonatomic, readonly) htmlSAXHandlerPtr htmlSaxHandler;
@property (nonatomic, readonly) htmlParserCtxtPtr htmlParserContext;
@end

@implementation _BMXMLParserInternal

- (xmlSAXHandlerPtr) xmlSaxHandler
{
    return ( saxHandler );
}

- (xmlParserCtxtPtr) xmlParserContext
{
    return ( parserContext );
}

- (htmlSAXHandlerPtr) htmlSaxHandler
{
    return ( (htmlSAXHandlerPtr) saxHandler );
}

- (htmlParserCtxtPtr) htmlParserContext
{
    return ( (htmlParserCtxtPtr) parserContext );
}

@end

enum
{
	BMXMLParserShouldProcessNamespaces = 1<<0,
	BMXMLParserShouldReportPrefixes = 1<<1,
	BMXMLParserShouldResolveExternals = 1<<2,
    BMXMLParserShouldIgnoreParseErrors = 1<<3,
    
    // most significant bit indicates HTML mode
    BMXMLParserHTMLMode = 1<<31
	
};

@interface BMXMLParser (Internal)
- (void) _setParserErrorWithCode: (int) err;
- (void) _pushXMLData: (const void *) bytes length: (NSUInteger) length;
- (xmlParserCtxtPtr) _xmlParserContext;
- (htmlParserCtxtPtr) _htmlParserContext;
- (void) _pushNamespaces: (NSDictionary *) nsDict;
- (void) _popNamespaces;
- (void) _initializeSAX2Callbacks;
- (void) _initializeParserWithBytes: (const void *) buf length: (NSUInteger) length;
- (_BMXMLParserInternal *) _info;
@end

#pragma mark -

static inline NSString * NSStringFromXmlChar( const xmlChar * ch )
{
	if ( ch == NULL )
		return ( nil );
	
	return ( [[NSString allocWithZone: nil] initWithBytes: ch
												   length: strlen((const char *)ch)
												 encoding: NSUTF8StringEncoding] );
}

static inline NSString * AttributeTypeString( int type )
{
#define TypeCracker(t) case XML_ATTRIBUTE_ ## t: return @#t
	switch ( type )
	{
			TypeCracker(CDATA);
			TypeCracker(ID);
			TypeCracker(IDREF);
			TypeCracker(IDREFS);
			TypeCracker(ENTITY);
			TypeCracker(ENTITIES);
			TypeCracker(NMTOKEN);
			TypeCracker(NMTOKENS);
			TypeCracker(ENUMERATION);
			TypeCracker(NOTATION);
			
		default:
			break;
	}
	
	return ( @"" );
}

static int __isStandalone( void * ctx )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	return ( p->myDoc->standalone );
}

static int __hasInternalSubset2( void * ctx )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	return ( p->myDoc->intSubset == NULL ? 0 : 1 );
}

static int __hasExternalSubset2( void * ctx )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	return ( p->myDoc->extSubset == NULL ? 0 : 1 );
}

static void __internalSubset2( void * ctx, const xmlChar * name, const xmlChar * ElementID,
							  const xmlChar * SystemID )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	xmlSAX2InternalSubset( p, name, ElementID, SystemID );
}

static void __externalSubset2( void * ctx, const xmlChar * name, const xmlChar * ExternalID,
							  const xmlChar * SystemID )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	xmlSAX2ExternalSubset( p, name, ExternalID, SystemID );
}

static void __structuredErrorFunc( void * ctx, xmlErrorPtr errorData );

static xmlParserInputPtr __resolveEntity( void * ctx, const xmlChar * publicId, const xmlChar * systemId )
{
    xmlSetStructuredErrorFunc(ctx, __structuredErrorFunc);
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
    xmlParserInputPtr result = xmlSAX2ResolveEntity(p, publicId, systemId);
    xmlSetStructuredErrorFunc(0, 0);
	return result;
}

static void __characters( void * ctx, const xmlChar * ch, int len )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	
	if ( (long)(p->_private) == 1 )
	{
		p->_private = 0;
		return;
	}
	
	id<BMXMLParserDelegate> delegate = parser.delegate;
	if ( [delegate respondsToSelector: @selector(parser:foundCharacters:)] == NO )
		return;
	
	NSString * str = [[NSString allocWithZone: nil] initWithBytes: ch
														   length: len
														 encoding: NSUTF8StringEncoding];
	[delegate parser: parser foundCharacters: str];
}

static xmlEntityPtr __getParameterEntity( void * ctx, const xmlChar * name )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	return ( xmlSAX2GetParameterEntity(p, name) );
}

static void __entityDecl( void * ctx, const xmlChar * name, int type, const xmlChar * publicId,
						 const xmlChar * systemId, xmlChar * content )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	xmlSAX2EntityDecl( p, name, type, publicId, systemId, content );
	
	NSString * contentStr = NSStringFromXmlChar( content );
	NSString * nameStr = NSStringFromXmlChar( name );
	
	if ( [contentStr length] != 0 )
	{
		if ( [delegate respondsToSelector: @selector(parser:foundInternalEntityDeclarationWithName:value:)] )
			[delegate parser: parser foundInternalEntityDeclarationWithName: nameStr value: contentStr];
	}
	else if ( [parser shouldResolveExternalEntities] )
	{
		if ( [delegate respondsToSelector: @selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:)] )
		{
			NSString * publicIDStr = NSStringFromXmlChar(publicId);
			NSString * systemIDStr = NSStringFromXmlChar(systemId);
			
			[delegate parser: parser foundExternalEntityDeclarationWithName: nameStr
					publicID: publicIDStr systemID: systemIDStr];
			
		}
	}
	
}

static void __attributeDecl( void * ctx, const xmlChar * elem, const xmlChar * fullname, int type, int def,
							const xmlChar * defaultValue, xmlEnumerationPtr tree )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:)] == NO )
		return;
	
	NSString * elemStr = NSStringFromXmlChar(elem);
	NSString * fullnameStr = NSStringFromXmlChar(fullname);
	NSString * defaultStr = NSStringFromXmlChar(defaultValue);
	
	[delegate parser: parser foundAttributeDeclarationWithName: fullnameStr forElement: elemStr
				type: AttributeTypeString(type) defaultValue: defaultStr];
	
}

static void __elementDecl( void * ctx, const xmlChar * name, int type, xmlElementContentPtr content )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundElementDeclarationWithName:model:)] == NO )
		return;
	
	NSString * nameStr = NSStringFromXmlChar(name);
	[delegate parser: parser foundElementDeclarationWithName: nameStr model: @""];
}

static void __notationDecl( void * ctx, const xmlChar * name, const xmlChar * publicId, const xmlChar * systemId )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundNotationDeclarationWithName:publicID:systemID:)] == NO )
		return;
	
	NSString * nameStr = NSStringFromXmlChar(name);
	NSString * publicIDStr = NSStringFromXmlChar(publicId);
	NSString * systemIDStr = NSStringFromXmlChar(systemId);
	
	[delegate parser: parser foundNotationDeclarationWithName: nameStr
			publicID: publicIDStr systemID: systemIDStr];
	
}

static void __unparsedEntityDecl( void * ctx, const xmlChar * name, const xmlChar * publicId,
								 const xmlChar * systemId, const xmlChar * notationName )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	xmlSAX2UnparsedEntityDecl( p, name, publicId, systemId, notationName );
	
	if ( [delegate respondsToSelector: @selector(parser:foundUnparsedEntityDeclarationWithName:publicID:systemID:notationName:)] == NO )
		return;
	
	NSString * nameStr = NSStringFromXmlChar(name);
	NSString * publicIDStr = NSStringFromXmlChar(publicId);
	NSString * systemIDStr = NSStringFromXmlChar(systemId);
	NSString * notationNameStr = NSStringFromXmlChar(notationName);
	
	[delegate parser: parser foundUnparsedEntityDeclarationWithName: nameStr
			publicID: publicIDStr systemID: systemIDStr notationName: notationNameStr];
	
}

static void __startDocument( void * ctx )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	const char * encoding = (const char *) p->encoding;
	if ( encoding == NULL )
		encoding = (const char *) p->input->encoding;
	
	if ( encoding != NULL )
		xmlSwitchEncoding( p, xmlParseCharEncoding(encoding) );
	
	xmlSAX2StartDocument( p );
	
	if ( [delegate respondsToSelector: @selector(parser:didStartDocumentOfType:)] == NO )
		return;
	
	[delegate parser:parser didStartDocumentOfType:BMParserDocumentTypeXML];
}

static void __endDocument( void * ctx )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parserDidEndDocument:)] == NO )
		return;
	
	[delegate parserDidEndDocument: parser];
}

static NSString* __createCompleteStr(NSString* prefixStr, NSString* localnameStr)
{
	if ( [prefixStr length] != 0 ) {
        NSMutableString* result = [[NSMutableString alloc] initWithCapacity:[prefixStr length]+[localnameStr length]+1];
        [result appendString:prefixStr];
        [result appendString:@":"];
        [result appendString:localnameStr];
		return result;
	} else
        return localnameStr;
}

static NSString* __elementName(BOOL processNS, NSString* localnameStr, NSString* completeStr)
{
    NSString* elementName =processNS ? localnameStr : completeStr;
    if (!elementName) elementName = localnameStr;
    return elementName;
}

static NSString* __qualifiedName(BOOL processNS, NSString* completeStr)
{
    NSString* qualifiedName = completeStr;
    if (!processNS) qualifiedName = 0;
    return qualifiedName;
}

static NSString* __createUriStr(BOOL processNS, const xmlChar* URI)
{
	NSString * uriStr = nil;
	if ( processNS ) {
		uriStr = NSStringFromXmlChar(URI);
        if (uriStr == 0)
            uriStr = @"";
    }
    return uriStr;
}

static void __endElementNS( void * ctx, const xmlChar * localname, const xmlChar * prefix, const xmlChar * URI )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
    BOOL processNS = [parser shouldProcessNamespaces];
	
	NSString * prefixStr = NSStringFromXmlChar(prefix);
	NSString * localnameStr = NSStringFromXmlChar(localname);
	
	NSString * completeStr = __createCompleteStr(prefixStr,localnameStr);
	NSString* elementName = __elementName(processNS,localnameStr,completeStr);
    NSString* qualifiedName = __qualifiedName(processNS,completeStr);
    
    NSString * uriStr = __createUriStr(processNS,URI);
	
	if ( [delegate respondsToSelector: @selector(parser:didEndElement:namespaceURI:qualifiedName:)] )
	{
		if ( prefixStr != nil )
		{
			if ( (completeStr == nil) && (uriStr == nil) )
				uriStr = @"";
        }
		
        [delegate parser: parser didEndElement: elementName
            namespaceURI: uriStr qualifiedName: qualifiedName];
	}
	
	[parser _popNamespaces];
	
}

static void __processingInstruction( void * ctx, const xmlChar * target, const xmlChar * data )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundProcessingInstructionWithTarget:data:)] == NO )
		return;
	
	NSString * targetStr = NSStringFromXmlChar(target);
	NSString * dataStr = NSStringFromXmlChar(data);
	
	[delegate parser: parser foundProcessingInstructionWithTarget: targetStr data: dataStr];
	
}

static void __cdataBlock( void * ctx, const xmlChar * value, int len )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundCDATA:)] == NO )
		return;
	
	NSData * data = [[NSData allocWithZone: nil] initWithBytes: value length: len];
	[delegate parser: parser foundCDATA: data];
}

static void __comment( void * ctx, const xmlChar * value )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	if ( [delegate respondsToSelector: @selector(parser:foundComment:)] == NO )
		return;
	
	NSString * commentStr = NSStringFromXmlChar(value);
	[delegate parser: parser foundComment: commentStr];
}

static void __errorCallback( void * ctx, const char * msg, ... )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	id<BMXMLParserDelegate> delegate = parser.delegate;
	int code = p->errNo;
	
	if ([parser ignoreParseErrors]) {
	    LogWarn(@"Ignoring parse error with code: %d", code);    
	} else {
	    [parser _setParserErrorWithCode:code];
	    
	    if ( [delegate respondsToSelector: @selector(parser:parseErrorOccurred:)] == NO )
	        return;
	    
	    [delegate parser: parser parseErrorOccurred: [NSError errorWithDomain: NSXMLParserErrorDomain
	                                                                     code: code
	                                                                 userInfo: nil]];
	}	
}

static void __structuredErrorFunc( void * ctx, xmlErrorPtr errorData )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	int code = parser.parsingAborted ? 0x200 : errorData->code;
    
    if ([parser ignoreParseErrors]) {
        LogWarn(@"Ignoring parse error with code: %d", code);    
    } else {
        [parser _setParserErrorWithCode:code];
        
        if ( [delegate respondsToSelector: @selector(parser:parseErrorOccurred:)] == NO )
            return;
        
        [delegate parser: parser parseErrorOccurred: [NSError errorWithDomain: NSXMLParserErrorDomain
                                                                         code: code
                                                                     userInfo: nil]];
    }
}

static xmlEntityPtr __getEntity( void * ctx, const xmlChar * name )
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	xmlParserCtxtPtr p = [parser _xmlParserContext];
	id<BMXMLParserDelegate> delegate = parser.delegate;
	
	xmlEntityPtr entity = xmlGetPredefinedEntity( name );
	if ( entity != NULL )
		return ( entity );
	
	entity = xmlSAX2GetEntity( p, name );
	if ( entity != NULL )
	{
		if ( (p->instate & XML_PARSER_MISC)|XML_PARSER_PI|XML_PARSER_DTD )
			p->_private = (void *) 1;
		return ( entity );
	}
	
	if ( [delegate respondsToSelector: @selector(parser:resolveExternalEntityName:systemID:)] == NO )
		return ( NULL );
	
	NSString * nameStr = NSStringFromXmlChar(name);
	
	NSData * data = [delegate parser: parser resolveExternalEntityName: nameStr systemID: nil];
	if ( data == nil )
		return ( NULL );
	
	if ( p->myDoc == NULL )
		return ( NULL );
	
	// got a string for the (parsed/resolved) entity, so just hand that in as characters directly
	NSString * str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	const char * ch = [str UTF8String];
	__characters( ctx, (const xmlChar *)ch, BMShortenIntSafely(strlen(ch),nil) );
	
	return ( NULL );
}



static void __startElementNS( void * ctx, const xmlChar *localname, const xmlChar *prefix,
							 const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
							 int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
	BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = [parser delegate];
	
	BOOL processNS = [parser shouldProcessNamespaces];
	BOOL reportNS = [parser shouldReportNamespacePrefixes];
	
	NSString * prefixStr = NSStringFromXmlChar(prefix);
	NSString * localnameStr = NSStringFromXmlChar(localname);
	
	NSString* completeStr = __createCompleteStr(prefixStr,localnameStr);
	NSString* elementName = __elementName(processNS,localnameStr,completeStr);
	
    NSString* qualifiedName = __qualifiedName(processNS,completeStr);
    
    NSString * uriStr = __createUriStr(processNS,URI);
	
	NSMutableDictionary * attrDict = [[NSMutableDictionary alloc] initWithCapacity: nb_attributes + nb_namespaces];
	
	NSMutableDictionary * nsDict = nil;
	if ( reportNS )
		nsDict = [[NSMutableDictionary alloc] initWithCapacity: nb_namespaces];
	
	int i;
	for ( i = 0; i < (nb_namespaces * 2); i += 2 )
	{
		NSString * namespaceStr = nil;
		NSString * qualifiedStr = nil;
		
		if ( namespaces[i] == NULL )
		{
			qualifiedStr = @"xmlns";
            namespaceStr = @"";
		}
		else
		{
			namespaceStr = NSStringFromXmlChar(namespaces[i]);
			qualifiedStr = [[NSString alloc] initWithFormat: @"xmlns:%@", namespaceStr];
		}
		
		NSString * val = nil;
		if ( namespaces[i+1] != NULL )
			val = NSStringFromXmlChar(namespaces[i+1]);
		else
			val = @"";
		
        [nsDict setObject: val forKey: namespaceStr];
		
        if (!processNS)
            [attrDict setObject: val forKey: qualifiedStr];
		
	}
	
	if ( reportNS )
		[parser _pushNamespaces: nsDict];
	
	for ( i = 0; i < (nb_attributes * 5); i += 5 )
	{
		if ( attributes[i] == NULL )
			continue;
		
		NSString * attrLocalName = NSStringFromXmlChar(attributes[i]);
		
		NSString * attrPrefix = nil;
		if ( attributes[i+1] != NULL )
			attrPrefix = NSStringFromXmlChar(attributes[i+1]);
		
		NSString * attrQualified = nil;
		if ( [attrPrefix length] != 0 && !processNS)
			attrQualified = [[NSString alloc] initWithFormat: @"%@:%@", attrPrefix, attrLocalName];
		else
			attrQualified = attrLocalName;
		
		
		NSString * attrValue = @"";
		if ( (attributes[i+3] != NULL) && (attributes[i+4] != NULL) )
		{
			NSUInteger length = attributes[i+4] - attributes[i+3];
			attrValue = [[NSString alloc] initWithBytes: attributes[i+3]
												 length: length
											   encoding: NSUTF8StringEncoding];
		}
		
		[attrDict setObject: attrValue forKey: attrQualified];
		
	}
	
	if ( [delegate respondsToSelector: @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)] )
	{
		[delegate parser: parser
		 didStartElement: elementName
			namespaceURI: uriStr
		   qualifiedName: qualifiedName
			  attributes: attrDict];
	}
	
}

static void __startElement( void * ctx, const xmlChar * name, const xmlChar ** attrs )
{
    BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = [parser delegate];
    
    if ( [delegate respondsToSelector: @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)] == NO )
        return;
    
    NSString * nameStr = NSStringFromXmlChar(name);
    NSMutableDictionary * attrDict = [[NSMutableDictionary alloc] init];
    
    if ( attrs != NULL )
    {
        while ( *attrs != NULL )
        {
            NSString * keyStr = NSStringFromXmlChar(*attrs);
            attrs++;
            
            NSString * valueStr = NSStringFromXmlChar(*attrs);
            attrs++;
            
            if ( (keyStr != nil) && (valueStr != nil) )
                [attrDict setObject: valueStr forKey: keyStr];
            
        }
    }
    
    [delegate parser: parser
     didStartElement: nameStr
        namespaceURI: nil
       qualifiedName: nil
          attributes: attrDict];
    
}

static void __endElement( void * ctx, const xmlChar * name )
{
    BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = [parser delegate];
	
    if ( [delegate respondsToSelector: @selector(parser:didEndElement:namespaceURI:qualifiedName:)] == NO )
        return;
    
    NSString * nameStr = NSStringFromXmlChar(name);
    
    [delegate parser: parser didEndElement: nameStr namespaceURI: nil qualifiedName: nil];
}

static void __ignorableWhitespace( void * ctx, const xmlChar * ch, int len )
{
    BMXMLParser * parser = (__bridge BMXMLParser *) ctx;
	id<BMXMLParserDelegate> delegate = [parser delegate];
    
    if ( [delegate respondsToSelector: @selector(parser:foundIgnorableWhitespace:)] == NO )
		return;
	
	NSString * str = [[NSString allocWithZone: nil] initWithBytes: ch
														   length: len
														 encoding: NSUTF8StringEncoding];
	[delegate parser: parser foundCharacters: str];
}

#pragma mark -

@implementation BMXMLParser

- (id) initWithStream: (NSInputStream *)theStream
{
	if ((self = [super initWithStream:theStream]) == nil )
		return ( nil );
	
	_internal = [[_BMXMLParserInternal alloc] init];
	_internal->saxHandler = NSZoneMalloc( nil, sizeof(struct _xmlSAXHandler) );
	_internal->parserContext = NULL;
	
	self.shouldReportNamespacePrefixes = YES;
	self.shouldProcessNamespaces = YES;
	
	[self _initializeSAX2Callbacks];
	
	return ( self );
}


- (id<BMXMLParserDelegate>)delegate {
	return (id<BMXMLParserDelegate>)[super delegate];
}

- (void)setDelegate:(id <BMXMLParserDelegate>)theDelegate {
	[super setDelegate:theDelegate];
}

- (BOOL) shouldProcessNamespaces
{
	return ( (_internal->parserFlags & BMXMLParserShouldProcessNamespaces) == BMXMLParserShouldProcessNamespaces );
}

- (void) setShouldProcessNamespaces: (BOOL) value
{
	// don't change if we're already parsing
	if ( [self _xmlParserContext] != NULL )
		return;
	
	if ( value )
		_internal->parserFlags |= BMXMLParserShouldProcessNamespaces;
	else
		_internal->parserFlags &= ~BMXMLParserShouldProcessNamespaces;
}

- (BOOL) shouldReportNamespacePrefixes
{
	return ( (_internal->parserFlags & BMXMLParserShouldReportPrefixes) == BMXMLParserShouldReportPrefixes );
}

- (void) setShouldReportNamespacePrefixes: (BOOL) value
{
	if ( [self _xmlParserContext] != NULL )
		return;
	
	if ( value )
		_internal->parserFlags |= BMXMLParserShouldReportPrefixes;
	else
		_internal->parserFlags &= ~BMXMLParserShouldReportPrefixes;
}

- (BOOL) shouldResolveExternalEntities
{
	return ( (_internal->parserFlags & BMXMLParserShouldResolveExternals) == BMXMLParserShouldResolveExternals );
}

- (void) setShouldResolveExternalEntities: (BOOL) value
{
	if ( [self _xmlParserContext] != NULL )
		return;
	
	if ( value )
		_internal->parserFlags |= BMXMLParserShouldResolveExternals;
	else
		_internal->parserFlags &= ~BMXMLParserShouldResolveExternals;
}

- (BOOL) ignoreParseErrors
{
	return ( (_internal->parserFlags & BMXMLParserShouldIgnoreParseErrors) == BMXMLParserShouldIgnoreParseErrors );
}

- (void) setIgnoreParseErrors: (BOOL) value
{
	if ( [self _xmlParserContext] != NULL )
		return;
	
	if ( value )
		_internal->parserFlags |= BMXMLParserShouldIgnoreParseErrors;
	else
		_internal->parserFlags &= ~BMXMLParserShouldIgnoreParseErrors;
}

- (BOOL) isInHTMLMode
{
    return ( (_internal->parserFlags & BMXMLParserHTMLMode) == BMXMLParserHTMLMode );
}

- (void) setHTMLMode: (BOOL) value
{
    if ( [self _htmlParserContext] != NULL )
        return;
    
    if ( value )
        _internal->parserFlags |= BMXMLParserHTMLMode;
    else
        _internal->parserFlags &= ~BMXMLParserHTMLMode;
}

@end

@implementation BMXMLParser (Protected)

#pragma mark -
#pragma mark Protected method implementation

- (void)parserAborted {
	xmlStopParser( _internal->parserContext );
	[super parserAborted];
}

- (void)parserFinished {
	xmlSetStructuredErrorFunc((__bridge void *)(self), __structuredErrorFunc);
	xmlParseChunk( _internal->parserContext, NULL, 0, 1 );
	xmlSetStructuredErrorFunc(0, 0);
	[super parserFinished];
}

- (void)parserDealloc {
	BM_RELEASE_SAFELY(_internal->namespaces);
	
	//Causes memory leak for some reason
	//xmlSetStructuredErrorFunc( 0, 0 );
	NSZoneFree( nil, _internal->saxHandler );
	
	if ( _internal->parserContext != NULL )
	{
        if ( self.HTMLMode )
        {
            htmlFreeParserCtxt( _internal.htmlParserContext );
        }
        else // XML mode
        {
			xmlParserCtxtPtr p = _internal.xmlParserContext;
			
			//Inserted to fix memory leak in xmlFreeParserCtxt
			if (p->sax != NULL) {
				xmlFree(p->sax);
				p->sax = NULL;
			}
			
            if ( p->myDoc != NULL )
                xmlFreeDoc( p->myDoc );
            xmlFreeParserCtxt( _internal->parserContext );
        }
	}	
	BM_RELEASE_SAFELY(_internal);
	[super parserDealloc];
}

- (void)parseData:(const void *)bytes length:(NSUInteger)length {
	[self _pushXMLData:bytes length:length];
	[super parseData:bytes length:length];
}

- (void)initializeParserWithBytes: (const void *) buf length: (NSUInteger) length {
	[super initializeParserWithBytes:buf length:length];
	[self _initializeParserWithBytes:buf length:length];
}

@end

@implementation BMXMLParser (BMXMLParserLocatorAdditions)

- (NSString *) publicID
{
	return ( nil );
}

- (NSString *) systemID
{
	return ( nil );
}

- (NSInteger) lineNumber
{
	if ( _internal->parserContext == NULL )
		return ( 0 );
	
	return ( xmlSAX2GetLineNumber(_internal->parserContext) );
}

- (NSInteger) columnNumber
{
	if ( _internal->parserContext == NULL )
		return ( 0 );
	
	return ( xmlSAX2GetColumnNumber(_internal->parserContext) );
}

@end

@implementation BMXMLParser (Internal)

- (void) _setParserErrorWithCode: (int) err
{
    NSError *error = [[NSError alloc] initWithDomain: NSXMLParserErrorDomain
												  code: err
											  userInfo: nil];
    [self setParserError:error];
}

- (xmlParserCtxtPtr) _xmlParserContext
{
	return ( _internal.xmlParserContext );
}

- (htmlParserCtxtPtr) _htmlParserContext
{
    return ( _internal.htmlParserContext );
}

- (void) _pushNamespaces: (NSDictionary *) nsDict
{
	if ( _internal->namespaces == nil )
		_internal->namespaces = [[NSMutableArray alloc] init];
	
	if ( nsDict != nil )
	{
		[_internal->namespaces addObject: nsDict];
		
		if ( [self.delegate respondsToSelector: @selector(parser:didStartMappingPrefix:toURI:)] )
		{
			for ( NSString * key in nsDict )
			{
				[self.delegate parser: self didStartMappingPrefix: key toURI: [nsDict objectForKey: key]];
			}
		}
	}
	else
	{
		[_internal->namespaces addObject: [NSNull null]];
	}
}

- (void) _popNamespaces
{
	id obj = [_internal->namespaces lastObject];
	if ( obj == nil )
		return;
	
	if ( [obj isEqual: [NSNull null]] == NO )
	{
		if ( [self.delegate respondsToSelector: @selector(parser:didEndMappingPrefix:)] )
		{
			for ( NSString * key in obj )
			{
				[self.delegate parser: self didEndMappingPrefix: key];
			}
		}
	}
	
	[_internal->namespaces removeLastObject];
}

- (void) _initializeSAX2Callbacks
{
	xmlSAXHandlerPtr p = _internal.xmlSaxHandler;
	
	p->internalSubset = __internalSubset2;
	p->isStandalone = __isStandalone;
	p->hasInternalSubset = __hasInternalSubset2;
	p->hasExternalSubset = __hasExternalSubset2;
	p->resolveEntity = __resolveEntity;
	p->getEntity = __getEntity;
	p->entityDecl = __entityDecl;
	p->notationDecl = __notationDecl;
	p->attributeDecl = __attributeDecl;
	p->elementDecl = __elementDecl;
	p->unparsedEntityDecl = __unparsedEntityDecl;
	p->setDocumentLocator = NULL;
	p->startDocument = __startDocument;
	p->endDocument = __endDocument;
	p->startElement = NULL; //__startElement;
	p->endElement = NULL; //__endElement;
	p->startElementNs = __startElementNS;
	p->endElementNs = __endElementNS;
	p->reference = NULL;
	p->characters = __characters;
	p->ignorableWhitespace = __ignorableWhitespace;
	p->processingInstruction = __processingInstruction;
	p->warning = NULL;
	p->error = __errorCallback;
    p->serror = __structuredErrorFunc;
	p->getParameterEntity = __getParameterEntity;
	p->cdataBlock = __cdataBlock;
	p->comment = __comment;
	p->externalSubset = __externalSubset2;
	p->initialized = XML_SAX2_MAGIC;
}

- (void) _initializeParserWithBytes: (const void *) buf length: (NSUInteger) length
{
    if ( self.HTMLMode )
    {
        // for HTML, we use the non-NS callbacks; for XML, we don't want these to get in the way.
        htmlSAXHandlerPtr saxPtr = _internal.htmlSaxHandler;
        saxPtr->startElement = __startElement;
        saxPtr->endElement = __endElement;
        
        _internal->parserContext = htmlCreatePushParserCtxt( saxPtr, (__bridge void *)(self),
															(const char *)(length > 0 ? buf : NULL),
															BMShortenUIntToIntSafely(length, nil), NULL, XML_CHAR_ENCODING_UTF8 );
        
        htmlCtxtUseOptions( _internal.htmlParserContext, XML_PARSE_RECOVER );
    }
    else
    {
        _internal->parserContext = xmlCreatePushParserCtxt( _internal.xmlSaxHandler, (__bridge void *)(self),
                                                           (const char *)(length > 0 ? buf : NULL),
                                                           BMShortenUIntToIntSafely(length, nil), NULL );
		
        int options = [self shouldResolveExternalEntities] ?
		XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_DTDLOAD | XML_PARSE_NOCDATA :
		XML_PARSE_RECOVER;
        
        xmlCtxtUseOptions( _internal->parserContext, options );
    }
}

- (void) _pushXMLData: (const void *) bytes length: (NSUInteger) length
{
    if ( _internal->parserContext == NULL )
    {
        [self _initializeParserWithBytes: bytes length: length];
    }
    else
    {
        int err = XML_ERR_OK;
        if ( self.HTMLMode )
            err = htmlParseChunk( _internal.htmlParserContext, (const char *)bytes, BMShortenUIntSafely(length, nil), 0 );
        else
            err = xmlParseChunk( _internal.xmlParserContext, (const char *)bytes, BMShortenUIntSafely(length, nil), 0 );
        
        if ( err != XML_ERR_OK && !self.ignoreParseErrors )
        {
            LogError(@"Could not parse chunk: %s", (const char *)bytes);
            [self _setParserErrorWithCode: err];
            [self stopParsing];
        }
    }
}

- (_BMXMLParserInternal *) _info
{
	return ( _internal );
}


@end

