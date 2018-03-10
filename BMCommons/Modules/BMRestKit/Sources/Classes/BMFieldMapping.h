//
//  BMFieldMapping.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMappableObject.h>
#import <BMCommons/BMSchemaFieldType.h>

#define MAPPING_ELEMENT_SEPARATOR @"/"
#define MAPPING_ATTRIBUTE_SEPARATOR @"@"

NS_ASSUME_NONNULL_BEGIN

@class BMObjectMapping;

/**
 Class that describes a field mapping between object and XML/JSON.
 */
@interface BMFieldMapping : NSObject 

/**
 Set to false to disable class checks for converters (that is if the class can be found and is a sub class of mappable object). 
 
 Useful if classes can not be found in the
 current class path. Default is true.
 */
+ (void)setClassChecksEnabled:(BOOL)enabled;
+ (BOOL)isClassChecksEnabled;

/**
 The default date format to use when no date format is supplied for date fields. 
 
 Defaults to @"RFC3339".
 */
+ (void)setDefaultDateFormat:(nullable NSString *)dateFormat;
+ (nullable NSString *)defaultDateFormat;

/**
 The default time zone to use for custom date formats. 
 
 Defaults to UTC, set to nil to use the local timezone.
 */
+ (void)setDefaultTimeZone:(nullable NSTimeZone *)tz;
+ (nullable NSTimeZone *)defaultTimeZone;

/**
 Parses a field descriptor dictionary as returned by [BMMappableObject fieldMappings]. 
 
 Uses [BMFieldMapping initWithFieldDescriptor:mappingPath:] for each entry in the dictionary (key=mapping path, value=fieldDescriptor)
 */
+ (nullable NSDictionary *)parseFieldDescriptorDictionary:(NSDictionary *)dict;

/**
 Parses a field descriptor dictionary with a dictionary of namespaces for each mapping path (key=mappingPath, value=namespaceURI).
 */
+ (nullable NSDictionary *)parseFieldDescriptorDictionary:(NSDictionary *)dict withNamespaces:(nullable NSDictionary *)namespaceDict error:(NSError * _Nullable *_Nullable )error;

/**
 Initializes the field mapping with a field descriptor and mapping path.
 
 The mapping path is in the format (See BMAbstractMappableObject for a full description):
 
    <xmlMappingPath>=<elementname>[/<subelementname>[/<othersubelementname>...]][@<attributeName>]
 
 The field descriptor is in the format
 
    fieldDescriptor=<propertyName>[:<type>[(<subType>)][:<format>]]
 
 */
- (nullable id)initWithFieldDescriptor:(NSString *)fieldDescriptor mappingPath:(nullable NSString *)theMappingPath;

/**
 Method to set the value of this field. 
 
 Uses converter selectors to convert to the proper type if necessary
 */
- (void)invokeSetterOnTarget:(NSObject <BMMappableObject> *)target withValue:(nullable NSObject *)value;

/**
 Method to get the value of this field. 
 
 Uses inverse converter selectors to convert back to the proper type.
 */
- (nullable NSObject *)invokeGetterOnTarget:(NSObject <BMMappableObject> *)target;

/**
 Method to get the value of this field without performing conversion.
 */
- (nullable NSObject *)invokeRawGetterOnTarget:(NSObject <BMMappableObject> *)target;

/**
 Method to set the value of this field without performing conversion.
 */
- (void)invokeRawSetterOnTarget:(NSObject <BMMappableObject> *)target withValue:(nullable NSObject *)value;

/**
 Optional namespace for the mapping
 */
@property(nullable, nonatomic, strong) NSString *namespaceURI;

/**
 The name of the field, corresponds to the property name of the property to map to
 */
@property(nonatomic, readonly) NSString *fieldName;

/**
 Array with components of the elements mapped to this field, e.g. {@"element1", @"element2"}  
 
 @see mappingPath
 */
