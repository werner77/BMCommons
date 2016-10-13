//
//  BMMappableObjectJSONSerializer.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMMappableObject.h>

/**
 Serializer for serializing a BMMappableObject to JSON and back.
 */
@interface BMMappableObjectJSONSerializer : NSObject

/**
 Parsed object from the supplied JSON data.
 */
- (id <BMMappableObject>)parsedObjectFromJSONData:(NSData *)data
                                    withRootXPath:(NSString *)xPath
                                         forClass:(Class <BMMappableObject>)mappableObjectClass
                                            error:(NSError **)error;

- (NSArray *)parsedArrayFromJSONData:(NSData *)data
                        withRootXPath:(NSString *)xPath
                             forClass:(Class <BMMappableObject>)mappableObjectClass
                                error:(NSError **)error;

/**
 The json string with name equal to the supplied element name.
 */
- (NSString *)jsonElementWithName:(NSString *)elementName fromObject:(id <BMMappableObject>)mappableObject;

/**
 The json string with name equal to the supplied element name, using the specified attributePrefix and textContentIdentifier.
 */
- (NSString *)jsonElementWithName:(NSString *)elementName attributePrefix:(NSString *)attributePrefix
            textContentIdentifier:(NSString *)textContentIdentifier fromObject:(id <BMMappableObject>)mappableObject;

/**
 The json string with name equal to the root element or nil if the rootElementName is not defined.
 */
- (NSString *)rootJsonElementFromObject:(id <BMMappableObject>)mappableObject;


@end
