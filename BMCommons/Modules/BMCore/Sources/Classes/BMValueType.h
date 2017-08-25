//
//  BMPrimitiveType.h
//  BMCommons
//
//  Created by Werner Altewischer on 18/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BMValueType) {
    BMValueTypeObject = 0, //object, id
    BMValueTypeBoolean, //BOOL
    BMValueTypeInteger, //NSInteger
    BMValueTypeUnsignedInteger, //NSUInteger
    BMValueTypeFloat, //float
    BMValueTypeDouble //double
};

NS_ASSUME_NONNULL_BEGIN

/**
 Converter to convert between object type and their raw primitive representation, e.g. NSNumber to Boolean, NSInteger, NSUInteger, etc.
 */
@interface BMValueTypeConverter : NSObject

@property (nonatomic, readonly) BMValueType valueType;

/**
 Returns a converter for converting the specified value type.
 
 If the value type is BMValueTypeObject, nil is returned.
 */
+ (nullable BMValueTypeConverter *)converterForValueType:(BMValueType)valueType;

/**
 Initializes a converter for converting the specified value type.
 
 If the value type is BMValueTypeObject, nil is returned.
 */
- (nullable id)initWithValueType:(BMValueType)valueType NS_DESIGNATED_INITIALIZER;

/**
 Copies the raw primitive value corresponding to the supplied objectValue to the supplied value buffer (pointer to a primitive type).
 In case the value type is BMValueTypeObject the pointer to the object is copied.
 
 Returns YES if successful, NO otherwise.
 The object value type should be compatible with the valueType for this converter.
 */
- (BOOL)getPrimitiveValue:(void *)value withLength:(NSUInteger)valueLength fromObjectValue:(id)objectValue;

/**
 Returns an object value corresponding to the supplied pointer to a primitive value.
 
 The primitive value type should be compatible with the valueType for this converter.
 */
- (nullable id)objectValueFromPrimitiveValue:(void *)value withLength:(NSUInteger)valueLength;

/**
 Returns the size in bytes for a buffer to hold the primitive value as returned by getPrimitiveValue:fromObjectValue:
 */
- (NSUInteger)sizeOfPrimitiveValue;

@end

NS_ASSUME_NONNULL_END
