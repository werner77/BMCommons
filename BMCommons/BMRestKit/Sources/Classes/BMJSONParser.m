//
//  BMJSONParser.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMJSONParser.h>
#import "NSString+BMCommons.h"
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRestKit.h>
#import "YAJLParser.h"

@interface BMJSONParser()<YAJLParserDelegate>

@property(nonatomic, assign) BOOL emptyArray;

@end

@interface BMJSONParser(Private)

- (id)decodedValue:(id)value;
- (void)pushElement:(NSString *)element;
- (NSString *)popElement;
- (NSString *)popElement:(BOOL)sendEndElementMessage;
- (void)startDocumentWithArray:(BOOL)array;
- (NSString *)currentKey;
- (void)setCurrentKey:(NSString *)key;
- (NSString *)lastElement;
- (void)setLastElement:(NSString *)element;
- (NSString *)currentElement;
- (NSString *)currentAttribute;
- (void)sendStartMessageForCurrentElement;
- (void)endDocument;
- (void)incrementElementLevel:(BOOL)sendMessage;
- (void)incrementSkipArrayLevel;
- (void)decrementSkipArrayLevel;
- (BOOL)skip;

@end

@implementation BMJSONParser {
    int _elementLevel;
    NSString *_currentKey;
    NSString *_lastElement;
    NSMutableArray *_elementStack;
    NSMutableDictionary *_attributes;
    
    NSString *_attributeSpecifier;
    NSString *_elementTextSpecifier;
    
    YAJLParser *_parser;
    BOOL _started;
    BOOL _isProcessingAttribute;
    BOOL _isProcessingElementText;
    NSString *_jsonRootElementName;
    BOOL _startedDocumentWithArray;
    BOOL _emptyDocument;
    int _skipArrayLevel;
}

@synthesize attributeSpecifier = _attributeSpecifier, elementTextSpecifier = _elementTextSpecifier, jsonRootElementName = _jsonRootElementName, startedDocumentWithArray = _startedDocumentWithArray, emptyArray = _emptyArray;

static BOOL defaultDecodeEntities = NO;

+ (void)setDefaultDecodeEntities:(BOOL)decodeEntities {
    defaultDecodeEntities = decodeEntities;
}

- (id)initWithStream:(NSInputStream *)theStream {
	if ((self = [super initWithStream:theStream])) {
		_elementStack = [NSMutableArray new];
		_attributes = [NSMutableDictionary new];
		_parser = [[YAJLParser alloc] initWithParserOptions:(YAJLParserOptionsAllowComments | YAJLParserOptionsCheckUTF8 | YAJLParserOptionsStrictPrecision)];
		_parser.delegate = self;
        self.attributeSpecifier = BM_JSON_DEFAULT_ATTRIBUTE_SPECIFIER;
        self.elementTextSpecifier = BM_JSON_DEFAULT_ELEMENT_TEXT_SPECIFIER;
		_elementLevel = 0;
        _skipArrayLevel = 0;
        _emptyDocument = NO;
        self.decodeEntities = defaultDecodeEntities;
	}
	return self;
}

#pragma mark -
#pragma mark Parsing

- (NSError *)parserError {
	return _parser.parserError;
}

#pragma mark -
#pragma mark YAJLParserDelegate

/*!
 Parser did start dictionary.
 @param parser Sender
 */
- (void)parserDidStartDictionary:(YAJLParser *)parser {
    if (!self.skip) {
        [self startDocumentWithArray:NO];
        
        self.emptyArray = NO;
        
        //For arrays: push the last element if no current key
        if (!_currentKey && _lastElement) {
            [self pushElement:_lastElement];
            self.currentKey = _lastElement;
        }
    }
}

/*!
 Parser did end dictionary.
 @param parser Sender
 */
- (void)parserDidEndDictionary:(YAJLParser *)parser {
    if (!self.skip) {
        [self popElement];
        self.currentKey = nil;
    }
}