@property(nullable, strong, nonatomic, readonly) NSArray *elementNameComponents;

/**
 Mapped attribute name, e.g. "someAttribute"
 
 @see mappingPath
 */
@property(nullable, strong, nonatomic, readonly) NSString *attributeName;

/**
 Full mapping path such as "element1/element2@someAttribute"
 */
@property(nullable, strong, nonatomic) NSString *mappingPath;

/**
 Selector to set the value for the field
 */
@property(nonatomic, readonly) SEL setterSelector;

/**
 Selector to get the value for this field
 */
@property(nonatomic, readonly) SEL getterSelector;

/**
 The converter selector to convert the xml string to an object of class <fieldObjectClass>
 */
@property(nullable, nonatomic, readonly) SEL converterSelector;

/**
 The target for the converter selector to convert the xml string to an object of class <fieldObjectClass>. 
 
 If this property is nil the target is the object being converted.
 */
@property(nullable, strong, nonatomic, readonly) id converterTarget;

/**
 The converter selector to convert the object back to xml string
 */
@property(nullable, nonatomic, readonly) SEL inverseConverterSelector;

/**
 Target for the inverseConverterSelector. If nil it is the object itself.
 */
@property(nullable, strong, nonatomic, readonly) id inverseConverterTarget;

/**
  Returns the converters set (forward and reverse) bundled as a value transformer
*/
@property(nullable, strong, nonatomic, readonly) NSValueTransformer *valueTransformer;

/**
 Class corresponding to fieldObjectClassName

 Can be nil if the class corresponding to fieldObjectClassName could not be resolved.
 */
@property(nullable, nonatomic, readonly) Class fieldObjectClass;

/**
 Class name of the field
 */
@property(strong, nonatomic, readonly) NSString *fieldClassName;

/**
 Class of the type of objects contained in the field.
 
 Is same as fieldClassName except in the case of arrays or sets.
 In that case fieldClassName is (a sub class of) NSArray/NSSet and fieldObjectClassName is the type of objects in the array/set (e.g. NSString)
 */
@property(strong, nonatomic, readonly) NSString *fieldObjectClassName;

/**
 Returns true if and only if the field object class is itself a sub class of MappableObject
 */
@property(nonatomic, readonly) BOOL fieldObjectClassIsMappable;

/**
 Returns true if and only if the field object class is a custom class (i.e. not NSString, NSDate, NSNumber, etc)
 */
@property(nonatomic, readonly) BOOL fieldObjectClassIsCustom;

/**
 Returns true if and only if the field is an array type
 */
@property(nonatomic, readonly, getter=isArray) BOOL array;

/**
 Returns true if and only if the field is a set type
 */
@property(nonatomic, readonly, getter=isSet) BOOL set;

/**
 Returns true if and only if the field is a set type or an array type.
 */
@property(nonatomic, readonly, getter=isCollection) BOOL collection;

/**
 Returns true if and only if the field is a dictionary type
 */
@property(nonatomic, readonly, getter=isDictionary) BOOL dictionary;

/**
 Returns true if and only if the field is of type NSDate.
 */
@property(nonatomic, readonly, getter=isDate) BOOL date;

/**
 Returns the format string for this field, e.g. array(date):simpleDate, object(SomeClass), etc
 */
@property(strong, nonatomic, readonly) NSString *fieldFormat;

/**
 Returns the full field mapping format string, e.g.: 
 
    @"someField;someElement/someSubElement@someAttribute;object(SomeClass)" 
 
 which is 
 
    @"<fieldName>;<mappingPath>;<fieldFormat>".
   
 Field format may be omitted if it is nil.
 */
@property(strong, nonatomic, readonly) NSString *fieldMappingFormatString;

/**
 Whether this descriptor is fully initialized, that is it a call to setFieldDescriptor:withError: has been done with success.
 */
@property(nonatomic, readonly, getter = isInitialized) BOOL initialized;

/**
 Optional reference identifier to an associated object mapping.
 */
