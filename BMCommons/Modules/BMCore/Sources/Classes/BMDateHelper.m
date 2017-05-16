//
//  BMDateHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/28/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMDateHelper.h>
#import "NSDateFormatter+BMCommons.h"
#import "BMCore.h"
#import <BMCommons/BMProxy.h>
#import <BMCommons/BMImmutableProxy.h>

static NSDateFormatter *rfc3339TimestampFormatter;
static NSDateFormatter *rfc3339TimestampFractionalFormatter;
static NSDateFormatter *rfc3339TimestampFormatterWithTimeZone;
static NSDateFormatter *rfc3339TimestampFractionalFormatterWithTimeZone;
static NSDateFormatter *rfc3339DateFormatter;
static NSDateFormatter *rfc3339DateFormatterWithTimeZone;
static NSDateFormatter *standardTimestampFormatter;
static NSDateFormatter *standardDateFormatter;
static NSDateFormatter *defaultDateFormatter = nil;
static NSDateFormatter *rfc1123DateFormatter = nil;

@implementation BMDateHelper

+ (void)initialize {
    if (!defaultDateFormatter) {
        [self setDefaultDateFormatter:[self rfc3339TimestampFractionalFormatterWithTimeZone]];
    }
}

+ (NSDateFormatter *)defaultDateFormatter {
    return defaultDateFormatter;
}

+ (void)setDefaultDateFormatter:(NSDateFormatter *)formatter {
    if (defaultDateFormatter != formatter) {
        defaultDateFormatter = nil;
        
        if (formatter) {
            if ([formatter isKindOfClass:[BMImmutableProxy class]]) {
                ((BMImmutableProxy *)formatter).threadSafe = YES;
            } else {
                formatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:formatter threadSafe:YES];
            }
            defaultDateFormatter = formatter;
        }
    }
}

