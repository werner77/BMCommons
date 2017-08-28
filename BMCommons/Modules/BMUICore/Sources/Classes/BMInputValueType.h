//
//  BMValueType.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BMCommons/BMUICoreObject.h>

//Predefined value types: use these as argument to [BMValueType registeredValueTypeForKey:]
#define VALUE_TYPE_DEFAULT @"default"

#define VALUE_TYPE_BOOL @"bool"
#define VALUE_TYPE_INT @"int"
#define VALUE_TYPE_UINT @"uint"
#define VALUE_TYPE_FLOAT @"float"
#define VALUE_TYPE_UFLOAT @"ufloat"

//Date in format: dd/MM/yy
#define VALUE_TYPE_DATE @"date"

//Time in format: dd/MM/yy HH:mm:ss
#define VALUE_TYPE_TIME @"time"

#define VALUE_TYPE_EMAIL @"email"
#define VALUE_TYPE_PHONE @"phone"

NS_ASSUME_NONNULL_BEGIN

/**
 Class describing the type/format of a value.
 
 Has support for a valid regex expression, allowed characters for input, keyboard type, etc.
 */
@interface BMInputValueType : BMUICoreObject

@property (nonatomic, readonly) NSString *typeKey;

/**
 Value transformer that converts a string to the value type (e.g. an NSDate, NSNumber, etc).
 */
@property (nullable, nonatomic, readonly) NSValueTransformer *valueTransformer;

/**
 A regex describing the valid string input for this value (if nil anything is valid) 
 */
@property (nullable, nonatomic, readonly) NSString *validPattern;

/**
 The allowed character set for string input of this value
 */
@property (nullable, nonatomic, readonly) NSCharacterSet *allowedCharacterSet;

/**
 The keyboard type to use for input.
 */
@property (nonatomic, readonly) UIKeyboardType keyboardType;

- (id)initWithTypeKey:(NSString *)theTypeKey transformer:(nullable NSValueTransformer *)transformer
		 validPattern:(nullable NSString *)validPattern allowedCharacterSet:(nullable NSCharacterSet *)charSet
		 keyboardType:(UIKeyboardType)type NS_DESIGNATED_INITIALIZER;

/**
 Validates the supplied string value for this value type.
 */
- (BOOL)validateValue:(nullable NSString *)value;

/**
 Whether to allow the specified change for this value type. 
 
 Can be used by a UITextFieldDelegate to check whether the input is allowed.
 */
- (BOOL)allowChangeOfCharactersInRange:(NSRange)range inString:(NSString *)text replacementString:(NSString *)string;

+ (NSArray *)registeredValueTypes;

/**
 Returns a registered value type (if existent) for the supplied key. 
 
 See the definitions of predefined value types in this header file above.
 */
+ (nullable BMInputValueType *)registeredValueTypeForKey:(NSString *)typeKey;

/**
 Constructs a value type with only the keyboard type set.
 */
+ (nullable BMInputValueType *)valueTypeWithKeyboardType:(UIKeyboardType)keyboardType;

@end

NS_ASSUME_NONNULL_END
