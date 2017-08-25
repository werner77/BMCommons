//
//  NSString+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSString additions.
 */
@interface NSString(BMCommons)

/**
 Returns a string containing the specified bytes using hex encoding (as in [NSString stringWithFormat:@"%2X", byte]).
 
 This method is optimized for performance.
 */
+ (instancetype)bmHexEncodedStringForBytes:(unsigned char *)bytes length:(NSUInteger)length;
+ (instancetype)bmHexEncodedStringForBytes:(unsigned char *)bytes length:(NSUInteger)length lowercase:(BOOL)lowercase;

/**
 Returns a string containing the bytes from the specified data using hex encoding (as in [NSString stringWithFormat:@"%2X", byte]).
 
 This method is optimized for performance.
 */
+ (instancetype)bmHexEncodedStringForData:(NSData *)data;

/**
 Calls stringWithFormat but with an array instead of using varargs as arguments.
 */
+ (instancetype)bmStringWithFormat:(NSString *)format arguments:(NSArray*) arguments;

/**
 * Returns a string containing the specified UTF32 char.
 *
 * @param c The character to add to the string.
 * @return A string containing only the specified char.
 */
+ (instancetype)bmStringWithUTF32Char:(UTF32Char)c;

/**
 converts a string to make it suitable for a URL (encodes special characters to percentage values)
 */
- (nullable NSString*)bmStringWithPercentEscapes;

/**
 Reverse encodes percentage encoding and replaces '+' characters with spaces.
 */
- (nullable NSString *)bmStringByDecodingURLFormat;

/**
 * Reverse encodes percentage encoding and optionally replaces '+' characters with spaces.
 */
- (nullable NSString *)bmStringByDecodingURLFormatIncludingPlusSigns:(BOOL)replacePlusSigns;

/**
 Returns the string by making the first character lowercase
 */
- (NSString*)bmStringWithLowercaseFirstChar;

/**
 Returns the string by making the first character uppercase
 */
- (NSString*)bmStringWithUppercaseFirstChar;

/**
 Removes all characters from the specified set, with the specified string comparison options
 */
- (NSString *)bmStringByRemovingCharactersInSet:(NSCharacterSet *)charSet
                                        options:(NSStringCompareOptions)mask;
/**
 Removes all characters from the specified set, default options
 */
- (NSString *)bmStringByRemovingCharactersInSet:(NSCharacterSet *)charSet;

/**
 String by removing all occurences of the specified character
 */
- (NSString *)bmStringByRemovingCharacter:(unichar)character;

/**
 String by decoding entities in the form &xxx; 
 */
- (NSString *)bmStringByDecodingEntities;

/**
 String by encoding entities in the form &xxx;
 Calls [NSString bmStringByEncodingEntities:] with isUnicode=NO.
 
 @see bmStringByEncodingEntities:
 */
- (NSString *)bmStringByEncodingEntities;

/**
 String by encoding entities in the form &xxx;
 
 If isUnicode == YES the unicode entity table is used, otherwise the ascii entity table is used.
 */
- (NSString *)bmStringByEncodingEntities:(BOOL)isUnicode;

/**
 Returns a new string by replacing the characters in the specified set with the specified string.
 */
- (NSString *)bmStringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;

/**
 Returns a new string by retaining only the characters in the specified set.
 */
- (NSString *)bmStringByRetainingCharactersInSet:(NSCharacterSet *)charSet;

/**
 * Returns a new string with all the characters after the last occurrence of the specified string.
 * If the searchString is not found, the receiver is returned unmodified.
 */
- (NSString *)bmStringByCroppingUptoLastOccurenceOfString:(NSString *)searchString;



@end


@interface NSMutableString(BMCommons)

/**
 Replaces all occurences of the specified string with the replacement string
 */
- (NSUInteger)bmReplaceAllOccurrencesOfString:(NSString *)searchString withString:(NSString *)replaceString;

/**
 Replaces the characters in the specified set with the specified string.
 */
- (void)bmReplaceCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
