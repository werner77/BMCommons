//
//  NSNumber+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "NSNumber+BMCommons.h"
#import <BMCommons/BMCore.h>

@implementation NSNumber(BMCommons)

+ (NSNumber *)bmNumberWithString:(NSString *)stringValue {
    if (!stringValue) {
        return nil;
    }

    static NSNumberFormatter *nf = nil;

    BM_DISPATCH_ONCE(^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });

    @synchronized (nf) {
        return [nf numberFromString:[stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
}

- (BOOL)bmIsBoolNumber {
	Class boolClass = [[NSNumber numberWithBool:YES] class];
	return [self isKindOfClass:boolClass];
}

- (BOOL)bmIsFloatNumber {
	Class floatClass = [[NSNumber numberWithDouble:1.0] class];
	return [self isKindOfClass:floatClass];
}

- (BOOL)bmIsIntNumber {
	Class intClass = [[NSNumber numberWithInt:1] class];
	return [self isKindOfClass:intClass];
}

- (NSString *)bmBoolStringValue {
    if ([self boolValue]) {
        return @"true";
    } else {
        return @"false";
    }
}

@end
