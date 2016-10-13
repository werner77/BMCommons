//
//  StringHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/09/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import "BMStringHelper.h"
#import <BMCore/NSString+BMCommons.h>
#import <BMCore/BMOrderedDictionary.h>
#import <BMCore/BMEncodingHelper.h>

@implementation BMStringHelper

+ (BOOL)isEmpty:(NSString *)string {
	return string == nil || [string isEqual:@""];
}

+ (NSString *)getSubStringFromString:(NSString *)string beginMarker:(NSString *)beginMarker endMarker:(NSString *)endMarker {
	NSRange range = [string rangeOfString:beginMarker];
	NSString *ret = nil;
	
	if (range.location != NSNotFound) {
		NSUInteger start = range.location + range.length;
		range = [string rangeOfString:endMarker options:NSLiteralSearch range:NSMakeRange(start, string.length - start)];
		if (range.location != NSNotFound) {
			NSUInteger end = range.location;
			range.location = start;
			range.length = end - start;
			ret = [string substringWithRange:range];
		}
	} 
	return ret;
}


+ (NSComparisonResult)numericPatternCompareString:(NSString *)s1 withString:(NSString *)s2 usingPattern:(NSString *)thePattern {
	NSString *fileName1 = (NSString *)s1;
	NSString *fileName2 = (NSString *)s2;
	NSInteger v1 = 0;
	NSInteger v2 = 0;
	const char *pattern = [thePattern cStringUsingEncoding:NSUTF8StringEncoding];
	
	sscanf([fileName1 cStringUsingEncoding:NSUTF8StringEncoding], pattern, &v1);
	sscanf([fileName2 cStringUsingEncoding:NSUTF8StringEncoding], pattern, &v2);
	
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

+ (NSString *)filterNilString:(NSString *)s {
	return s ? s : @"";
}

+ (NSString *)filterEmptyString:(NSString *)s {
    return [@"" isEqual:s] ? nil : s; 
}

+ (NSString*) stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
										  //get the string representation of the UUID
	NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	CFRelease(uuidObj);
	return uuidString;
}

+ (NSString *)stringRepresentationOfData:(NSData *)data	{
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}	  

+ (NSData *)dataRepresentationOfString:(NSString *)string {
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)urlStringFromString:(NSString *)s {
    if (!s) return nil;
    
    NSRange range = [s rangeOfString:@"?"];
    NSString *baseUrlString = s;
    NSString *escapedParameterString = nil;
        
    if (range.location != NSNotFound) {
        baseUrlString = [s substringToIndex:range.location];
        NSString *parameterString = [s substringFromIndex:range.location + 1];
        NSDictionary *parameters = [self parametersFromQueryString:parameterString decodePlusSignsAsSpace:NO];
        escapedParameterString = [self queryStringFromParameters:parameters];
    }

    NSString *escapedBaseUrlString = [[baseUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (escapedParameterString.length > 0) {
        s = [escapedBaseUrlString stringByAppendingString:escapedParameterString];
    } else {
        s = escapedBaseUrlString;
    }
    return s;
}

+ (NSURL *)urlFromString:(NSString *)s {
	s = [self urlStringFromString:s];
	return s ? [NSURL URLWithString:s] : nil;
}

+ (NSString *)decimalStringFromDouble:(double)d {
	// convert the double to an NSNumber
	NSNumber *number = [NSNumber numberWithDouble: d];
	
	// create a number formatter object
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle: NSNumberFormatterDecimalStyle];
	
	// convert the number to a string
	NSString *string = [formatter stringFromNumber: number];
	
	// release just the formatter (the number will be release in the autorelease pool)
	
	// return the string
	return string;
}

+ (NSString *)currencyStringFromDouble:(double)d {
	return [self currencyStringFromDouble:d withCurrencyCode:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]];
}

+ (NSString *)currencyStringFromDouble:(double)d withCurrencyCode:(NSString *)currencyCode {
	// convert the double to an NSNumber
	NSNumber *number = [NSNumber numberWithDouble: d];
	
	// create a number formatter object
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	
	[formatter setCurrencyCode:currencyCode];
	
	// convert the number to a string
	NSString *string = [formatter stringFromNumber: number];
	
	// release just the formatter (the number will be release in the autorelease pool)
	
	// return the string
	return string;
}

