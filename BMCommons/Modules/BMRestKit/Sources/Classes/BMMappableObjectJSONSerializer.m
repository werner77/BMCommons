//
//  BMMappableObjectJSONSerializer.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMappableObjectJSONSerializer.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMMappableObject.h>
#import <BMCommons/BMXMLElement.h>
#import <BMCommons/BMMappableObjectXMLSerializer.h>
#import <BMCommons/BMJSONParser.h>
#import <BMCommons/BMObjectMappingParserHandler.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMRestKit.h>

@implementation BMMappableObjectJSONSerializer

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}

- (id <BMMappableObject>)parsedObjectFromJSONData:(NSData *)data
                                    withRootXPath:(NSString *)xPath
                                         forClass:(Class <BMMappableObject>)mappableObjectClass
                                            error:(NSError **)error {
    return [self parsedObjectFromJSONData:data withRootXPath:xPath forClass:mappableObjectClass withReturnType:mappableObjectClass error:error];
}

- (NSArray *)parsedArrayFromJSONData:(NSData *)data
                       withRootXPath:(NSString *)xPath
                            forClass:(Class <BMMappableObject>)mappableObjectClass
                               error:(NSError **)error {
    return [self parsedObjectFromJSONData:data withRootXPath:xPath forClass:mappableObjectClass withReturnType:[NSArray class] error:error];
}


- (NSString *)jsonElementWithName:(NSString *)elementName fromObject:(id <BMMappableObject>)mappableObject {
    return [self jsonElementWithName:elementName attributePrefix:BM_JSON_DEFAULT_ATTRIBUTE_SPECIFIER textContentIdentifier:BM_JSON_DEFAULT_ELEMENT_TEXT_SPECIFIER fromObject:mappableObject];
}

- (NSString *)jsonElementWithName:(NSString *)elementName attributePrefix:(NSString *)attributePrefix
            textContentIdentifier:(NSString *)textContentIdentifier fromObject:(id <BMMappableObject>)mappableObject {
    
    BOOL emptyElement = [BMStringHelper isEmpty:elementName];
    if (emptyElement) {
        //JSON doesn't require a named root element
        
        //Temp element, we strip it off afterwards
        elementName = @"json";
    }
    
    BMMappableObjectXMLSerializer *xmlSerializer = [BMMappableObjectXMLSerializer new];
    
    BMXMLElement *element = [xmlSerializer xmlElementWithName:elementName namespaceURI:nil namespacePrefixes:nil fromObject:mappableObject jsonMode:YES];
    
    if (attributePrefix == nil) attributePrefix = @"";
    if (textContentIdentifier == nil) textContentIdentifier = @"#text";
    
    NSString *string = [element JSONStringWithAttributePrefix:attributePrefix textContentIdentifier:textContentIdentifier];

    if (!string) {
        return nil;
    }
    
    if (emptyElement) {
        int i;
        NSUInteger startIndex = 0;
        NSUInteger endIndex = string.length;
        NSUInteger foundIndex = NSNotFound;
        for (i = 0; i < 2; ++i) {
            foundIndex = [string rangeOfString:@"{" options:0 range:NSMakeRange(startIndex, string.length - startIndex)].location;
            startIndex = foundIndex + 1;
        }
        startIndex = foundIndex;
        foundIndex = NSNotFound;
        
        for (i = 0; i < 2; ++i) {
            foundIndex = [string rangeOfString:@"}" options:NSBackwardsSearch range:NSMakeRange(startIndex, endIndex - startIndex)].location;
            endIndex = foundIndex;
        }
        
        if (startIndex != NSNotFound && endIndex != NSNotFound && endIndex > startIndex) {
            string = [string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex + 1)];
        }
    }
    return string;
}

/**
 The json string with name equal to the root element or nil if the rootElementName is not defined.
 */
- (NSString *)rootJsonElementFromObject:(id <BMMappableObject>)mappableObject {
    return [self jsonElementWithName:[[mappableObject class] rootElementName] fromObject:mappableObject];
}

#pragma mark - Private

- (id)parsedObjectFromJSONData:(NSData *)data
                 withRootXPath:(NSString *)xPath
                      forClass:(Class <BMMappableObject>)mappableObjectClass
                withReturnType:(Class)returnType
                         error:(NSError **)error {
    NSError *theError = nil;
	id object = nil;
	
	if (data) {
		BMJSONParser *parser = [[BMJSONParser alloc] initWithData:data];
        
        if ([BMStringHelper isEmpty:xPath] || [@"/" isEqualToString:xPath]) {
            parser.jsonRootElementName = @"json";
            xPath = @"/json";
        }
		BMObjectMappingParserHandler *handler = [[BMObjectMappingParserHandler alloc] initWithXPath:xPath
                                                                                   rootElementClass:mappableObjectClass
                                                                                           delegate:nil];
        parser.delegate = handler;
		BOOL parsedOK = [parser parse];
		if (!parsedOK) {
			theError = parser.parserError;
		} else {
			object = handler.result;
		}
        
        if (![object isKindOfClass:returnType]) {
            theError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA description:BMLocalizedString(@"Return type of parsed data is not as expected", nil)];
            object = nil;
        }
        
	} else {
        theError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA description:BMLocalizedString(@"No data was supplied", nil)];
	}
	
	if (error) {
		*error = theError;
	}
	return object;
    
}

@end
