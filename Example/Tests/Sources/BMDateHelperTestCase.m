//
//  BMDateHelperTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMDateHelperTestCase.h"
#import <BMCommons/BMDateHelper.h>

@implementation BMDateHelperTestCase

- (void)testTimezoneCorrection {
	
	NSDateFormatter *df = [BMDateHelper standardTimestampFormatter];
	
	//@"yyyy-MM-dd HH:mm:ss"
	
	//28th of march is a date when DST starts in Europe
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Europe/Brussels"];
	
	
	NSDate *theDate = [df dateFromString:@"2010-03-28 01:59:59"];
	NSDate *correctedDate = [BMDateHelper utcDateFromLocalDate:theDate withTimeZone:timeZone];
	NSString *correctedDateString = [df stringFromDate:correctedDate];
	
	XCTAssertTrue([@"2010-03-28 00:59:59" isEqual:correctedDateString], @"Date correction is not as expected");
	
	theDate = [df dateFromString:@"2010-03-28 02:00:00"];
	correctedDate = [BMDateHelper utcDateFromLocalDate:theDate withTimeZone:timeZone];
	correctedDateString = [df stringFromDate:correctedDate];
	
	XCTAssertTrue([@"2010-03-28 01:00:00" isEqual:correctedDateString], @"Date correction is not as expected");
	
	theDate = [df dateFromString:@"2010-03-28 03:00:00"];
	correctedDate = [BMDateHelper utcDateFromLocalDate:theDate withTimeZone:timeZone];
	correctedDateString = [df stringFromDate:correctedDate];
	
	XCTAssertTrue([@"2010-03-28 01:00:00" isEqual:correctedDateString], @"Date correction is not as expected");
}

@end
