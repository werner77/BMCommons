//
//  NSNumber+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSNumber additions.
 */
@interface NSNumber(BMCommons)

/**
 Returns a number by parsing the specified string. 
 
 Depending on the string a boolean, float or int number may be returned.
 */
+ (nullable NSNumber *)bmNumberWithString:(NSString *)stringValue;

/**
 Returns YES iff this is boolean number.
 */
- (BOOL)bmIsBoolNumber;

/**
 Returns YES iff this is a float number.
 */
- (BOOL)bmIsFloatNumber;

/**
 Returns YES iff this is an int number.
 */
- (BOOL)bmIsIntNumber;

/**
 Returns "true" iff [self boolValue] == YES, "false" otherwise.
 */
- (NSString *)bmBoolStringValue;

@end

NS_ASSUME_NONNULL_END
