//
//  BMXSDObjectMappingHandler.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMXMLSchemaParser.h>
#import "NSString+BMCommons.h"
#import <BMCommons/NSArray+BMCommons.h>
#import <BMCommons/BMRestKit.h>

@interface BMXMLSchemaParser()

@property(nonatomic, assign) BOOL preProcessMode;

@end

@interface BMXMLSchemaParser(Private)

- (NSString *)fieldDescriptorForXSDField:(NSString *)field type:(NSString *)type array:(BOOL)isArray unique:(BOOL)isUnique namespace:(NSString **)namespace;
- (NSString *)stringByStrippingNamespaceFromString:(NSString *)s namespace:(NSString **)namespace;
- (BOOL)isSimpleType:(NSString *)type;

@end

@implementation BMXMLSchemaParser {
@private
	NSMutableDictionary *_objectMappings;
    NSMutableDictionary *_rootElementTypesDict;
	NSMutableArray *_mappingStack;
	BMObjectMapping *_currentMapping;
	NSString *_lastElementName;
	Class _restrictedBaseType;
	BMFieldMapping *_restrictedFieldMapping;
	NSMutableDictionary *_namespaceDict;
	NSMutableDictionary *_rootElementNamesDict;
	BOOL _qualifiedSchema;
}

static NSDictionary *xsdTypeDictionary = nil;
static NSArray *w3cNamespaces = nil;

+ (void)initialize {
    if (!w3cNamespaces) {
        w3cNamespaces = [NSArray arrayWithObjects:@"http://www.w3.org/1999/XMLSchema", @"http://www.w3.org/2000/10/XMLSchema", @"http://www.w3.org/2001/XMLSchema", nil];
    }
    
    if (!xsdTypeDictionary) {
		xsdTypeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
							 BM_FIELD_TYPE_STRING, @"string",
							 BM_FIELD_TYPE_BOOL, @"boolean",
							 BM_FIELD_TYPE_DOUBLE, @"float",
							 BM_FIELD_TYPE_DOUBLE, @"double",
							 BM_FIELD_TYPE_DOUBLE, @"decimal",
							 BM_FIELD_TYPE_DATE, @"dateTime",
							 BM_FIELD_TYPE_DOUBLE, @"duration",
							 BM_FIELD_TYPE_STRING, @"anyURI", //Should this be url?
							 BM_FIELD_TYPE_STRING, @"normalizedString",
                             BM_FIELD_TYPE_STRING, @"token",
							 BM_FIELD_TYPE_INT, @"integer",
							 BM_FIELD_TYPE_INT, @"negativeInteger",
							 BM_FIELD_TYPE_INT, @"nonNegativeInteger",
							 BM_FIELD_TYPE_INT, @"positiveInteger",
							 BM_FIELD_TYPE_INT, @"nonPositiveInteger",
							 BM_FIELD_TYPE_INT, @"byte",
							 BM_FIELD_TYPE_INT, @"int",
							 BM_FIELD_TYPE_INT, @"long",
							 BM_FIELD_TYPE_INT, @"short",
							 BM_FIELD_TYPE_INT, @"unsignedByte",
							 BM_FIELD_TYPE_INT, @"unsignedInt",
							 BM_FIELD_TYPE_INT, @"unsignedLong",
							 BM_FIELD_TYPE_INT, @"unsignedShort",
							 BM_FIELD_TYPE_DATE, @"date",
							 BM_FIELD_TYPE_DATE, @"time",
							 nil];
	}
}

- (NSDictionary *)primitiveTypeDictionary {
    return xsdTypeDictionary;
}

- (id)initWithMappableObjectClassResolver:(id <BMMappableObjectClassResolver>)mappableObjectClassResolver {
	if ((self = [super initWithMappableObjectClassResolver:mappableObjectClassResolver])) {
		_mappingStack = [NSMutableArray new];
		_namespaceDict = [NSMutableDictionary new];
        _rootElementNamesDict = [NSMutableDictionary new];
        _rootElementTypesDict = [NSMutableDictionary new];
	}
	return self;
}

- (void)dealloc {
}

- (void)parserDidStartDocument:(BMParser *)parser {
    self.targetNamespace = nil;
    _qualifiedSchema = NO;
    _currentMapping = nil;
    _lastElementName = nil;
    _restrictedFieldMapping = nil;
    [_mappingStack removeAllObjects];
	[_namespaceDict removeAllObjects];
    [_rootElementNamesDict removeAllObjects];
    if (self.preProcessMode) {
        [_rootElementTypesDict removeAllObjects];
    }
}

