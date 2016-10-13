//
//  BMObjectMappingParserHandler.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMObjectMappingParserHandler.h"
#import "BMErrorCodes.h"
#import "BMErrorHelper.h"
#import "BMStringHelper.h"
#import "BMXMLParser.h"
#import "BMOrderedDictionary.h"
#import "BMXMLElement.h"
#import "BMXMLDocument.h"
#import "BMJSONParser.h"
#import "BMDynamicObject.h"
#import <BMRestKit/BMRestKit.h>

@interface BMObjectMappingParserHandler(Private)

- (void)initModelDictionaryFromRootClass:(Class)c;
- (void)initErrorModelDictionaryFromRootClass:(Class)c;
- (void)abortParsing:(BMParser *)parser withErrorMessage:(NSString *)errorMessage;
- (void)setCurrentElement:(BMParserElement *)element;
- (void)pushElement:(BMParserElement *)element;
- (void)popElement;
- (id)internalResult;

@end

@implementation BMObjectMappingParserHandler {
@private
	NSString *_topElement;
	NSString *_topErrorElement;
	BOOL _errorResponse;

	NSDictionary *_modelDictionary;
	NSDictionary *_errorModelDictionary;

	NSDictionary *_currentModelDictionary;

	BOOL _recordCharacters;
	NSDate *_parseStartDate;

	NSObject<BMMappableObject> *_rootModelObject;
	NSString *_skipElement;

	BMParserElement *_currentElement;
	NSMutableString *_relativeElementName;

	BOOL _started;
	BOOL _forceErrorResponse;

	NSMutableArray *_xmlElementStack;
	BMXMLDocument *_xmlDocument;

	Class _rootClass;
	Class _rootErrorClass;

	NSDictionary *_currentMappingDict;
	NSMutableArray *_rootModelObjects;

	BOOL _rootIsArray;
	BOOL _jsonMode;
}

static BMObjectMappingParserHandlerInitBlock defaultInitBlock = nil;

@synthesize errorResponse = _errorResponse;
@synthesize currentElement = _currentElement;
@synthesize forceErrorResponse = _forceErrorResponse;

+ (void)setDefaultInitBlock:(BMObjectMappingParserHandlerInitBlock)block {
    defaultInitBlock = [block copy];
}

- (id)initWithXPath:(NSString *)rootElementName rootElementClass:(Class <BMMappableObject>)elementClass 
					 delegate:(id <BMParserHandlerDelegate>)theDelegate {
	if ((self = [self initWithXPath:rootElementName 
				  rootElementClass:elementClass
						errorXPath:nil
				 errorRootElementClass:nil
						  delegate:theDelegate])) {
	}
	return self;
}

- (id)initWithXPath:(NSString *)rootElementName rootElementClass:(Class <BMMappableObject>)elementClass 
		 errorXPath:(NSString *)errorRootElementName errorRootElementClass:(Class <BMMappableObject>)errorElementClass	
					 delegate:(id <BMParserHandlerDelegate>)theDelegate {
	if ((self = [self init])) {
        BMRestKitCheckLicense();
		_topElement = rootElementName;
        if (elementClass) {
            [self initModelDictionaryFromRootClass:elementClass];    
        }
		if (errorRootElementName) {
			_topErrorElement = errorRootElementName;
			[self initErrorModelDictionaryFromRootClass:errorElementClass];
		}
		self.delegate = theDelegate;
		_xmlElementStack = [NSMutableArray new];
	}
	return self;
}

- (id)init {
    if ((self = [super init])) {
        BMRestKitCheckLicense();
        if (defaultInitBlock) {
            defaultInitBlock(self);
        }
    }
    return self;
}


- (void)parser:(BMParser *)parser didStartDocumentOfType:(NSString *)documentType {
    _jsonMode = (![documentType isEqual:BMParserDocumentTypeXML]);
    _rootIsArray = ([documentType isEqual:BMParserDocumentTypeJSONArray]);
	_parseStartDate = [NSDate date];
	_errorResponse = NO;
	_rootModelObjects = nil;
    _rootModelObjects = [NSMutableArray new];
	[_xmlElementStack removeAllObjects];
	BM_RELEASE_SAFELY(_xmlDocument);
	_recordCharacters = NO;
	_relativeElementName = [NSMutableString new];
	_started = NO;
	if ([self.delegate respondsToSelector:@selector(handlerDidStartParsing:)]) {
		[self.delegate handlerDidStartParsing:self];
	}
}

- (void)parserDidEndDocument:(BMParser *)parser {
	if (!_started && _topElement) {
		//Couldn't find the root element or root error element
		//Error: unparseable document
		[self abortParsing:parser withErrorMessage:[NSString stringWithFormat:@"Could not find root element/root error element"]];
	} else {		
		if ([self.delegate respondsToSelector:@selector(handlerDidEndParsing:)]) {
			[self.delegate handlerDidEndParsing:self];	
		}
	}
	LogInfo(@"Parsing took %f seconds", [[NSDate date] timeIntervalSinceDate:_parseStartDate]);
}

