//
//  BMXSDObjectMappingHandler.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMObjectMapping.h>
#import <BMRestKit/BMXMLParser.h>
#import <BMCore/BMParser.h>
#import <BMRestKit/BMAbstractSchemaParserHandler.h>

/**
 BMParserHandler implementation that parses an XSD schema file and returns an array of BMObjectMappings.
 */
@interface BMXMLSchemaParser : BMAbstractSchemaParserHandler<BMXMLParserDelegate> {
    @private
	NSMutableDictionary *_objectMappings;
	NSMutableArray *mappingStack;
	BMObjectMapping *currentMapping;
	NSString *lastElementName;
	Class restrictedBaseType;
	BMFieldMapping *restrictedFieldMapping;
	NSMutableDictionary *namespaceDict;
    NSMutableDictionary *rootElementNamesDict;
	BOOL qualifiedSchema;
}

@end
