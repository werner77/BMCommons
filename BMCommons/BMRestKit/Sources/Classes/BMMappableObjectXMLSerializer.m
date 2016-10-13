//
//  BMMappableObjectXMLSerializer.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMMappableObjectXMLSerializer.h"
#import <BMCommons/BMXMLParser.h>
#import <BMCommons/BMObjectMappingParserHandler.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMOrderedDictionary.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRestKit.h>

@interface BMMappableObjectXMLSerializer(Private)

- (NSString *)namespacePrefixForURI:(NSString *)namespaceURI withNamespaces:(NSMutableDictionary *)namespaces;

@end


@implementation BMMappableObjectXMLSerializer

- (id)init {
    if ((self = [super init])) {
        BMRestKitCheckLicense();
    }
    return self;
}

/**
 The xmlElement with name equal to the root element or nil if rootElementName is not defined.
 */
- (BMXMLElement *)rootXmlElementFromObject:(id <BMMappableObject>)mappableObject {
    return [self xmlElementWithName:[[mappableObject class] rootElementName] fromObject:mappableObject];
}

/**
 Returns this object as XML Element (inverse coversion from object to XML)
 */
- (BMXMLElement *)xmlElementWithName:(NSString *)elementName fromObject:(id <BMMappableObject>)mappableObject {
    NSMutableDictionary *namespacePrefixes = [NSMutableDictionary dictionary];
	BMXMLElement *element = [self xmlElementWithName:elementName namespaceURI:[[mappableObject class] namespaceURI] namespacePrefixes:namespacePrefixes fromObject:mappableObject];
	for (NSString *namespace in namespacePrefixes) {
		NSString *attributeName = [NSString stringWithFormat:@"xmlns:%@", [namespacePrefixes objectForKey:namespace]];
		[element addAttribute:attributeName value:namespace];
	}
	return element;
}