- (void)parser:(BMParser *)parser parseErrorOccurred:(NSError *)parseError {
	LogError(@"Parse error occured: %@", parseError);
}

- (void)parser:(BMParser *)parser foundCharacters:(NSString *)string {
	if (_recordCharacters && string) {
		[self.currentElement appendText:string];
	}
}

- (void)parserFoundNil:(BMParser *)parser {
    self.currentElement.nilElement = YES;
}

- (BOOL)respondsToSelector:(SEL)selector {
	if (selector == @selector(parser:foundCharacters:) ||
		selector == @selector(parser:foundCDATA:)) {
		return _recordCharacters;
	} else {
		return [super respondsToSelector:selector];
	}
}

- (void)parser:(BMXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	if (_recordCharacters) {
		NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
		if (string) [self.currentElement appendText:string];
	}
}

- (void)parser:(BMParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	if (!_started) {
		BMXMLElement *currentXMLElement = [[BMXMLElement alloc] initWithName:elementName];
		for (NSString *attributeName in attributeDict) {
			[currentXMLElement addAttribute:attributeName value:[attributeDict objectForKey:attributeName]];
		}
		
		if (_xmlElementStack.count == 0) {
			//Create an XMLDocument the first time. Without an XMLDocument the XPath does not work.
			_xmlDocument = [BMXMLDocument documentWithRootElement:currentXMLElement];
		} else {
			[(BMXMLElement *)[_xmlElementStack lastObject] addChild:currentXMLElement];
		}
		[_xmlElementStack addObject:currentXMLElement];
		
		BMXMLElement *rootXMLElement = [_xmlElementStack objectAtIndex:0];
		if (!self.forceErrorResponse && _topElement && [rootXMLElement elementsForXPath:_topElement error:nil].count > 0) {
			_currentModelDictionary = _modelDictionary;
			_errorResponse = NO;
			_started = YES;
		} else if (_topErrorElement && [rootXMLElement elementsForXPath:_topErrorElement error:nil].count > 0) {
			_currentModelDictionary = _errorModelDictionary;
			_errorResponse = YES;
			_started = YES;
		}
		
		if (_started) {
			//Release the XMLElement stack and document: we don't need it anymore
			[_xmlElementStack removeAllObjects];
			BM_RELEASE_SAFELY(_xmlDocument);
			
			//Root element has empty element name in our model by definition 
			BMParserElement *theElement = [[BMParserElement alloc] initWithName:@"" 
																					 attributes:attributeDict 
																						 parent:nil];
            theElement.treatAttributesAsElements = _jsonMode;
			[self pushElement:theElement];
						
		} 
	} else if (_skipElement == nil) {
		BOOL shouldParse = YES;
		if ([self.delegate respondsToSelector:@selector(handler:shouldParseModelObjectForElementName:)]) {
			shouldParse = [self.delegate handler:self shouldParseModelObjectForElementName:elementName];
		}
		if (shouldParse) {
            if (self.currentElement == nil) {
                //Another root! Support this for JSON: json can have an array as top level object
                elementName = @"";
            }
			BMParserElement *theElement = [[BMParserElement alloc] initWithName:elementName
																	 attributes:attributeDict
																		 parent:self.currentElement];
            theElement.treatAttributesAsElements = _jsonMode;
            
			[self pushElement:theElement];
		} else {
			_skipElement = elementName;
		}
	}
	_recordCharacters = (_skipElement == nil);
}

- (void)parser:(BMParser *)parser didEndElement:(NSString *)elementName 
			namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (!_started) {
		[_xmlElementStack removeLastObject];
	} else if (_skipElement == nil) {
        BMParserElement *theElement = self.currentElement;
		if (!theElement.nilElement) {
            [theElement fillModelObject];
            NSObject<BMMappableObject> *theModelObject = theElement.modelObject;
            if (theModelObject) {
                [theModelObject afterPropertiesSet];
                if ([self.delegate respondsToSelector:@selector(handler:didParseModelObject:forElementName:)]) {
                    [self.delegate handler:self didParseModelObject:theModelObject forElementName:elementName];
                }
            }
        }
		[self popElement];
	} else if ([_skipElement isEqualToString:elementName]) {
		_skipElement = nil;
	}
    
    _recordCharacters = NO;
}

- (id)result {
    if (!_errorResponse) {
        return self.internalResult;
    } else {
        return nil;
    }
}

- (id <BMMappableObject>)rootModelObject {
    id result = self.result;
    return [result conformsToProtocol:@protocol(BMMappableObject)] ? result : nil;
}

- (NSError *)error {
	NSError *error = nil;
    id result = self.internalResult;
	if ([result respondsToSelector:@selector(error)] && [[result error] isKindOfClass:[NSError class]]) {
		error = [result error];
	}
	return error;
}

@end

@implementation BMObjectMappingParserHandler(Private)

- (id)internalResult {
    if (_rootIsArray) {
        return [NSArray arrayWithArray:_rootModelObjects];
    } else {
        return _rootModelObjects.count == 0 ? nil : [_rootModelObjects objectAtIndex:0];
    }
}

