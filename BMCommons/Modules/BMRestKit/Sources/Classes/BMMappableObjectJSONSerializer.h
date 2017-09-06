//
//  BMMappableObjectJSONSerializer.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMappableObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Serializer for serializing a BMMappableObject to JSON and back.
 */
@interface BMMappableObjectJSONSerializer : NSObject

/**
 Parsed object from the supplied JSON data.
 */
- (nullable id <BMMappableObject>)parsedObjectFromJSONData:(NSData *)data
                                    withRootXPath:(nullable NSString *)xPath
                                         forClass:(Class <BMMappableObject>)mappableObjectClass
                                            error:(NSError *_Nullable *_Nullable)error;

- (nullable NSArray *)parsedArrayFromJSONData:(NSData *)data
                        withRootXPath:(nullable NSString *)xPath
                             forClass:(Class <BMMappableObject>)mappableObjectClass
                                error:(NSError * _Nullable *_Nullable)error;

/**
 The json string with name equal to the supplied element name.
 */
- (nullable NSString *)jsonElementWithName:(nullable NSString *)elementName fromObject:(id <BMMappableObject>)mappableObject;

/**
 The json string with name equal to the supplied element name, using the specified attributePrefix and textContentIdentifier.

 If attributePrefix is nil, the empty string is assumed.
 If textContentIdentifier is nil, #text is used.
 If elementName is nil, the json will have no root element
 */
- (nullable NSString *)jsonElementWithName:(nullable NSString *)elementName attributePrefix:(nullable NSString *)attributePrefix
            textContentIdentifier:(nullable NSString *)textContentIdentifier fromObject:(id <BMMappableObject>)mappableObject;

/**
 The json string with name equal to the root element or nil if the rootElementName is not defined.
 */
- (nullable NSString *)rootJsonElementFromObject:(id <BMMappableObject>)mappableObject;

@end

NS_ASSUME_NONNULL_END