/*!
 Parser did start array.
 @param parser Sender
 */
- (void)parserDidStartArray:(YAJLParser *)parser {
    [self startDocumentWithArray:YES];
    if (self.emptyArray) {
        LogWarn(@"Arrays with dimensions > 1 are not supported by BMJSONParser. Ignoring array under key: %@", self.currentKey);
        [self incrementSkipArrayLevel];
    } else {
        self.emptyArray = YES;
    }
}

/*!
 Parser did end array.
 @param parser Sender
 */
- (void)parserDidEndArray:(YAJLParser *)parser {
    if (!self.skip) {
        if (self.emptyArray) {
            [self incrementElementLevel:_emptyDocument];
            [self popElement:_emptyDocument];
        }
        self.currentKey = nil;
        self.emptyArray = NO;
    }
    [self decrementSkipArrayLevel];
}

/*!
 Parser did map key.
 @param parser Sender
 @param key Key that was mapped
 */
- (void)parser:(YAJLParser *)parser didMapKey:(NSString *)key {
    if (!self.skip) {
        self.emptyArray = NO;
        _emptyDocument = NO;
        self.currentKey = key;
        
        if (!_isProcessingAttribute) {
            [self sendStartMessageForCurrentElement];
        }
        
        if (!_isProcessingAttribute && !_isProcessingElementText) {
            [self pushElement:key];
        }
    }
}

/*!
 Did add value.
 @param parser Sender
 @param value Value of type NSNull, NSString or NSNumber
 */
