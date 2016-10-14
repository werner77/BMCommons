//
//  BMJSONParser.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#define BM_JSON_DEFAULT_ATTRIBUTE_SPECIFIER @"@"
#define BM_JSON_DEFAULT_ELEMENT_TEXT_SPECIFIER @"#text"

#import <Foundation/Foundation.h>
#import <BMCommons/BMParser.h>

@class BMJSONParser;

//Extra delegate methods for BMJSONParser
@protocol BMJSONParserDelegate <BMParserDelegate>

@optional
//For JSON parsing: nil element encountered
- (void)parserFoundNil:(BMJSONParser *)parser;

@end

/**
 * JSON parser implementation which maps JSON to XML element/attributes so JSON parsing becomes transparent.
 * 
 Attributes should be specified with a prefix to know the have to be treated as such. The attibuteSpecifier property of this class specifies this prefix.
 *
 * The only restriction is that attributes should not come after other types of elements, otherwise they won't be treated as such.
 */
@interface BMJSONParser : BMParser {
}

/**
 Prefix to regard a JSON key as an attribute instead of an element.
 
 Default = "@"
 */
@property (nonatomic, strong) NSString *attributeSpecifier;

/**
 Special key to regard a value as element text instead of a new nested element.
 
 Default = "#text"
 */
@property (nonatomic, strong) NSString *elementTextSpecifier;

/**
 Element to insert as root element. 
 
 Needed for XML compatibility, because XML requires a single root element and JSON does not.
 By default no element is inserted (which means the mapping cannot start from the root).
 */
@property (nonatomic, strong) NSString *jsonRootElementName;

/**
 Returns true iff the parsed json document starts with an array instead of a dictionary.
 */
@property (nonatomic, readonly) BOOL startedDocumentWithArray;

/**
 If set to true, any XML/HTML entities in the form &xxx; will be replaced with their UTF-8 equivalent.
 */
@property (nonatomic, assign) BOOL decodeEntities;

/**
 Sets the default decode entities property for instances of this class.
 */
+ (void)setDefaultDecodeEntities:(BOOL)decodeEntities;

@end
