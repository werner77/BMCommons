//
//  BMStringToDateValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/18/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMStringToDateValueTransformer.h>
#import "NSDateFormatter+BMCommons.h"
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCore.h>

@implementation BMStringToDateValueTransformer  {
}

@synthesize dateFormatter = _dateFormatter;

+ (Class)transformedValueClass {
	return [NSDate class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

#define ISO_DATE_FORMAT @"yyyy-MM-dd"

+ (BMStringToDateValueTransformer *)isoStringToDateValueTransformer {
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateFormat = ISO_DATE_FORMAT;
    return [[BMStringToDateValueTransformer alloc] initWithDateFormatter:fm];
}

- (id)init {
	return [self initWithDateFormatter:[NSDateFormatter new]];
}

- (id)initWithDateFormatter:(NSDateFormatter *)theDateFormatter {
	if ((self = [super init])) {
		_dateFormatter = theDateFormatter;
		if (!theDateFormatter) {
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(_dateFormatter);
}

- (id)transformedValue:(id)value {
	return [BMStringHelper isEmpty:value] ? nil : [_dateFormatter bmDateByParsingFromString:value];
}

- (id)reverseTransformedValue:(id)value {
	return value ? [_dateFormatter stringFromDate:value] : nil;
}

@end