- (void)parserDidEndDocument:(BMParser *)parser {
}

- (void)parser:(BMParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (void)parser:(BMParser *)parser foundCharacters:(NSString *)string {
}

- (void)parser:(BMXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
	[_namespaceDict setObject:namespaceURI forKey:prefix];
}

- (void)parser:(BMXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
	[_namespaceDict removeObjectForKey:prefix];
}

- (void)parser:(BMParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	if ([elementName isEqual:@"schema"]) {
		self.targetNamespace = [attributeDict objectForKey:@"targetNamespace"];
		_qualifiedSchema = [[attributeDict objectForKey:@"elementFormDefault"] isEqual:@"qualified"];
        
        BMMappableObjectNameSpaceType namespaceType = [self.mappableObjectClassResolver typeForNamespace:self.targetNamespace];
        if (namespaceType == BMMappableObjectNameSpaceTypeQualified) {
            _qualifiedSchema = YES;
        } else if (namespaceType == BMMappableObjectNameSpaceTypeUnqualified) {
            _qualifiedSchema = NO;
        }
        
	} else if ([elementName isEqual:@"element"]) {
		BM_RELEASE_SAFELY(_lastElementName);
		_lastElementName = [attributeDict objectForKey:@"name"];
        
        if (_currentMapping) {
			NSString *fieldRef = [attributeDict objectForKey:@"ref"];
			NSString *fieldName = nil;
			NSString *fieldType = nil;
			NSString *namespace = nil;
			
			if (fieldRef) {
                fieldName = [self stringByStrippingNamespaceFromString:fieldRef namespace:&namespace];
                fieldType = [self lookupTypeForElementName:fieldRef];
			} else {
				//Use the same namespace as the current namespace if qualified
				namespace = _qualifiedSchema ? nil : @"";
				fieldName = [attributeDict objectForKey:@"name"];
				fieldType = [attributeDict objectForKey:@"type"];
			}
			
			if (!fieldType) {
				fieldType = fieldName;
			}

            //NSString *minOccurs = [attributeDict objectForKey:@"minOccurs"];
			NSString *maxOccurs = [attributeDict objectForKey:@"maxOccurs"];
			
			BOOL isArray = maxOccurs && ![maxOccurs isEqual:@"0"] && ![maxOccurs isEqual:@"1"];
			//BOOL isOptional = minOccurs && [minOccurs isEqual:@"0"];

			BOOL isUnique = [[attributeDict objectForKey:@"unique"] boolValue];
			
			NSString *mappingPath = fieldName;
			
			NSString *fieldDescriptor = [self fieldDescriptorForXSDField:fieldName type:fieldType array:isArray unique:isUnique namespace:nil];
			
			BMFieldMapping *fm = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor 
                                                                     mappingPath:mappingPath];
			fm.namespaceURI = namespace;
			[_currentMapping addFieldMapping:fm];
		} else {
            //Root element: cross-reference with type
            NSString *type = [attributeDict objectForKey:@"type"];

            if (type) {
                NSString *typeNamespace = nil;
                NSString *typeName = [self stringByStrippingNamespaceFromString:type namespace:&typeNamespace];
                if (!typeNamespace) {
                    typeNamespace = self.targetNamespace;
                }
                
                NSString *mappingName = [self mappingNameForObjectType:typeName forNamespace:typeNamespace];
                [_rootElementNamesDict setObject:_lastElementName forKey:mappingName];
                if (self.preProcessMode) {
                    [_rootElementTypesDict setObject:[NSString stringWithFormat:@"%@|%@", typeNamespace, typeName] forKey:[NSString stringWithFormat:@"%@|%@", self.targetNamespace, _lastElementName]];
                }
            }
        }
    } else if ([elementName isEqual:@"complexType"] || [elementName isEqual:@"simpleType"]) {

        NSString *theName = [attributeDict objectForKey:@"name"];
        BOOL isRootElement = NO;

        if (!theName) {
            theName = _lastElementName;
            isRootElement = (_mappingStack.count == 0);
        }

        NSString *mappingName = [self mappingNameForObjectType:theName forNamespace:self.targetNamespace];
        _currentMapping = [[BMObjectMapping alloc] initWithName:mappingName];
        _currentMapping.namespaceURI = (_mappingStack.count == 0 || _qualifiedSchema) ? self.targetNamespace : nil;
        _currentMapping.elementName = theName;

        [_mappingStack addObject:_currentMapping];

        if (isRootElement) {
            [_rootElementNamesDict setObject:theName forKey:_currentMapping.name];
        }

    } else if (!self.preProcessMode) {
        if ([elementName isEqual:@"restriction"]) {
            NSString *baseName = [attributeDict objectForKey:@"base"];
            NSString *fieldDescriptor = [self fieldDescriptorForXSDField:@"value" type:baseName array:NO unique:NO namespace:nil];
            _restrictedFieldMapping = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor
                                                                         mappingPath:@""];
            _restrictedFieldMapping.namespaceURI = _qualifiedSchema ? nil : @"";
            [_currentMapping addFieldMapping:_restrictedFieldMapping];
        } else if ([elementName isEqual:@"enumeration"]) {
            NSString *stringValue = [attributeDict objectForKey:@"value"];
            id value = stringValue;
            if (value) {
                if ([NSNumber class] == _restrictedFieldMapping.fieldObjectClass) {
                    //Only support for NSNumber (treat all other types as string)
                    BM_IGNORE_SELECTOR_LEAK_WARNING(
                                                    value = [_restrictedFieldMapping.converterTarget performSelector:_restrictedFieldMapping.converterSelector withObject:stringValue];
                                                    )
                }
                BMEnumerationValue *enumValue = [BMEnumerationValue enumerationValueWithValue:value];
                [_currentMapping addEnumeratedValue:enumValue];
            }
        } else if ([elementName isEqual:@"extension"]) {
            NSString *baseName = [attributeDict objectForKey:@"base"];

            //Check whether the baseName is a primitive type: if so treat it the same as restriction
            BOOL isSimpleType = [self isSimpleType:baseName];
            if (isSimpleType) {
                NSString *fieldDescriptor = [self fieldDescriptorForXSDField:@"value" type:baseName array:NO unique:NO namespace:nil];
                BMFieldMapping *fieldMapping = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor
                                                                                   mappingPath:@""];
                fieldMapping.namespaceURI = _qualifiedSchema ? nil : @"";
                [_currentMapping addFieldMapping:fieldMapping];
            } else {
                NSString *namespace = nil;
                baseName = [self stringByStrippingNamespaceFromString:baseName namespace:&namespace];
                _currentMapping.parentName = [self mappingNameForObjectType:baseName forNamespace:namespace];
            }
        } else if ([elementName isEqual:@"attribute"]) {
            if (_currentMapping) {
                NSString *fieldName = [attributeDict objectForKey:@"name"];
                NSString *fieldType = [attributeDict objectForKey:@"type"];
                NSString *mappingPath = [NSString stringWithFormat:@"@%@", fieldName];
                NSString *fieldDescriptor = [self fieldDescriptorForXSDField:fieldName type:fieldType array:NO unique:NO namespace:nil];

                BMFieldMapping *fm = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor
                                                                         mappingPath:mappingPath];
                fm.namespaceURI = _qualifiedSchema ? nil : @"";
                [_currentMapping addFieldMapping:fm];
            }
        }
    }
}

