//
//  BMAbstractMappableObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMFieldMapping.h>
#import <BMCommons/BMXMLElement.h>
#import <CoreData/CoreData.h>

#define SET_IF_DEFINED(x, y) {id z = y;  if (z) {x = z;}}

NS_ASSUME_NONNULL_BEGIN

/**
 Base class for BMMappableObject implementations.
 */
@interface BMAbstractMappableObject : NSObject<NSCoding, NSCopying, BMMappableObject> {

}

/**
 * Returns a shallow copy of this object by only copying the direct properties.
 * This in contrast with copyWithZone: which will perform a deep copy of the object.
 *
 */
- (id)shallowCopyWithZone:(nullable NSZone *)zone;

/**
 * Calls shallowCopyWithZone with zone set to nil.
 */
- (id)shallowCopy;

/**
 This array of strings describing property to message mappings is used to autogenerate implementations for: dealloc, initWithCoder, encodeWithCoder and [BMMappableObject fieldMappings].
 
 All properties designated in this array are automatically serialized using the NSCoding protocol and released in dealloc by calling the setter with a nil value. A mapping dictionary is generated from the format string as specified by [BMMappableObject fieldMappings].
 
 The encoding of the format is as follows:
 
    <fieldName>[;<xmlMappingPath>[;<fieldFormat>]]
 
 Here
 
 - <fieldName> is the name of the field or property, e.g. the string "identifier" for the property:
 
    @property (nonatomic, retain) NSString *identifier;
 
 - <xmlMappingPath> (optional, defaults to <fieldName>) is the XPath within the message to map the property to. Examples:
 
    <xmlMappingPath>="" //The text contents for the current XMLElement are mapped
    <xmlMappingPath>="@count" //The attribute named 'count' for the current XMLElement
    <xmlMappingPath>=@"a@count" //The attribute named 'count' under the subelement named 'a'
    <xmlMappingPath>=@"a/b@count" //The attribute named 'count' under the subelement 'b' under 'a'
    <xmlMappingPath>=@"a/b/c" //The text contents of the subelement 'c' under 'b' under 'a'
 
 - <fieldFormat> (optional, only required for types that are not NSString). If <fieldFormat> is present it implies that <xmlMappingPath> should also be present, even if it is the default path.
 
    <fieldFormat>=<type>[(<subType>)][:<format>]
 
 If <type> is defined it is interpreted to convert the string value to the specified format.
 The following types are valid:
    
    "string" --> NSString: no conversion, this is the default and may be omitted
    "int" --> NSNumber from int
    "double" --> NSNumber from double
    "bool" --> NSNumber from boolean
    "url" --> NSURL constructed with urlFromString
    "date" --> any of the dates in formats "standardDate", "standardTime", "gpxTime" (see BMDateHelper for more info on these formats) or a custom date format
    "object" --> another BMMappableObject class
    "array" --> a mutable array
    "custom" --> a custom selector to set the value
 
 In case <type>=="array", "object" or "custom" the <subType> value is required and should specify a concrete class name of another class implementing BMMappableObject or one of the types listed above with the exception of "array", "object" and "custom". The string value from the message is automatically converted to an instance of the supplied class if possible. If not possible a nil value will result.
 
 The <format> identifier is currently only supported for type "date" (where it is optional and specifies the date format) and "custom" (where it is required and specifies the name of a custom selector to call). In case of date it is either a date format such as "dd-MM-yyyy" or one of the preconfigured date formats:
 
 - RFC3339: uses [BMDateHelper dateFromRFC3339String:] and [BMDateHelper rfc3339StringFromDate:]
 - standardTime: uses [BMDateHelper standardTimestampFormatter]
 - standardDate: uses [BMDateHelper standardDateFormatter]
 
 if no format is specified [BMFieldMapping defaultDateFormat] is used (defaults to 'RFC3339') together with [BMFieldMapping defaultTimeZone] (defaults to 'UTC').
 
 In case of a "custom" type the format specifies the selector that should be called on the object where a ':' is appended e.g.:
    
    "someNumberField;elementNameForTheField;custom(int):setCustomFieldWithNumber"
 
 This example assumes the object contains the following property and setter method:
 
    @property (nonatomic, retain) NSNumber *someNumberField;
    
    - (void)setCustomFieldWithNumber:(NSNumber *)someNumberField;
 
 Full example:
 
 XML Message:
 
    <bar id="1"><a>someString</a><b>2010-01-01</b><c>200</c><d><foo><f>bla</f><g>blabla</g></foo></d></bar>

 Assume this object (of class Bar) maps to the element named "bar" and contains the properties:
 
    @property (nonatomic, retain) NSDate *creationDate;
    @property (nonatomic, retain) NSNumber *count;
    @property (nonatomic, retain) NSString *identifier; 
    @property (nonatomic, retain) NSString *name;
    @property (nonatomic, retain) Foo *foo;
 
 The class named Foo contains the mappings for the xml snippet under the "foo" element.
 
 The following field mapping format array could be returned for this situation:
 
     [NSArray arrayWithObjects:
     @"identifier;@id" //No format or type needed, string is default, the attribute 'id' maps to the property 'identifier'
     @"name;a" //the element 'a' maps to the string property 'name'
     @"creationDate;b;date(standardDate)" //The element 'b' maps to creationDate which should be parsed in standard date format (defined as yyyy-MM-dd in UTC time zone)
     @"count;c;int" // The element c maps to the NSNumber count, which is parsed as an int value.
     @"foo;d/e;object(Foo)" //The element 'e' under 'd' maps to the setter 'setFoo:' with newly instantiated an object of class 'Foo'. This class will handle the mappings under 'e' recursively
     @"bar;d/e/g;custom(Bar):setBar", //The element 'g' under 'e' under 'd' maps to the custom setter @selector(setBar:) by first converting the contents of the element to the class Bar
     nil]
 
 @warning NSArray properties should be of kind NSMutableArray to allow read/write access to the array.
 */
