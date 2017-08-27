//
//  BMMappableObjectXMLSerializer.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMappableObject.h>
#import <BMCommons/BMXMLElement.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Serializer for serializing a BMMappableObject to XML and back.
 */
@interface BMMappableObjectXMLSerializer : NSObject


/**
 The xmlElement with name equal to the root element or nil if rootElementName is not defined.
 */
- (nullable BMXMLElement *)rootXmlElementFromObject:(nullable id <BMMappableObject>)object;

/**
 Returns this object as XML Element (inverse coversion from object to XML)
 */
- (nullable BMXMLElement *)xmlElementWithName:(NSString *)elementName fromObject:(id <BMMappableObject>)object;

/**
 Returns this object as XML Element (inverse coversion from object to XML) by using the specified namespace prefixes for the namespaces encountered (key=namespaceURI, value=prefix)
 */
- (nullable BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI namespacePrefixes:(nullable NSMutableDictionary *)namespacePrefixes fromObject:(nullable id <BMMappableObject>)object;

/**
 Same as xmlElementWithName:namespaceURI:namespacePrefixes:fromObject: but optionally sets jsonMode to preserve empty arrays/dictionaries for array/dictionary mapping types.
 */
- (nullable BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI namespacePrefixes:(nullable NSMutableDictionary *)namespacePrefixes fromObject:(nullable id <BMMappableObject>)object jsonMode:(BOOL)jsonMode;


/**
 Returns a parsed object from the supplied XML Data. 
 
 The rootXPath (which is looked for by the parser) should map to an object of the class this method is called upon.
 Returns nil if an error occured (error will be filled in that case) or the parsed object if successful;.
 */
- (nullable id <BMMappableObject>)parsedObjectFromXMLData:(NSData *)data
                                   withRootXPath:(NSString *)xPath
                                        forClass:(Class<BMMappableObject>)mappableObjectClass
                                           error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