- (void)parser:(BMParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"schema"]) {
		self.targetNamespace = nil;
	} else 	if ([elementName isEqual:@"complexType"] || [elementName isEqual:@"simpleType"]) {
		[_objectMappings setObject:_currentMapping forKey:_currentMapping.name];
		[_mappingStack removeLastObject];
		_currentMapping = [_mappingStack lastObject];
	} else if ([elementName isEqual:@"restriction"]) {
		BM_RELEASE_SAFELY(_restrictedFieldMapping);
	}
}

#pragma mark - Protected methods

- (NSDictionary *)parseSchemaImpl:(NSData *)schemaData fromURL:(NSURL *)url objectMappings:(NSMutableDictionary *)objectMappings withError:(NSError *__autoreleasing *)error {

    _objectMappings = objectMappings;
    self.preProcessMode = NO;
    BMXMLParser *xmlParser = [[BMXMLParser alloc] initWithData:schemaData];
    xmlParser.shouldProcessNamespaces= YES;
    xmlParser.delegate = self;
    if ([xmlParser parse]) {
        return _objectMappings;
    } else {
        if (error) {
            *error = xmlParser.parserError;
        }
        return nil;
    }
}

- (void)eliminateDuplicateFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings {
    [super eliminateDuplicateFieldMappingsFromObjectMappings:objectMappings];
    for (NSString *mappingName in objectMappings) {
        BMObjectMapping *mapping = [objectMappings objectForKey:mappingName];
        
        //Set the rootElementName if appropriate
        NSString *rootElementName = [_rootElementNamesDict objectForKey:mappingName];
        if (rootElementName) {
            mapping.rootElement = YES;
            mapping.elementName = rootElementName;
        }
    }
}

