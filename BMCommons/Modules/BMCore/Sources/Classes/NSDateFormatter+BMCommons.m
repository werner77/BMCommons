//
//  NSDateFormatter+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 19/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "NSDateFormatter+BMCommons.h"
#import <BMCommons/BMCore.h>

@implementation NSDateFormatter(BMCommons)

- (NSDate *)bmDateByParsingFromString:(NSString *)dateString {
    NSDate *ret = nil;
	NSError *error = nil;	
	if (dateString == nil || ![self getObjectValue:&ret forString:dateString range:nil error:&error]) {
		LogWarn(@"Date '%@' could not be parsed: %@", dateString, error);
	}
	return ret;
}

@end
