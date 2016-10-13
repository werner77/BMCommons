//
//  BMEnumeratedValue.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMUICoreObject.h>

@class BMInputValueType;

/**
 Class that is used for representing values with an attached label, e.g. in drop down lists.
 */
@interface BMEnumeratedValue : BMUICoreObject

/**
 The value as a string.
 
 Uses the [BMValueType valueTransformer] of the valueType set to convert from and to value.
 */
@property (nonatomic, strong) NSString *valueString;

/**
 The display label for this value.
 */
@property (nonatomic, strong) NSString *label;

/**
 The corresponding value type.
 */
@property (nonatomic, strong) BMInputValueType *valueType;

/**
 The underlying value.
 */
@property (nonatomic, strong) id value;

/**
 Sets sub values for multi level navigation. The sub values should be instances of BMEnumeratedValue.
 
 This instance then represents a group of sub values or labelled category.
 */
@property (nonatomic, copy) NSArray *subValues;

+ (BMEnumeratedValue *)enumeratedValueWithValue:(id)theValue;
+ (BMEnumeratedValue *)enumeratedValueWithValue:(id)theValue label:(NSString *)theLabel;

/**
 sets the value type from one of the strings: "bool", "int", "float" or "string" (default if none matched)
 */
- (void)setValueTypeString:(NSString *)typeString;
- (NSString *)valueTypeString;

/**
 Adds a sub value.
 
 @see subValues
 */
- (void)addSubValue:(BMEnumeratedValue *)subValue;

@end
