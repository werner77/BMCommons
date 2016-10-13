//
//  BMDateHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/28/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 Utility class for working with dates and date formatters. 
 
 Dateformatters are using "UTC" timezone and "en_US_POSIX" locale unless specified otherwise.
 */
@interface BMDateHelper : BMCoreObject {

}

/**
 Immutable Dateformatter for rfc3339 timestamps: yyyy-MM-dd'T'HH:mm:ss'Z'
 */
+ (NSDateFormatter *)rfc3339TimestampFormatter;

/**
 Immutable Dateformatter for rfc3339 fractional timestamps: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
 */
+ (NSDateFormatter *)rfc3339TimestampFractionalFormatter;

/**
 Immutable Dateformatter for rfc3339 fractional timestamps with time zone: yyyy-MM-dd'T'HH:mm:ss.SSSZ
 */
+ (NSDateFormatter *)rfc3339TimestampFractionalFormatterWithTimeZone;

/**
 Immutable dateformatter for dates in the format: yyyy-MM-ddZ
 */
+ (NSDateFormatter *)rfc3339DateFormatterWithTimeZone;

/**
 Immutable dateformatter for dates in the format: yyyy-MM-dd'Z'
 */
+ (NSDateFormatter *)rfc3339DateFormatter;

/**
 Immutable dateformatter for dates in the RFC 1123 format such as used for HTTP headers for example.
 */
+ (NSDateFormatter *)rfc1123DateFormatter;

/**
 Immutable Dateformatter with format: yyyy-MM-dd HH:mm:ss
 */
+ (NSDateFormatter *)standardTimestampFormatter;

/**
 Immutable Dateformatter with format: yyyy-MM-dd
 */
+ (NSDateFormatter *)standardDateFormatter;

/**
 Parses a RFC3339 date from a string. 
 
 Picks the right rfc3339 dateformatter from one of the methods defined in this class depending on the string supplied.
 */
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;

/**
 Returns a date as string by using the rfc3339TimestampFormatter.
 */
+ (NSString *)rfc3339StringFromDate:(NSDate *)date;

/**
 Returns a Dateformatter with the specified date format and time zone.
 */
+ (NSDateFormatter *)dateformatterWithFormat:(NSString *)format andTimeZone:(NSTimeZone *)timeZone;

/**
 Parses time from a string and adds it to the specified date using the specified time zone.
 
 The supplied date is truncated with 00:00 time and the time is parsed from the time string and added to it.
 
 @param timeString The string depicting the time on the day of the date. E.g. 01:14:55
 @param timeFormat The format of the timeString. E.g. HH:mm:ss
 @param date The date to add the time to. The time of the date is ignored.
 @param timeZone The timeZone to use, or nil for UTC timezone.
 @return The resulting date.
 */
+ (NSDate *)addTimeString:(NSString *)timeString withFormat:(NSString *)timeFormat toDate:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone;

/**
 Converts (shifts) a local date to the date it would be in UTC using the specified timezone.
 
 The resulting date is the original date + the offset of timeZone against UTC.
 */
+ (NSDate *)utcDateFromLocalDate:(NSDate *)theDate withTimeZone:(NSTimeZone *)timeZone;

/* *
 Returns a date by ignoring the time zone info. 
 
 The resulting date is in UTC with time 00:00:00. Useful for birthdays, holidays, etc. for which it doesn't make sense to shift by time zone.
 
 @param date The date
 @param timeZone The timezone in which to interpret the date given
 */
+ (NSDate *)absoluteDateFromDate:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone;

/**
 Returns a date formatter in UTC timezone with the specified date format.
 */
+ (NSDateFormatter *)utcDateFormatterWithFormat:(NSString *)format;

/**
 The default date formatter.
 */
+ (NSDateFormatter *)defaultDateFormatter;

/**
 Sets the default date formatter.
 */
+ (void)setDefaultDateFormatter:(NSDateFormatter *)formatter;

@end
