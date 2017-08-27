//
//  BMXSDObjectMappingHandler.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMObjectMapping.h>
#import <BMCommons/BMXMLParser.h>
#import <BMCommons/BMParser.h>
#import <BMCommons/BMAbstractSchemaParserHandler.h>

NS_ASSUME_NONNULL_BEGIN

/**
 BMParserHandler implementation that parses an XSD schema file and returns an array of BMObjectMappings.
 */
@interface BMXMLSchemaParser : BMAbstractSchemaParserHandler<BMXMLParserDelegate>

@end

NS_ASSUME_NONNULL_END
