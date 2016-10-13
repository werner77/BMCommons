//
//  BMNumberHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 27/08/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMNumberHelper.h"

@implementation BMNumberHelper

+ (NSNumber *)intNumberForString:(NSString *)s {
	if (s == nil) return nil;
	return [NSNumber numberWithLongLong:[s longLongValue]];
}

+ (NSNumber *)doubleNumberForString:(NSString *)s {
	if (s == nil) return nil;
	return [NSNumber numberWithDouble:[s doubleValue]];
}

+ (NSNumber *)boolNumberForString:(NSString *)s {
	if (s == nil) return nil;
	return [NSNumber numberWithBool:[s boolValue]];
}

+ (NSString *)priceStringForNumber:(NSNumber *)number withLocale:(NSLocale *)locale {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:locale];
	return [numberFormatter stringFromNumber:number];	
}

+ (BOOL)isPow2:(NSUInteger)i {
	while (i > 1) {
		if (i % 2 == 0) {
			//OK
			i >>= 1;
		} else {
			return NO;
		}
	}	
	return YES;
}

@end