+ (NSString *)stringByConvertingFirstCharToLowercase:(NSString *)s {

	NSString *ret = s;

	if (s.length > 0) {
		NSString *firstChar = [s substringWithRange:NSMakeRange(0,1)];
		ret = [firstChar lowercaseString];
		if (s.length > 1) {
			ret = [ret stringByAppendingString:[s substringFromIndex:1]];
		}
	}
	return ret;
}

+ (NSString *)stringByConvertingFirstCharToUppercase:(NSString *)s {
    NSString *ret = s;
    
    if (s.length > 0) {
        NSString *firstChar = [s substringWithRange:NSMakeRange(0,1)];
        ret = [firstChar uppercaseString];
        if (s.length > 1) {
            ret = [ret stringByAppendingString:[s substringFromIndex:1]];
        }
    }
    return ret;
}

+ (NSURL *)urlFromFilePath:(NSString *)filePath {
    return filePath ? [NSURL fileURLWithPath:filePath] : nil;
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)query {
    return [self parametersFromQueryString:query decodePlusSignsAsSpace:YES];
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)query decodePlusSignsAsSpace:(BOOL)decodePlusSigns {
    NSMutableDictionary *ret = [BMOrderedDictionary dictionary];
    NSArray	*tuples = [query componentsSeparatedByString: @"&"];
	for (NSString *tuple in tuples) {
        NSRange range = [tuple rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *key = [[tuple substringToIndex:range.location] bmStringByDecodingURLFormatIncludingPlusSigns:decodePlusSigns];
            NSString *value = [[tuple substringFromIndex:range.location + 1] bmStringByDecodingURLFormatIncludingPlusSigns:decodePlusSigns];
            if (value) {
                id existingValue = [ret objectForKey:key];
                if (existingValue == nil) {
                    [ret setObject:value forKey:key];
                } else {
                    if ([existingValue isKindOfClass:[NSMutableArray class]]) {
                        [(NSMutableArray *)existingValue addObject:value];
                    } else {
                        NSMutableArray *array = [NSMutableArray array];
                        [array addObject:existingValue];
                        [array addObject:value];
                        [ret setObject:array forKey:key];
                    }
                }
            }
        }
	}
    return ret;
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters includeQuestionMark:(BOOL)includeQuestionMark {
    return [self queryStringFromParameters:parameters includeQuestionMark:includeQuestionMark useBase64Encoding:NO];
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters includeQuestionMark:(BOOL)includeQuestionMark useBase64Encoding:(BOOL)useBase64Encoding {
    if (parameters == nil) return nil;
    
    NSMutableString *ret = [NSMutableString string];
    for (NSString *parameterName in parameters) {
        id parameterValue = [parameters objectForKey:parameterName];
        
        if (parameterValue) {
            NSArray *parameterValueArray = nil;
            if ([parameterValue isKindOfClass:[NSArray class]]) {
                parameterValueArray = parameterValue;
            } else {
                parameterValueArray = [NSArray arrayWithObject:parameterValue];
            }
            
            for (id p in parameterValueArray) {
                NSString *parameterValueString;
                if ([p isKindOfClass:[NSData class]]) {
                    if (useBase64Encoding) {
                        parameterValueString = [BMEncodingHelper base64EncodedStringForData:p];
                    } else {
                        parameterValueString = [[NSString alloc] initWithData:p encoding:NSUTF8StringEncoding];
                    }
                } else {
                    parameterValueString = [p description];
                }
                if (ret.length == 0) {
                    if (includeQuestionMark) {
                        [ret appendString:@"?"];
                    }
                } else {
                    [ret appendString:@"&"];
                }
                NSString *escapedParameterValue = [parameterValueString bmStringWithPercentEscapes];
                [ret appendFormat:@"%@=%@", parameterName, escapedParameterValue];
            }
        }
        
    }
    return ret;
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    return [self queryStringFromParameters:parameters includeQuestionMark:YES];
}

@end
