//
//  BMEnumeratedValue.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMUICoreObject.h>

NS_ASSUME_NONNULL_BEGIN

@class BMInputValueType;

/**
 Class that is used for representing values with an attached label, e.g. in drop down lists.
 */
@interface BMEnumeratedValue : BMUICoreObject

/**
 The value as a string.
 
 Uses the [BMValueType valueTransformer] of the valueType set to convert from and to value.
 */
@property (nullable, nonatomic, strong) NSString *valueString;

/**
 The display label for this value.
 */
@property (nullable, nonatomic, strong) NSString *label;

/**
 The corresponding value type.
 */
@property (nullable, nonatomic, strong) BMInputValueType *valueType;

/**
 The underlying value.
 */
@property (nullable, nonatomic, strong) id value;

/**
 Sets sub values for multi level navigation. The sub values should be instances of BMEnumeratedValue.
 
 This instance then represents a group of sub values or labelled category.
 */
@property (nullable, nonatomic, copy) NSArray *subValues;

+ (BMEnumeratedValue *)enumeratedValueWithValue:(nullable id)theValue;
+ (BMEnumeratedValue *)enumeratedValueWithValue:(nullable id)theValue label:(nullable NSString *)theLabel;

/**
 sets the value type from one of the strings: "bool", "int", "float" or "string" (default if none matched)
 */
- (void)setValueTypeString:(nullable NSString *)typeString;
- (nullable NSString *)valueTypeString;

/**
 Adds a sub value.
 
 @see subValues
 */
- (void)addSubValue:(BMEnumeratedValue *)subValue;

@end

NS_ASSUME_NONNULL_END