- (void)abortParsing:(BMParser *)parser withErrorMessage:(NSString *)theErrorMessage {
	LogError(@"Fatal error while parsing document: %@", theErrorMessage);
	[parser stopParsing];
}

- (Class)customClassForElement:(BMParserElement *)element {
    Class customClass = nil;
    
    if (self.customTypeDescriptorAttributeName) {
        NSString *customTypeDescriptor = [element.attributes objectForKey:self.customTypeDescriptorAttributeName];
        
        if (self.mappableObjectClassResolver) {
            NSString *className = nil;
            NSString *parentClassName = nil;
            if ([self.mappableObjectClassResolver getMappableObjectClassName:&className andParentClassName:&parentClassName fromDescriptor:customTypeDescriptor]) {
                customClass = NSClassFromString(className);
            }
        }
    }
    return customClass;
}

- (void)pushElement:(BMParserElement *)element {
	
    BOOL root = self.currentElement == nil;
	Class class = nil;
	if (root) {
		//Root element: initialize
		
		if (_errorResponse) {
			class = _rootErrorClass;
		} else {
			class = _rootClass;
		}
		
		_currentMappingDict = nil;
		[_relativeElementName setString:@""];
		
	} else {
        if (_relativeElementName.length > 0) {
			[_relativeElementName appendString:MAPPING_ELEMENT_SEPARATOR];
		}
        
        NSString *wildCardElementName = _relativeElementName.length > 0 ? [_relativeElementName stringByAppendingString:@"*"] : nil;
        
		[_relativeElementName appendString:element.elementName];
		
		class = [_currentMappingDict objectForKey:_relativeElementName];
        
        if (!class && wildCardElementName) {
            class = [_currentMappingDict objectForKey:wildCardElementName];
        }
        
        Class customClass = [self customClassForElement:element];
                
        if (customClass) {
            if (class == nil || [customClass isSubclassOfClass:class]) {
                if ([_currentModelDictionary objectForKey:customClass] == nil) {
                    //Initialize the model dictionary for this class
					[self updateModelDictionary:(NSMutableDictionary *) _currentModelDictionary withClass:customClass];
                }
                class = customClass;
            } else {
                LogWarn(@"Invalid class specified as custom class: %@. Should be a subclass of %@", customClass, class);
            }
        }
	}
	
	if (class) {
		//Current element maps to a model object
		//instantiate an object of the class set in the dictionary
		NSObject<BMMappableObject> *currentModelObject = [class new];
		element.modelObject = currentModelObject;
		
		_currentMappingDict = [_currentModelDictionary objectForKey:class];
		
		[_relativeElementName setString:@""];
		
		if (root) {
            [_rootModelObjects addObject:currentModelObject];
		}
	} 
	
	element.context = [NSString stringWithString:_relativeElementName];
	self.currentElement = element;
}

- (void)popElement {
	BMParserElement *parentElement = self.currentElement.parentElement;
	self.currentElement = parentElement;
	NSString *parentRelativeElementName = (NSString *)parentElement.context;
	[_relativeElementName setString:(parentRelativeElementName ? parentRelativeElementName : @"")];
	
	BMParserElement *e = parentElement;
	while (e) {
		if (e.modelObject) {
			_currentMappingDict = [_currentModelDictionary objectForKey:[e.modelObject class]];
			break;
		} else {
			e = e.parentElement;
		}
	}
	
}

- (void)setCurrentElement:(BMParserElement *)element {
	if (_currentElement != element) {
		_currentElement = element;
	}
}

- (void)updateModelDictionary:(NSMutableDictionary *)dict withClass:(Class)c  {
	NSMutableDictionary *mappingDict = [NSMutableDictionary dictionary];
	if (c) {
		[dict setObject:mappingDict forKey:(id <NSCopying>)c];
	}

	NSDictionary *fieldMappings = [c fieldMappings];
	for (BMFieldMapping *fieldMapping in [fieldMappings allValues]) {
		if (fieldMapping.fieldObjectClassIsMappable) {
			Class fieldObjectClass = fieldMapping.fieldObjectClass;
			if (fieldObjectClass) {
				if (fieldMapping.isDictionary) {
					[mappingDict setObject:fieldObjectClass forKey:[fieldMapping.mappingPath stringByAppendingString:MAPPING_ELEMENT_SEPARATOR @"*"]];
				} else {
					[mappingDict setObject:fieldObjectClass forKey:fieldMapping.mappingPath];
				}
				if (![dict objectForKey:fieldObjectClass]) {
					[self updateModelDictionary:dict withClass:fieldObjectClass];
				}
			}
		}
	}
}

- (void)initModelDictionaryFromRootClass:(Class)c {
	_rootClass = c;
	_modelDictionary = [NSMutableDictionary new];
	[self updateModelDictionary:(NSMutableDictionary *) _modelDictionary withClass:c];
}

- (void)initErrorModelDictionaryFromRootClass:(Class)c {
	_rootErrorClass = c;
	_errorModelDictionary = [NSMutableDictionary new];
	[self updateModelDictionary:(NSMutableDictionary *) _errorModelDictionary withClass:c];
}

@end
