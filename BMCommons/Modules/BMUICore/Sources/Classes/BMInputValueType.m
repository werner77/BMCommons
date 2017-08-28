//
//  BMValueType.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMInputValueType.h>
#import <BMCommons/BMStringToBooleanValueTransformer.h>
#import <BMCommons/BMStringToIntegerValueTransformer.h>
#import <BMCommons/BMStringToFloatValueTransformer.h>
#import <BMCommons/BMStringToDateValueTransformer.h>
#import <BMCommons/BMDateHelper.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRegexKitLite.h>
#import <BMCommons/BMUICore.h>

@implementation BMInputValueType {
	NSString *typeKey;
	NSString *validPattern;
	NSValueTransformer *valueTransformer;
	NSCharacterSet *allowedCharacterSet;
	UIKeyboardType keyboardType;
}

@synthesize typeKey, valueTransformer, validPattern, allowedCharacterSet, keyboardType;

static NSDictionary *registeredTypes = nil;

+ (void)initialize {
	if (!registeredTypes) {
		NSDateFormatter *dateFormatter = [BMDateHelper utcDateFormatterWithFormat:@"dd/MM/yy"];
		NSDateFormatter *timeFormatter = [BMDateHelper utcDateFormatterWithFormat:@"HH:mm"];
		registeredTypes = @{VALUE_TYPE_DEFAULT: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_DEFAULT
                                                    transformer:nil
                                                   validPattern:nil
                                            allowedCharacterSet:nil
                                                   keyboardType:UIKeyboardTypeDefault],
                           
						   VALUE_TYPE_BOOL: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_BOOL
												  transformer:[BMStringToBooleanValueTransformer new]
												 validPattern:@"^\\d*$"
										  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"01"]
												 keyboardType:UIKeyboardTypeNumberPad],
						   
						   VALUE_TYPE_INT: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_INT
												  transformer:[BMStringToIntegerValueTransformer new]
												 validPattern:@"^-?\\d+$"
										  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890-"]
												 keyboardType:UIKeyboardTypeNumberPad],
						   
						   VALUE_TYPE_UINT: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_UINT
												  transformer:[BMStringToIntegerValueTransformer new]
												 validPattern:@"^\\d+$"
										  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890"]
												 keyboardType:UIKeyboardTypeNumberPad],
						   
						   VALUE_TYPE_FLOAT: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_FLOAT
												  transformer:[BMStringToFloatValueTransformer new]
												 validPattern:@"^-?\\d+(\\.\\d?)?$"
										  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"eE01234567890.-"]
												 keyboardType:UIKeyboardTypeDecimalPad],
						   
						   VALUE_TYPE_UFLOAT: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_UFLOAT
												  transformer:[BMStringToFloatValueTransformer new]
												 validPattern:@"^\\d+(\\.\\d?)?$"
										  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"eE01234567890."]
												 keyboardType:UIKeyboardTypeDecimalPad],
						   
						   VALUE_TYPE_DATE: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_DATE
												  transformer:[[BMStringToDateValueTransformer alloc] initWithDateFormatter:dateFormatter]
												 validPattern:nil
										  allowedCharacterSet:nil
												 keyboardType:UIKeyboardTypeNumbersAndPunctuation],
						   
						   
						   VALUE_TYPE_TIME: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_TIME
												  transformer:[[BMStringToDateValueTransformer alloc] initWithDateFormatter:timeFormatter]
												 validPattern:nil
										  allowedCharacterSet:nil
												 keyboardType:UIKeyboardTypeNumbersAndPunctuation],
						   
						   VALUE_TYPE_EMAIL: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_EMAIL
												   transformer:nil
												  validPattern:@"^(\\w[-._\\w]*@\\w[-._\\w]*\\w\\.\\w{2,6})$"
										   allowedCharacterSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]
												  keyboardType:UIKeyboardTypeEmailAddress],
						   
						   VALUE_TYPE_PHONE: [[BMInputValueType alloc] initWithTypeKey:VALUE_TYPE_PHONE
													  transformer:nil
													 validPattern:@"^\\+(?:[0-9] ?){6,14}[0-9]$"
											  allowedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890-+ "]
													 keyboardType:UIKeyboardTypePhonePad]};
		
	}
}

