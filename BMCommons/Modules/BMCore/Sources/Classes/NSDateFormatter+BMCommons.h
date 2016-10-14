//
//  NSDateFormatter+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 19/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDateFormatter(BMCommons)

/**
 Returns a date by intelligently parsing the string up to the point where it can be parsed. 
 
 Returns nil if unsuccessful.
 
 This method is preferable over dateFromString, see: http://stackoverflow.com/questions/3094819/nsdateformatter-returning-nil-in-os-4-0
 */
- (NSDate *)bmDateByParsingFromString:(NSString *)dateString;

@end
