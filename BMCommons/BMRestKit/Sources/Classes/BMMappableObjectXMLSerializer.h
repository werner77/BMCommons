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

/**
 Serializer for serializing a BMMappableObject to XML and back.
 */
@interface BMMappableObjectXMLSerializer : NSObject


/**
 The xmlElement with name equal to the root element or nil if rootElementName is not defined.
 */
- (BMXMLElement *)rootXmlElementFromObject:(id <BMMappableObject>)object;

/**
 Returns this object as XML Element (inverse coversion from object to XML)
 */
- (BMXMLElement *)xmlElementWithName:(NSString *)elementName fromObject:(id <BMMappableObject>)object;

/**
 Returns this object as XML Element (inverse coversion from object to XML) by using the specified namespace prefixes for the namespaces encountered (key=namespaceURI, value=prefix)
 */
- (BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI namespacePrefixes:(NSMutableDictionary *)namespacePrefixes fromObject:(id <BMMappableObject>)object;

/**
 Same as xmlElementWithName:namespaceURI:namespacePrefixes:fromObject: but optionally sets jsonMode to preserve empty arrays/dictionaries for array/dictionary mapping types.
 */
- (BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI namespacePrefixes:(NSMutableDictionary *)namespacePrefixes fromObject:(id <BMMappableObject>)object jsonMode:(BOOL)jsonMode;


/**
 Returns a parsed object from the supplied XML Data. 
 
 The rootXPath (which is looked for by the parser) should map to an object of the class this method is called upon.
 Returns nil if an error occured (error will be filled in that case) or the parsed object if successful;.
 */
- (id <BMMappableObject>)parsedObjectFromXMLData:(NSData *)data
                                   withRootXPath:(NSString *)xPath
                                        forClass:(Class<BMMappableObject>)mappableObjectClass
                                           error:(NSError **)error;

@end
