//
//  BMMappableObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 29/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

@class BMXMLElement;

#define BM_FIELD_TYPE_STRING @"string"
#define BM_FIELD_TYPE_INT @"int"           
#define BM_FIELD_TYPE_DOUBLE @"double"     
#define BM_FIELD_TYPE_BOOL @"bool"         
#define BM_FIELD_TYPE_URL @"url"           
#define BM_FIELD_TYPE_DATE @"date"
#define BM_FIELD_TYPE_OBJECT @"object"     
#define BM_FIELD_TYPE_ARRAY @"array"
#define BM_FIELD_TYPE_CUSTOM @"custom"

/**
 Protocol to be implemented by concrete classes that define XML-object mappings
 */
@protocol BMMappableObject<NSObject, NSCoding>

/**
 * Returns a map of key=mappingPath and value=BMFieldMapping
 */
+ (NSDictionary *)fieldMappings;

/**
 * Returns a map of key=mappingPath and value=String with namespaceURI
 */
+ (NSDictionary *)fieldMappingNamespaces;

/** 
 The namespace URI for this object (used when the object is converted back to XML)
 */
+ (NSString *)namespaceURI;

/**
 The name of the root element or nil if this object is not mapped to a root XML element.
 */
+ (NSString *)rootElementName;

/**
 To perform any conversion of the state of the object after all properties have been set by mapping from JSON/XML
 */
- (void)afterPropertiesSet;


@optional

/**
 Return an error if the parsed content corresponds with an error
 */
- (NSError *)error;

@end

