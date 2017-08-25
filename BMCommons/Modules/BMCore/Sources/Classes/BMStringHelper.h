//
//  BMStringHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/09/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class with string utility methods
 */
@interface BMStringHelper : BMCoreObject {
	
}

/**
 Returns true if and only if a string is nil or equal to the empty string.
 */
+ (BOOL)isEmpty:(nullable NSString *)string;

/**
 Extracts a substring by looking for the specified begin and end markers.
 
 @return The first occurence of a string between the specified begin and end marker
 */
+ (nullable NSString *)getSubStringFromString:(NSString *)string beginMarker:(NSString *)beginMarker endMarker:(NSString *)endMarker;

/**
 Parses integers from strings by using the specified sscanf pattern and subsequently compares them. 
 
 UTF8 encoding is used.
 
 @param s1 String containing the first int number to compare
 @param s2 String containing the second int number to compare
 @param thePattern sscanf pattern for parsing the int number from the supplied strings
 @returns the comparison result
 */
+ (NSComparisonResult)numericPatternCompareString:(NSString *)s1 withString:(NSString *)s2 usingPattern:(NSString *)thePattern;

/**
 Checks if the supplied string is nil and converts it to the empty string if so, otherwise the string is returned unmodified.
 */
+ (NSString *)filterNilString:(nullable NSString *)s;

/**
 Checks if the supplied string is the empty string, if so it is converted to nil, otherwise the string is returned unmodified
 */
+ (nullable NSString *)filterEmptyString:(nullable NSString *)s;

/**
 Returns a string containing a Universal Unique Identifier. 
 
 The identifier is in the form: 68753A44-4D6F-1226-9C60-0050E4C00067
 */
+ (NSString*) stringWithUUID;

/**
 Returns the specified string as URL where all special characters are replaced with percentage escapes.
 
 If the string already contains a '%'-character no percentage encoding is applied.
 */
+ (nullable NSURL *)urlFromString:(NSString *)s;

/**
 Returns a string where all special characters are replaced with percentage escapes.
 
 If the string already contains a '%'-character no percentage encoding is applied.
 */
+ (nullable NSString *)urlStringFromString:(NSString *)s;

/**
 Returns the UTF8 string representation of the specified data.
 */
+ (nullable NSString *)stringRepresentationOfData:(NSData *)data;

/**
 Returns the UTF8 data representation of the specified string.
 */
+ (nullable NSData *)dataRepresentationOfString:(NSString *)string;

/**
 Returns a formatted string with the kCFNumberFormatterDecimalStyle by parsing the supplied double.
 */
+ (NSString *)decimalStringFromDouble:(double)d;

/**
 Returns a formatted string with currency symbol and format for the current locale.
 */
+ (NSString *)currencyStringFromDouble:(double)d;

/**
 Returns a formatted string with currency symbol as specified by the supplied currency code.
 
 @see [NSNumberFormatter setCurrencyCode:]
 */
+ (nullable NSString *)currencyStringFromDouble:(double)d withCurrencyCode:(nullable NSString *)currencyCode;

/**
 Returns a copy of the string with the first char converted to lowercase.
 */
+ (NSString *)stringByConvertingFirstCharToLowercase:(NSString *)s;

/**
 Returns a copy of the string with the first char converted to uppercase.
 */
+ (NSString *)stringByConvertingFirstCharToUppercase:(NSString *)s;


/**
 Converts a filePath to a file URL or returns nil if the path is nil.
 */
+ (nullable NSURL *)urlFromFilePath:(NSString *)filePath;

/**
 A dictionary containing key/value pairs for a url query string. Plus signs are automatically converted to spaces.
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)query;

/**
 A dictionary containing key/value pairs for a url query string. Plus signs are optionally converted to spaces.
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)query decodePlusSignsAsSpace:(BOOL)decodePlusSigns;

/**
 A properly encoded url query string from the supplied parameter dictionary.
 
 This is the inverse of [BMStringHelper parametersFromQueryString:]. Includes the questionmark as prefix.
 No base64 encoding is used.
 
 @see queryStringFromParameters:includeQuestionMark:useBase64Encoding:
 */
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters includeQuestionMark:(BOOL)includeQuestionMark;

/**
 Returns a properly encoded query string from the specified parameters dictionary. Optionally includes the leading question mark and encodes NSData parameters using base64 encoding. 
 
 If useBase64Encoding == NO any NSData parameters are converted to UTF-8 text.
 */
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters includeQuestionMark:(BOOL)includeQuestionMark useBase64Encoding:(BOOL)useBase64Encoding;

/**
 * Generates a random string of the specified length using the specified character set for the characters to source from.
 *
 * @param length The length of the string to generate
 * @param characterSet The characterset to use or nil for the default characterset containing all numbers (0-9) and the 26 letters of the latin alphabet in both lower and upper case.
 * @return The generated random string.
 */
+ (NSString *)randomStringOfLength:(NSUInteger)length charSet:(nullable NSCharacterSet *)characterSet;

@end

NS_ASSUME_NONNULL_END