- (void)parser:(YAJLParser *)parser didAdd:(id)value {
    if (!self.skip) {
        value = [self decodedValue:value];
        self.emptyArray = NO;
        _emptyDocument = NO;
        
        if (!_currentKey && _lastElement) {
            [self pushElement:_lastElement];
            self.currentKey = _lastElement;
        }
        
        BOOL isNull = value == nil || value == [NSNull null];
        NSString *currentAttribute = self.currentAttribute;
        
        if (currentAttribute) {
            if (!isNull) {
                [_attributes setObject:[value description] forKey:currentAttribute];
            }
        } else {
            [self sendStartMessageForCurrentElement];
            
            if (!isNull) {
                if ([self.delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
                    [self.delegate parser:self foundCharacters:[value description]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(parserFoundNil:)]) {
                    [(id <BMJSONParserDelegate>)self.delegate parserFoundNil:self];
                }
            }
        }
        
        if (!currentAttribute && !_isProcessingElementText) {
            [self popElement];
        }
        
        self.currentKey = nil;
    }
}


@end

@implementation BMJSONParser(Protected)

- (void)parserFinished {
	[super parserFinished];
}

- (void)parserAborted {
	[super parserAborted];
}

- (void)parseData:(const void *)bytes length:(NSUInteger)length {
	NSData *data = [NSData dataWithBytes:bytes length:length];
	
	YAJLParserStatus status = [_parser parse:data];
	switch (status) {
		case YAJLParserStatusNone:
			//Don't do anything
			break;
		case YAJLParserStatusOK:
			//Finished
			[self endDocument];
			break;
		case YAJLParserStatusError:
			//Error
			if ([self.delegate respondsToSelector:@selector(parser:parseErrorOccurred:)]) {
				[self.delegate parser:self parseErrorOccurred:self.parserError];
			}
			[self stopParsing];
			break;
	}
	
	[super parseData:bytes length:length];
}

- (void)initializeParserWithBytes: (const void *) buf length: (NSUInteger) length {
	[super initializeParserWithBytes:buf length:length];
}

- (void)parserDealloc {
	BM_RELEASE_SAFELY(_parser);
	BM_RELEASE_SAFELY(_attributeSpecifier);
	BM_RELEASE_SAFELY(_elementTextSpecifier);
	BM_RELEASE_SAFELY(_currentKey);
	BM_RELEASE_SAFELY(_lastElement);
	BM_RELEASE_SAFELY(_elementStack);
	BM_RELEASE_SAFELY(_attributes);
    BM_RELEASE_SAFELY(_jsonRootElementName);
	[super parserDealloc];
}

@end


@implementation BMJSONParser(Private)

- (id)decodedValue:(id)value {
    if (self.decodeEntities && [value isKindOfClass:[NSString class]]) {
        return [value bmStringByDecodingEntities];
    } else {
        return value;
    }
}

- (NSString *)currentElement {
	return [_elementStack lastObject];
}

- (NSString *)currentAttribute {
	return _isProcessingAttribute ? [_currentKey substringFromIndex:_attributeSpecifier.length] : nil;
}

- (void)startDocumentWithArray:(BOOL)array {
	if (!_started) {
        _startedDocumentWithArray = array;
		_started = YES;
		_elementLevel = 0;
        _skipArrayLevel = 0;
		_isProcessingAttribute = NO;
		_isProcessingElementText = NO;
		[_attributes removeAllObjects];
		[_elementStack removeAllObjects];
		//Send message to delegate
		if ([self.delegate respondsToSelector:@selector(parser:didStartDocumentOfType:)]) {
            NSString *documentType = array ? BMParserDocumentTypeJSONArray : BMParserDocumentTypeJSONDictionary;
			[self.delegate parser:self didStartDocumentOfType:documentType];
		}

        if (![BMStringHelper isEmpty:self.jsonRootElementName]) {
            //Map an artificial root element
            [self parser:_parser didMapKey:self.jsonRootElementName];
            [self parserDidStartDictionary:_parser];

        }
        _emptyDocument = YES;
	}
}

- (void)endDocument {

    if (![BMStringHelper isEmpty:self.jsonRootElementName]) {
        [self parserDidEndDictionary:_parser];
    }

    if ([self.delegate respondsToSelector:@selector(parserDidEndDocument:)]) {
        [self.delegate parserDidEndDocument:self];
    }
}

- (void)incrementElementLevel:(BOOL)sendMessage {
	NSString *element = self.currentElement;
	if (_elementLevel < _elementStack.count) {
		if (sendMessage && [self.delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
			[self.delegate parser:self didStartElement:element namespaceURI:@"" qualifiedName:element attributes:_attributes];
		}
		_elementLevel++;
	}
	[_attributes removeAllObjects];
}

- (void)sendStartMessageForCurrentElement {
    [self incrementElementLevel:YES];
}

- (void)pushElement:(NSString *)element {
	[_elementStack addObject:element];
}

- (NSString *)popElement {
    return [self popElement:YES];
}

- (NSString *)popElement:(BOOL)sendEndElementMessage {
	if (_elementStack.count > 0) {
        
        //Only necessary in case an empty dictionary was encountered
        if (sendEndElementMessage) {
            [self sendStartMessageForCurrentElement];
        }
		NSString *element = self.currentElement;
		[_elementStack removeLastObject];
		self.lastElement = element;
		if (sendEndElementMessage && [self.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
			[self.delegate parser:self didEndElement:element namespaceURI:@"" qualifiedName:element];
		}
		_elementLevel--;
		return element;
	} else {
		return nil;
	}
}

- (NSString *)currentKey {
	return _currentKey;
}

- (void)setCurrentKey:(NSString *)key {
	if (key != _currentKey) {
		_currentKey = key;
		
		_isProcessingAttribute = [_currentKey hasPrefix:_attributeSpecifier];
		_isProcessingElementText = [_currentKey isEqual:_elementTextSpecifier];
	}
}

- (NSString *)lastElement {
	return _lastElement;
}

- (void)setLastElement:(NSString *)element {
	if (element != _lastElement) {
		_lastElement = element;
	}
}

- (void)incrementSkipArrayLevel {
    _skipArrayLevel++;
}

- (void)decrementSkipArrayLevel {
    _skipArrayLevel = MAX(0, _skipArrayLevel - 1);
}

- (BOOL)skip {
    return _skipArrayLevel > 0;
}

@end