- (BOOL)preProcessSchemaURLs:(NSArray *)schemaURLs withError:(NSError **)error {

    //Pre convert all URLs to JSON data so they can be found by references
    for (NSURL *url in schemaURLs) {
        NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
        if (data) {
            self.preProcessMode = YES;
            BMXMLParser *xmlParser = [[BMXMLParser alloc] initWithData:data];
            xmlParser.shouldProcessNamespaces = YES;
            xmlParser.delegate = self;
            if (![xmlParser parse]) {
                if (error) {
                    *error = xmlParser.parserError;
                }
                return NO;
            }
        } else {
            LogError(@"Could not read data from url '%@': %@", url, *error);
            return NO;
        }
    }
    return YES;
}

- (NSString *)lookupTypeForElementName:(NSString *)elementName {
    NSString *namespace = nil;
    NSString *name = [self stringByStrippingNamespaceFromString:elementName namespace:&namespace];
    NSString *typeNameWithNamespace = [_rootElementTypesDict objectForKey:[NSString stringWithFormat:@"%@|%@", namespace ?: self.targetNamespace, name]];

    NSArray *components = [typeNameWithNamespace componentsSeparatedByString:@"|"];
    NSString *typeNamespace = components.count > 1 ? components.firstObject : nil;
    NSString *typeName = components.lastObject;
    NSString *prefix = nil;

    if (typeNamespace != nil) {
        for (NSString *nsPrefix in _namespaceDict) {
            NSString *ns = [_namespaceDict objectForKey:nsPrefix];
            if ([ns isEqualToString:typeNamespace]) {
                prefix = nsPrefix;
                break;
            }
        }
    }

    if (prefix == nil) {
        return typeName;
    } else {
        return [NSString stringWithFormat:@"%@:%@", prefix, typeName];
    }
}

@end

@implementation BMXMLSchemaParser(Private)

- (NSString *)stringByStrippingNamespaceFromString:(NSString *)s namespace:(NSString **)namespace {
	NSRange range = [s rangeOfString:@":"];
	if (range.location != NSNotFound && range.location < s.length) {
		if (namespace) {
			NSString *namespaceIdentifier = [s substringToIndex:range.location];
			*namespace = [_namespaceDict objectForKey:namespaceIdentifier];
		}
		s = [s substringFromIndex:range.location + 1];
	}
	return s;
}

- (NSString *)simpleFieldTypeFromType:(NSString *)type {
    NSString *namespace = nil;
    NSString *strippedType = [self stringByStrippingNamespaceFromString:type namespace:&namespace];
    NSString *fieldType = [self.primitiveTypeDictionary objectForKey:strippedType];
    if  ([w3cNamespaces containsObject:namespace]) {
        return fieldType;
    } else {
        return nil;
    }
}

- (BOOL)isSimpleType:(NSString *)type {
    return [self simpleFieldTypeFromType:type] != nil;
}

- (NSString *)fieldDescriptorForXSDField:(NSString *)field type:(NSString *)type array:(BOOL)isArray unique:(BOOL)isUnique namespace:(NSString **)namespace {
    
    BMSchemaFieldType schemaFieldType = BMSchemaFieldTypePrimitive;
	
	__autoreleasing NSString *theNamespace = nil;
	
	if (!namespace) {
		namespace = &theNamespace;
	}
	
	type = [self stringByStrippingNamespaceFromString:type namespace:namespace];
	
	NSString *fieldType = [self.primitiveTypeDictionary objectForKey:type];
    
    if (![w3cNamespaces containsObject:*namespace]) {
        fieldType = nil;
    }
    
	if (!fieldType) {
		//Custom type
		fieldType = [self mappingNameForObjectType:type forNamespace:*namespace];
        schemaFieldType |= BMSchemaFieldTypeObject;
    }
    
    if (isArray) {
        schemaFieldType |= BMSchemaFieldTypeArray;
    }

	if (isUnique) {
		schemaFieldType |= BMSchemaFieldTypeUnique;
	}
    
    return [self fieldDescriptorForField:field type:fieldType fieldType:schemaFieldType];
}

@end