+ (nullable NSArray *)fieldMappingFormatArray;

/**
 Integer which is compared upon deserialization to determine if the version stored is compatible with the current class.
 
 If not, deserialization is stopped and nil is returned.
 
 The default implementation uses a sum of hashcodes of all the field mappings. So if any field mapping changes or mappings are added or removed the version changes.
 */
+ (int64_t)serialVersionUID;

/**
 Overwrites the data with the supplied object by copying similar properties, ignoring nil values or not depending on the boolean supplied.
 
 Fails with exception if other is not of the same class as self.
 */
- (void)mergeWithData:(BMAbstractMappableObject *)other ignoreNilValues:(BOOL)ignoreNilValues;

/**
 Overwrites the data with the supplied object by copying similar properties, ignoring nil values or not depending on the boolean supplied.
 
 Tho performs a deep merge to recurse into fields of class BMAbstractMappableObject to perform the same operation, set deepMerge to true.
 
 If perform class check == true: fails with exception if other is not of the same class as self.
 */
- (void)mergeWithData:(BMAbstractMappableObject *)other ignoreNilValues:(BOOL)ignoreNilValues performClassCheck:(BOOL)performClassCheck deepMerge:(BOOL)deepMerge;

/**
 Validates the state of this object.
 */
- (BOOL)validateWithError:(NSError * _Nullable *_Nullable)error;

/**
 Returns a sha1 digest using the values of all field mappings recursively.
 */
- (nullable NSString *)sha1Digest;

/**
 * The keypaths that should not be included in the digest calculation.
 */
+ (nullable NSSet<NSString *> *)keyPathsToIgnoreForDigest;

@end

@interface BMAbstractMappableObject(XMLSerialization)

/**
 The xmlElement with name equal to the root element or nil if rootElementName is not defined.
 */
- (nullable BMXMLElement *)rootXmlElement;

/**
 Returns this object as XML Element (inverse coversion from object to XML)
 */
- (nullable BMXMLElement *)xmlElementWithName:(NSString *)elementName;

/**
 Returns this object as XML Element (inverse coversion from object to XML) by using the specified namespace prefixes for the namespaces encountered (key=namespaceURI, value=prefix)
 */
- (nullable BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI namespacePrefixes:(nullable NSMutableDictionary *)namespacePrefixes;

/**
 Returns a parsed object from the supplied XML Data. 
 
 The rootXPath (which is looked for by the parser) should map to an object of the class this method is called upon.
 Returns nil if an error occured (error will be filled in that case) or the parsed object if successful;.
 */
+ (nullable instancetype)parsedObjectFromXMLData:(NSData *)data
                                   withRootXPath:(nullable NSString *)xPath
                                           error:(NSError * _Nullable * _Nullable)error;


@end

@interface BMAbstractMappableObject(JSONSerialization)


/**
 The json string with name equal to the root element or nil if the rootElementName is not defined.
 */
- (nullable NSString *)rootJsonElement;

/**
 Returns this object as JSON Element
 */
- (nullable NSString *)jsonElementWithName:(nullable NSString *)elementName;

/**
 Returns this object as JSON Element by using the specified attributePrefix and textContentIdentifier.
 */
- (nullable NSString *)jsonElementWithName:(nullable NSString *)elementName attributePrefix:(nullable NSString *)attributePrefix
            textContentIdentifier:(nullable NSString *)textContentIdentifier;


/**
 Returns a parsed object from the supplied JSON Data.
 
 The rootXPath (which is looked for by the parser) should map to an object of the class this method is called upon.
 Returns nil if an error occured (error will be filled in that case) or the parsed object if successful;.
 */
+ (nullable instancetype)parsedObjectFromJSONData:(NSData *)data
                                    withRootXPath:(nullable NSString *)xPath
                                            error:(NSError *_Nullable *_Nullable)error;

+ (nullable NSArray *)parsedArrayFromJSONData:(NSData *)data
                       withRootXPath:(nullable NSString *)xPath
                               error:(NSError *_Nullable *_Nullable)error;

@end

@interface BMAbstractMappableObject(CoreData)

/**
 Method for merging data objects with model objects: the primary keys of the model and data objects are compared.

 All Model objects
 for which no corresponding data object exists are removed. If no model object exists for a corresponding data object it is inserted
 in the context.
 The merge selector is called on each data object with argument the corresponding model object.
 */
+ (void)mergeDataObjects:(NSArray *)dataObjects
        withModelObjects:(NSArray *)modelObjects
                 ofClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector
               inContext:(NSManagedObjectContext *)context;

/**
 Merges the toManyRelationship of the specified model object.

 For all objects in the toManyRelationship the merge method above is called.
 */
+ (void)mergeDataObjects:(NSArray *)dataObjects
         withModelObject:(NSManagedObject *)modelObject
 usingToManyRelationship:(NSString *)relationShip
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
           mergeSelector:(SEL)mergeSelector;


@end

NS_ASSUME_NONNULL_END