- (id)init {
	return [self initWithTypeKey:VALUE_TYPE_DEFAULT transformer:nil validPattern:nil allowedCharacterSet:nil keyboardType:UIKeyboardTypeDefault];
}

- (id)initWithTypeKey:(NSString *)theTypeString 
		  transformer:(NSValueTransformer *)transformer 
		 validPattern:(NSString *)pattern 
  allowedCharacterSet:(NSCharacterSet *)charSet
		 keyboardType:(UIKeyboardType)type {
	if ((self = [super init])) {
		typeKey = theTypeString;
		valueTransformer = transformer;
		validPattern = pattern;
		allowedCharacterSet = charSet;
		keyboardType = type;
	}
	return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(typeKey);
	BM_RELEASE_SAFELY(valueTransformer);
	BM_RELEASE_SAFELY(validPattern);
	BM_RELEASE_SAFELY(allowedCharacterSet);
}

- (BOOL)validateValue:(NSString *)value {
	return self.validPattern == nil || [value isMatchedByRegex:self.validPattern];
}

+ (NSArray *)registeredValueTypes {
	return [registeredTypes allValues];
}

+ (BMInputValueType *)registeredValueTypeForKey:(NSString *)typeString {
	
	NSError *error = nil;
	NSString *regex = @"(.*)\\((.*)\\)";
	NSString *typeKey = typeString;
	NSString *format = nil;
	
	if (typeString) {
		NSRange range = [typeString rangeOfRegex:regex options:RKLNoOptions inRange:NSMakeRange(0, typeString.length) capture:2L error:&error];
		
		if (range.location != NSNotFound) {
			typeKey = [typeString substringWithRange:NSMakeRange(0, range.location - 1)];
			
			format = [typeString substringWithRange:range];
		}
	}
	
	BMInputValueType *valueType = registeredTypes[typeKey];
	
	if (format && ([typeKey isEqualToString:VALUE_TYPE_DATE] || [typeKey isEqualToString:VALUE_TYPE_TIME])) {
		NSDateFormatter *dateFormatter = [BMDateHelper utcDateFormatterWithFormat:format];
		NSValueTransformer *transformer = [[BMStringToDateValueTransformer alloc] initWithDateFormatter:dateFormatter];
		valueType = [[BMInputValueType alloc] initWithTypeKey:typeKey transformer:transformer validPattern:valueType.validPattern allowedCharacterSet:valueType.allowedCharacterSet keyboardType:valueType.keyboardType];
	}
	return valueType;
}

+ (BMInputValueType *)valueTypeWithKeyboardType:(UIKeyboardType)keyboardType {
    return [[self alloc] initWithTypeKey:nil transformer:nil validPattern:nil allowedCharacterSet:nil keyboardType:keyboardType];
}

- (BOOL)allowChangeOfCharactersInRange:(NSRange)range inString:(NSString *)text replacementString:(NSString *)string {
    BOOL charactersAllowed = self.allowedCharacterSet == nil || [self.allowedCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]];
	
    if (!charactersAllowed) {
        return NO;
    }
	
    //TODO: possible support for max length
    NSInteger newLength = (text.length - range.length + string.length);
    NSInteger minLength = 0;
    NSInteger maxLength = NSIntegerMax;
    
	BOOL lengthValid = (maxLength == 0 || newLength <= maxLength) && newLength >= minLength;
	
    if (!lengthValid) {
        return NO;
    }
    
    NSString *newString = [text stringByReplacingCharactersInRange:range withString:string];
    
    BOOL patternMatched = [BMStringHelper isEmpty:newString] || [self validateValue:newString];
	return patternMatched;
}

@end
