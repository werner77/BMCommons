//
//  BMObjectMapping.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMFieldMapping.h>
#import <BMCommons/BMEnumerationValue.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Describes a XML/JSON to object mapping
 */
@interface BMObjectMapping : NSObject

/**
 Unique identifier of the mapping.
 */
@property (nullable, nonatomic, strong) NSString *mappingId;

/**
 The name of the mapping which is the normally class name for the class to map to
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The namespace the mapped element belongs to
 */
@property (nullable, nonatomic, strong) NSString *namespaceURI;

/**
 The name of the element which is mapped
 */
@property (nullable, nonatomic, strong) NSString *elementName;

/**
 The name of the parent mapping which is normally the class name the generated class extends from
 */
@property (nullable, nonatomic, strong) NSString *parentName;

/**
 An array of the enumeration values part of this elements' mapping
 */
@property (nullable, nonatomic, readonly) NSArray *enumeratedValues;

/**
 An array of the field mappings contained within this mapping
 */
@property (nullable, strong, nonatomic, readonly) NSArray *fieldMappings;

/**
 An array of the field mappings inherited from the ancestors of this mapping.
 */
@property (nullable, strong, nonatomic, readonly) NSArray *inheritedFieldMappings;

/**
 An array containing both the fieldmappings defined by this object as well as the inherited mappings.
 */
@property (nullable, strong, nonatomic, readonly) NSArray *allFieldMappings;

/**
 The parent mapping for this mapping or nil if no parent mapping exists.
 */
@property (nullable, nonatomic, weak) BMObjectMapping *parentMapping;

/**
 Whether or not this element is a root element.
 */
@property (nonatomic, assign, getter = isRootElement) BOOL rootElement;

- (id)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/**
 Adds a field mapping
 */
- (void)addFieldMapping:(BMFieldMapping *)fm;

/**
 Removes a field mapping
 */
- (void)removeFieldMapping:(BMFieldMapping *)fm;

/**
 Adds an enumerated value to this mapping: makes the mapping an enumeration
 */
- (void)addEnumeratedValue:(BMEnumerationValue *)value;

/**
 Returns true if and only if this mapping has at least one enumerated value
 */
- (BOOL)isEnumeration;

/**
 The element name with the namespace prepended, separated by a colon
 */
- (nullable NSString *)fqElementName;

/**
 * Returns the fully qualified type name (name including any modules).
 */
- (NSString *)objectClassName;

/**
 Returns the unqualified typeName (name without any modules prepended).
 */
- (NSString *)unqualifiedObjectClassName;
    
/**
 * Returns the fully qualified type name of the parent of this object (name including any modules).
 */
- (NSString *)parentObjectClassName;

/**
 Returns the unqualified typeName of the parent of this object (name without any modules prepended).
 */
- (NSString *)unqualifiedParentObjectClassName;

/**
 The field mapping for the value of an enumeration if this object mapping points to an enumeration.
 */
- (nullable BMFieldMapping *)enumeratedFieldValueMapping;

@end

NS_ASSUME_NONNULL_END
