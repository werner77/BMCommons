//
//  BMNumberHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 27/08/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
Helper class for parsing/handling numbers
*/
@interface BMNumberHelper : BMCoreObject {

}

/**
Returns the string parsed as an int number
*/
+ (NSNumber *)intNumberForString:(NSString *)s;

/**
 Returns the string parsed as a double number
 */
+ (NSNumber *)doubleNumberForString:(NSString *)s;

/**
 Returns the string parsed as a boolean number
 */
+ (NSNumber *)boolNumberForString:(NSString *)s;

/**
 Returns a number as a string with the default currency symbol for the specified locale
 */
+ (NSString *)priceStringForNumber:(NSNumber *)number withLocale:(NSLocale *)locale;

/**
 Returns true if and only if the specified integer is expressable as a binary number with at most one bit that is equal to '1': (0, 1, 2, 4, 8, 16, etc)
 */
+ (BOOL)isPow2:(NSUInteger)i;

@end