- (BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI namespacePrefixes:(NSMutableDictionary *)namespacePrefixes fromObject:(id <BMMappableObject>)mappableObject {
    return [self xmlElementWithName:elementName namespaceURI:namespaceURI namespacePrefixes:namespacePrefixes fromObject:mappableObject jsonMode:NO];
}

/**
 Returns this object as XML Element (inverse conversion from object to XML) by using the specified namespace prefixes for the namespaces encountered (key=namespaceURI, value=prefix)
 */
- (BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI namespacePrefixes:(NSMutableDictionary *)namespacePrefixes fromObject:(id <BMMappableObject>)mappableObject jsonMode:(BOOL)jsonMode {
    
    
    NSDictionary *mappings = [[mappableObject class] fieldMappings];
	NSString *namespacePrefix = [self namespacePrefixForURI:namespaceURI withNamespaces:namespacePrefixes];
	
	BMXMLElement *rootElement = [BMXMLElement elementWithName:(namespacePrefix ? [NSString stringWithFormat:@"%@:%@", namespacePrefix, elementName] : elementName)];
	
	NSMutableDictionary *elementDictionary = [BMOrderedDictionary new];
	
	for (BMFieldMapping *mapping in [mappings allValues]) {
        
		BMXMLElement *theElement = rootElement;
		NSArray *elementNameComponents = [mapping elementNameComponents];
		NSString *lastComponent = [elementNameComponents lastObject];
		
		NSMutableString *fullElementName = [NSMutableString new];
		BOOL first = YES;
		
		for (NSString *component in elementNameComponents) {
			if (first) {
				first = NO;
			} else {
				[fullElementName appendString:@"/"];
			}
			[fullElementName appendString:component];
			if (component != lastComponent) {
				BMXMLElement *dictionaryElement = [elementDictionary objectForKey:fullElementName];
				if (!dictionaryElement) {
					dictionaryElement = [theElement addChildNamed:component];
					[elementDictionary setObject:dictionaryElement forKey:fullElementName];
				}
				theElement = dictionaryElement;
			} else {
				break;
			}
		}
		
		NSObject *theObject = [mapping invokeGetterOnTarget:mappableObject];
		NSString *attributeName = mapping.attributeName;
		NSString *mappingNamespaceURI = mapping.namespaceURI ? mapping.namespaceURI : [[mappableObject class] namespaceURI]; //default to namespaceURI
		NSString *mappingNamespacePrefix = mappingNamespaceURI == namespaceURI ? namespacePrefix : [self namespacePrefixForURI:mappingNamespaceURI withNamespaces:namespacePrefixes];
		NSString *prefixedLastComponent = (mappingNamespacePrefix && ![BMStringHelper isEmpty:lastComponent]) ? [NSString stringWithFormat:@"%@:%@", mappingNamespacePrefix, lastComponent] : lastComponent;
		
		BOOL lastComponentDefined = ![BMStringHelper isEmpty:lastComponent];
		
		if (theObject) {
			if (![BMStringHelper isEmpty:attributeName]) {
				//Attribute
				if ([theObject isKindOfClass:[NSString class]]) {
					if (lastComponentDefined) {
						//Check if we need to add an element. Not necessary if it was already added.
						BMXMLElement *childElement = [theElement lastChildNamed:prefixedLastComponent];
						if (!childElement) {
							childElement = [theElement addChildNamed:prefixedLastComponent];
						}
						theElement = childElement;
					}
					BMXMLNode *node = [theElement addAttribute:attributeName value:(NSString *)theObject];
                    node.jsonQuotedValueType = mapping.isJSONStringField;
				} else {
					LogError(@"Error: attribute value should be a string. Failed object: %@", theObject);
				}
            } else if ([theObject isKindOfClass:[NSDictionary class]]) {
                //Dictionary
				if (lastComponentDefined) {
                    BOOL emptyDictionary = YES;
					for (id key in ((id<NSFastEnumeration>)theObject)) {
                        emptyDictionary = NO;
                        id value = [(NSDictionary *)theObject objectForKey:key];
                        BOOL handled = NO;
                        if ([key isKindOfClass:[NSString class]]) {
                            
                            BMXMLElement* childElement = [theElement firstChildNamed:prefixedLastComponent];
                            if (!childElement) {
                                childElement = [theElement addChildNamed:prefixedLastComponent];
                            }
                            
                            if ([value isKindOfClass:[NSString class]]) {
                                BMXMLElement *elem = [childElement addChildNamed:key withTextContent:(NSString *)value];
                                BMXMLNode *textNode = [elem firstChild];
                                textNode.jsonQuotedValueType = mapping.isJSONStringField;
                                handled = YES;
                            } else if ([value conformsToProtocol:@protocol(BMMappableObject)] && [value isKindOfClass:mapping.fieldObjectClass]) {
                                BMXMLElement *keyValueElement = [self xmlElementWithName:key namespaceURI:mappingNamespaceURI namespacePrefixes:namespacePrefixes fromObject:(id <BMMappableObject>)value jsonMode:jsonMode];
                                [childElement addChild:keyValueElement];
                                handled = YES;
                            }
                            
                        }
                        if (!handled) {
							LogError(@"Error: key-value pair in dictionary is not of supported type, ignoring. Failed pair: (%@, %@)", key, value);
						}
					}
                    if (emptyDictionary && jsonMode) {
                        BMXMLElement* childElement = [theElement firstChildNamed:prefixedLastComponent];
                        if (!childElement) {
                            childElement = [theElement addChildNamed:prefixedLastComponent];
                        }
                        childElement.emptyElement = YES;
                    }
                    
				} else {
					LogError(@"Error: empty element name, ignoring. Failed mapping: %@", mapping);
				}
			} else if ([theObject conformsToProtocol:@protocol(NSFastEnumeration)]) {
				//Array
				if (lastComponentDefined) {
                    BOOL emptyArray = YES;
					for (id childObject in ((id<NSFastEnumeration>)theObject)) {
                        emptyArray = NO;
                        BOOL handled = NO;
						if ([childObject conformsToProtocol:@protocol(BMMappableObject)]) {
							if ([childObject isKindOfClass:mapping.fieldObjectClass]) {
                                BMXMLElement *childElement = [self xmlElementWithName:lastComponent namespaceURI:mappingNamespaceURI namespacePrefixes:namespacePrefixes fromObject:(id <BMMappableObject>)childObject jsonMode:jsonMode];
                                childElement.arrayElement = (mapping.isArray || mapping.isSet);
                                [theElement addChild:childElement];
                                handled = YES;
							}
						} else if ([childObject isKindOfClass:[NSString class]]) {
							BMXMLElement* childElement = [theElement addChildNamed:prefixedLastComponent withTextContent:(NSString *)childObject];
                            childElement.arrayElement = (mapping.isArray || mapping.isSet);
                            BMXMLNode *textNode = [childElement firstChild];
                            textNode.jsonQuotedValueType = mapping.isJSONStringField;
                            handled = YES;
						}
                        if (!handled) {
							LogError(@"Error: object in array is not of a supported type, ignoring. Failed object: %@", childObject);
						}
					}
                    if (emptyArray && jsonMode) {
                        BMXMLElement *childElement = [self xmlElementWithName:lastComponent namespaceURI:mappingNamespaceURI namespacePrefixes:namespacePrefixes fromObject:nil jsonMode:jsonMode];
                        childElement.arrayElement = YES;
                        childElement.emptyElement = YES;
                        [theElement addChild:childElement];
                    }
				} else {
					LogError(@"Error: empty element name, ignoring. Failed mapping: %@", mapping);
				}
			} else if ([theObject conformsToProtocol:@protocol(BMMappableObject)]) {
				if (lastComponentDefined) {
                    BMXMLElement *childElement = [self xmlElementWithName:lastComponent namespaceURI:mappingNamespaceURI namespacePrefixes:namespacePrefixes fromObject:(id <BMMappableObject>)theObject jsonMode:jsonMode];
                    childElement.arrayElement = (mapping.isArray || mapping.isSet);
                    [theElement addChild:childElement];
				} else {
					LogError(@"Error: empty element name, ignoring. Failed mapping: %@", mapping);
				}
			} else if ([theObject isKindOfClass:[NSString class]]) {
				if (lastComponentDefined) {
					if (theObject) {
						
						//Check whether we need to add the sub element. Not necessary if it was already added.
						BMXMLElement *childElement = [theElement lastChildNamed:prefixedLastComponent];
						if (!childElement) {
							childElement = [theElement addChildNamed:prefixedLastComponent];
						}
						theElement = childElement;
						BMXMLNode *textNode = [theElement addTextChild:(NSString *)theObject];
                        textNode.jsonQuotedValueType = mapping.isJSONStringField;
					}
				} else {
					BMXMLNode *textNode = [theElement addTextChild:(NSString *)theObject];
                    textNode.jsonQuotedValueType = mapping.isJSONStringField;
				}
			} else {
				LogError(@"Error: object is not of a supported type, ignoring. Failed object: %@", theObject);
			}
		}
	}
	
	return rootElement;
    
}

/**
 Returns a parsed object from the supplied XML Data. The rootXPath (which is looked for by the parser) should map to an object of the class this method is called upon.
 Returns nil if an error occured (error will be filled in that case) or the parsed object if successful;.
 */
- (id <BMMappableObject>)parsedObjectFromXMLData:(NSData *)data
                                   withRootXPath:(NSString *)xPath
                                        forClass:(Class<BMMappableObject>)mappableObjectClass
                                           error:(NSError **)error {
    NSError *theError = nil;
	id <BMMappableObject> object = nil;
	
	if (data) {
		BMParser *parser = [[BMXMLParser alloc] initWithData:data];
		BMObjectMappingParserHandler *handler = [[BMObjectMappingParserHandler alloc] initWithXPath:xPath
                                                                                   rootElementClass:mappableObjectClass
                                                                                           delegate:nil];
		parser.delegate = handler;
		BOOL parsedOK = [parser parse];
		if (!parsedOK) {
			theError = parser.parserError;
		} else {
			object = handler.rootModelObject;
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

@implementation BMMappableObjectXMLSerializer(Private)

- (NSString *)namespacePrefixForURI:(NSString *)namespaceURI withNamespaces:(NSMutableDictionary *)namespaces {
	NSString *namespacePrefix = nil;
	
	if (![BMStringHelper isEmpty:namespaceURI]) {
		namespacePrefix = [namespaces objectForKey:namespaceURI];
		
		if (!namespacePrefix) {
			//Generate a new prefix
			namespacePrefix = [NSString stringWithFormat:@"n%d", (int)(namespaces.count + 1)];
			[namespaces setObject:namespacePrefix forKey:namespaceURI];
		}
	}
	return namespacePrefix;
}

@end