+ (NSDateFormatter *)rfc3339TimestampFormatter {
	@synchronized([BMDateHelper class]) {
		if (rfc3339TimestampFormatter == nil) {
            rfc3339TimestampFormatter = [[NSDateFormatter alloc] init];
			[rfc3339TimestampFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];			
			[rfc3339TimestampFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			[rfc3339TimestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            rfc3339TimestampFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339TimestampFormatter threadSafe:YES];
		}
	}
	return rfc3339TimestampFormatter;
}

+ (NSDateFormatter *)rfc3339TimestampFractionalFormatter {
	@synchronized([BMDateHelper class]) {
		if (rfc3339TimestampFractionalFormatter == nil) {
            rfc3339TimestampFractionalFormatter = [[NSDateFormatter alloc] init];
			[rfc3339TimestampFractionalFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[rfc3339TimestampFractionalFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
			[rfc3339TimestampFractionalFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            rfc3339TimestampFractionalFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339TimestampFractionalFormatter threadSafe:YES];
		}
	}
	return rfc3339TimestampFractionalFormatter;
}

+ (NSDateFormatter *)rfc3339TimestampFractionalFormatterWithTimeZone {
	@synchronized([BMDateHelper class]) {
		if (rfc3339TimestampFractionalFormatterWithTimeZone == nil) {
            rfc3339TimestampFractionalFormatterWithTimeZone = [[NSDateFormatter alloc] init];
			[rfc3339TimestampFractionalFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[rfc3339TimestampFractionalFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            rfc3339TimestampFractionalFormatterWithTimeZone = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339TimestampFractionalFormatterWithTimeZone threadSafe:YES];
		}
	}
	return rfc3339TimestampFractionalFormatterWithTimeZone;
}

+ (NSDateFormatter *)rfc3339TimestampFormatterWithTimeZone {
	@synchronized([BMDateHelper class]) {
		if (rfc3339TimestampFormatterWithTimeZone == nil) {
			rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
			[rfc3339TimestampFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            rfc3339TimestampFormatterWithTimeZone = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339TimestampFormatterWithTimeZone threadSafe:YES];
		}
	}
	return rfc3339TimestampFormatterWithTimeZone;
}

+ (NSDateFormatter *)rfc3339DateFormatter {
	@synchronized([BMDateHelper class]) {
		if (rfc3339DateFormatter == nil) {
			rfc3339DateFormatter = [[NSDateFormatter alloc] init];
			[rfc3339DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[rfc3339DateFormatter setDateFormat:@"yyyy-MM-dd'Z'"];
            rfc3339DateFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339DateFormatter threadSafe:YES];
		}
	}
	return rfc3339DateFormatter;
}

+ (NSDateFormatter *)rfc3339DateFormatterWithTimeZone {
	@synchronized([BMDateHelper class]) {
		if (rfc3339DateFormatterWithTimeZone == nil) {
			rfc3339DateFormatterWithTimeZone = [[NSDateFormatter alloc] init];
			[rfc3339DateFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[rfc3339DateFormatterWithTimeZone setDateFormat:@"yyyy-MM-ddZ"];
            rfc3339DateFormatterWithTimeZone = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc3339DateFormatterWithTimeZone threadSafe:YES];
		}
	}
	return rfc3339DateFormatterWithTimeZone;
}


+(NSDate*)dateFromRFC1123:(NSString*)value_
{
    if(value_ == nil)
        return nil;
    static NSDateFormatter *rfc1123 = nil;
    if(rfc1123 == nil)
    {
        rfc1123 = [[NSDateFormatter alloc] init];
        rfc1123.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        rfc1123.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        rfc1123.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss z";
    }
    NSDate *ret = [rfc1123 dateFromString:value_];
    if(ret != nil)
        return ret;
    
    static NSDateFormatter *rfc850 = nil;
    if(rfc850 == nil)
    {
        rfc850 = [[NSDateFormatter alloc] init];
        rfc850.locale = rfc1123.locale;
        rfc850.timeZone = rfc1123.timeZone;
        rfc850.dateFormat = @"EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z";
    }
    ret = [rfc850 dateFromString:value_];
    if(ret != nil)
        return ret;
    
    static NSDateFormatter *asctime = nil;
    if(asctime == nil)
    {
        asctime = [[NSDateFormatter alloc] init];
        asctime.locale = rfc1123.locale;
        asctime.timeZone = rfc1123.timeZone;
        asctime.dateFormat = @"EEE MMM d HH':'mm':'ss yyyy";
    }
    return [asctime dateFromString:value_];
}

+ (NSDateFormatter *)rfc1123DateFormatter {
    @synchronized([BMDateHelper class]) {
        if (rfc1123DateFormatter == nil) {
            rfc1123DateFormatter = [[NSDateFormatter alloc] init];
            [rfc1123DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [rfc1123DateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
            rfc1123DateFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:rfc1123DateFormatter threadSafe:YES];
        }
    }
    return rfc1123DateFormatter;
}

+ (NSDateFormatter *)standardTimestampFormatter {
	@synchronized([BMDateHelper class]) {
		if (standardTimestampFormatter == nil) {
			standardTimestampFormatter = [[NSDateFormatter alloc] init];
			[standardTimestampFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[standardTimestampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			[standardTimestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            standardTimestampFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:standardTimestampFormatter threadSafe:YES];
		}
	}
	return standardTimestampFormatter;
}

+ (NSDateFormatter *)utcDateFormatterWithFormat:(NSString *)format {
    return [self dateformatterWithFormat:format andTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

+ (NSDateFormatter *)standardDateFormatter {
	@synchronized([BMDateHelper class]) {
		if (standardDateFormatter == nil) {
			standardDateFormatter = [[NSDateFormatter alloc] init];
			[standardDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
			[standardDateFormatter setDateFormat:@"yyyy-MM-dd"];
			[standardDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            standardDateFormatter = (NSDateFormatter *)[[BMImmutableProxy alloc] initWithObject:standardDateFormatter threadSafe:YES];
		}
	}
	return standardDateFormatter;
}

+ (NSDateFormatter *)dateformatterWithFormat:(NSString *)format andTimeZone:(NSTimeZone *)timeZone {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[df setDateFormat:format];
    if (timeZone) {
        [df setTimeZone:timeZone];
    }
	return (NSDateFormatter *)[[BMProxy alloc] initWithObject:df threadSafe:YES];
}

+ (NSDate *)dateFromRFC3339String:(NSString *)dateString {
	NSRange range = [dateString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
	NSDateFormatter *dateFormatter = nil;
	if (range.location == NSNotFound) {
        
        int timezoneLength = 6;
        BOOL timeZonePresent = NO;
		if (dateString.length >= timezoneLength) {
			range = [dateString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"] 
												options:NSLiteralSearch range:NSMakeRange(dateString.length - timezoneLength, timezoneLength)];
            timeZonePresent = (range.location != NSNotFound);
        }
        
        if ([dateString rangeOfString:@"T"].location == NSNotFound) {
            if (timeZonePresent) {
                dateFormatter = [self rfc3339DateFormatterWithTimeZone];
            } else {
                dateFormatter = [self rfc3339DateFormatter];
            }
        } else {
            if (timeZonePresent) {
                dateFormatter = [self rfc3339TimestampFormatterWithTimeZone];
            } else {
                dateFormatter = [self rfc3339TimestampFormatter]; 
            }
        }
        
		
	} else {
		//Fractional
		dateFormatter = [self rfc3339TimestampFractionalFormatter];
		range = [dateString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"] 
											options:NSLiteralSearch range:NSMakeRange(range.location, dateString.length - range.location)];
		if (range.location != NSNotFound) {
			dateFormatter = [self rfc3339TimestampFractionalFormatterWithTimeZone];			
		}
	}
	
	return [dateFormatter bmDateByParsingFromString:dateString];
}

+ (NSString *)rfc3339StringFromDate:(NSDate *)date {
	return [[self rfc3339TimestampFractionalFormatter] stringFromDate:date];
}

+ (NSDate *)absoluteDateFromDate:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone {
	NSCalendar *localCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[localCalendar setTimeZone:timeZone];
	NSUInteger unitFlags = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
	NSDateComponents *dateComponents = [localCalendar components:unitFlags fromDate:date];
	
	NSCalendar *utcCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[utcCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	NSDate *ret = [utcCalendar dateFromComponents:dateComponents];
	
	
	return ret;
}

+ (NSDate *)addTimeString:(NSString *)timeString withFormat:(NSString *)timeFormat toDate:(NSDate *)theDate withTimeZone:(NSTimeZone *)timeZone {
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	NSString *dateFormat = @"yyyy-MM-dd";
	[formatter setDateFormat:dateFormat];
	
	NSString *dateString = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:theDate], timeString];
	[formatter setDateFormat:[NSString stringWithFormat:@"%@ %@", dateFormat, timeFormat]];
    
    if (!timeZone) {
        timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    }
	
    [formatter setTimeZone:timeZone];
    
	NSDate *ret = [formatter dateFromString:dateString];
	
	
	return ret;
}

+ (NSDate *)utcDateFromLocalDate:(NSDate *)localDate withTimeZone:(NSTimeZone *)timeZone {
	
	NSDate *correctedDate = localDate;
	
	if (timeZone) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		
		[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];

		NSInteger i = 0;
		while (i++ < 2) {
			[df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
			NSString *dateString = [df stringFromDate:localDate];

			[df setTimeZone:timeZone];

			correctedDate = [df dateFromString:dateString];

			if (correctedDate == nil) {
				//correctedDate lies within DST interval: add one hour and try again
				localDate = [[NSDate alloc] initWithTimeInterval:BM_HOUR sinceDate:localDate];
			} else {
				break;
			}
		}
	}
	return correctedDate;
}																																				

@end