@property (nullable, nonatomic, strong) NSString *objectMappingRefId;

/**
 For use by a parser to keep track of the associated schema field type.
 */
@property (nonatomic, assign) BMSchemaFieldType schemaFieldType;

/**
 The schema field format type for pre-defined field formats (e.g. as defined by the JSON schema spec).
 */
@property (nonatomic, assign) BMSchemaFieldFormatType schemaFieldFormatType;

/**
 Whether the property is required or not.
 */
@property (nonatomic, assign, getter=isRequired) BOOL required;

/**
 Defaults to 0. If set to something > 0 a string value is only valid if its length >= this limit.
 */
@property (nonatomic, assign) NSInteger minLength;

/**
 Defaults to -1. If set to something > 0 a string value is only valid if its length <= this limit.
 */
@property (nonatomic, assign) NSInteger maxLength;
    
/**
 Defaults to 0. If set to something > 0 a collection value is only valid if its size >= this limit.
 */
@property (nonatomic, assign) NSInteger minItems;

/**
 Defaults to -1. If set to something > 0 a collection value is only valid if its size <= this limit.
 */
@property (nonatomic, assign) NSInteger maxItems;

/**
 If set to true a collection value is required to have distinct (unique) items.
 */
@property (nonatomic, assign) BOOL uniqueItems;

/**
 If set, the minimum valid value for a numeric value type.
 */
@property (nonatomic, strong) NSNumber *minimum;

/**
 If set, the maximum valid value for a numeric value type.
 */
@property (nonatomic, strong) NSNumber *maximum;

/**
 If set, a numeric value is only valid if it is divisible by this number.
 */
@property (nonatomic, strong) NSNumber *multipleOf;

/**
 Returns true iif minimum != nil
 */
@property (nonatomic, readonly) BOOL hasMinimum;

/**
 Returns true iif maximum != nil
 */
@property (nonatomic, readonly) BOOL hasMaximum;

/**
 Returns true iif multipleOf != nil
 */
@property (nonatomic, readonly) BOOL hasMultipleOf;

/**
 If set, the minimum is exclusive, else inclusive.
 */
@property (nonatomic, assign, getter=isExclusiveMinimum) BOOL exclusiveMinimum;

/**
 If set, the maximum is exclusive, else inclusive.
 */
@property (nonatomic, assign, getter=isExclusiveMaximum) BOOL exclusiveMaximum;

/**
 Regex pattern to validate a string value against.
 */
@property (nonatomic, nullable, strong) NSString *pattern;

/**
 Escaped pattern which can be used within a string litteral: "<escaped pattern>"
 */
@property (nonatomic, nullable, strong) NSString *escapedPattern;

/**
 Valid values in case of an enumeration
 */
@property (nonatomic, strong) NSArray *enumeratedValues;

/**
 The object mapping this field mapping belongs to if any.
 */
@property (nonatomic, weak) BMObjectMapping *parentObjectMapping;

/**
 Returns true iff the field represented by this mapping converts to a JSON string. 
 
 If true it should be quoted in the resulting JSON, either with single or double quotes.
 */
- (BOOL)isJSONStringField;

/**
 Returns true iff the field represents an enumeration, i.e. enumeratedValues contains a finite amount of values.
 */
- (BOOL)isEnumeration;

/**
 Returns true iff the field represents an enumeration AND all enumeratedValues are strings.
 */
- (BOOL)isStringEnumeration;

/**
 The type name in case it is an enumeration, else nil
 */
- (NSString *)enumerationTypeName;

/**
 Initializes with the specified field descriptor.
 */
- (BOOL)setFieldDescriptor:(NSString *)fieldDescriptor withError:(NSError * _Nullable *_Nullable )error;

/**
 * Returns the class name without any module info (part after the last dot)
 */
- (NSString *)unqualifiedFieldObjectClassName;

@end

NS_ASSUME_NONNULL_END

