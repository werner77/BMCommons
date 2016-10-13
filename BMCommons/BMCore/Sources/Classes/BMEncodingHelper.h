//
//  BMEncodingHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 Helper methods for converting data to NSString using various encoding methods.
 */
@interface BMEncodingHelper : BMCoreObject

/**
 Converts a BASE-64 encoded string to data. Standard (non-url friendly) encoding is assumed.
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

/**
 Converts a BASE-64 encoded string to data. If urlFriendly is set to true a modified base64 charset is used with only URL supported characters.
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string urlFriendly:(BOOL)urlFriendly;

/**
 Decodes BASE-64 encoded data. Standard (non-url friendly) encoding is assumed.
 */
+ (NSData *)dataWithBase64EncodedData:(NSData *)data;

/**
 Decodes BASE-64 encoded data. If urlFriendly is set to true a modified base64 charset is used with only URL supported characters.
 */
+ (NSData *)dataWithBase64EncodedData:(NSData *)data urlFriendly:(BOOL)urlFriendly;

/**
 Converts data to a BASE-64 encoded string using unlimited line length and standard (non-url friendly) encoding.
 */
+ (NSString *)base64EncodedStringForData:(NSData *)data;

/**
 Converts data to a BASE-64 encoded string using the specified line length and standard (non-url friendly) encoding.
 */
+ (NSString *)base64EncodedStringForData:(NSData *)data withLineLength:(NSUInteger)lineLength;

/**
 Converts data to a BASE-64 encoded string using the specified line length and optional url-friendly encoding.
 */
+ (NSString *)base64EncodedStringForData:(NSData *)data withLineLength:(NSUInteger)lineLength urlFriendly:(BOOL)urlFriendly;

/**
 Converts data to BASE-64 encoded data using unlimited line length and non url-friendly encoding.
 */
+ (NSData *)base64EncodedDataForData:(NSData *)data;

/**
 Converts data to BASE-64 encoded data using the specified line length and non url-friendly encoding.
 */
+ (NSData *)base64EncodedDataForData:(NSData *)data withLineLength:(NSUInteger)lineLength;

/**
 Converts data to BASE-64 encoded data using the specified line length and optional url-friendly encoding.
 */
+ (NSData *)base64EncodedDataForData:(NSData *)data withLineLength:(NSUInteger)lineLength urlFriendly:(BOOL)urlFriendly;

/**
 Converts a byte array to a hex encoded string where each byte in the array is represented by the string representing of it's hexadecimal representation, e.g. @"FF" for 11111111.
 */
+ (NSString *)hexEncodedStringForBytes:(unsigned char *)bytes length:(NSUInteger)length;

/**
 Converts data to a hex encoded byte array.
 */
+ (NSString *)hexEncodedStringForData:(NSData *)data;

@end
