//
//  BMEnumeratedValue.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEnumerationValue.h>
#import "NSNumber+BMCommons.h"
#import <BMCommons/BMRestKit.h>

@implementation BMEnumerationValue {
@private
	id _value;
}

@synthesize value = _value;

+ (BMEnumerationValue *)enumerationValueWithValue:(id)theValue {
	BMEnumerationValue *ret = [BMEnumerationValue new];
	ret.value = theValue;
	return ret;
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}


- (NSString *)formattedValue {
	id theValue = _value;
	if ([_value isKindOfClass:[NSString class]]) {
		NSString *valueString = _value;
        NSArray *components = [valueString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t+=_-{[}]|\\\"':;?/>.<,±§!@#$%^&*~`"]];
		NSMutableString *s = [NSMutableString stringWithCapacity:valueString.length];
        BOOL first = YES;
		for (NSString *component in components) {
            if (!first) {
                [s appendString:@"_"];
            } else {
                first = NO;
            }
			[s appendString:[component capitalizedString]];
		}
		theValue = s;
	}
	return [theValue description];
}

- (NSString *)valueDeclaration {
	NSString *ret = nil;
	if ([_value isKindOfClass:[NSNumber class]]) {
		NSNumber *n = _value;
        ret = [NSString stringWithFormat:@"@(%@)", [n stringValue]];
	} else if (_value) {
		ret = [NSString stringWithFormat:@"@\"%@\"", [_value description]];
	}
	return ret;
}

- (NSString *)swiftValueDeclaration {
    NSString *ret = nil;
    if ([_value isKindOfClass:[NSNumber class]]) {
        NSNumber *n = _value;
        ret = [n stringValue];
    } else if (_value) {
        ret = [NSString stringWithFormat:@"\"%@\"", [_value description]];
    }
    return ret;
}

- (BOOL)isEqual:(id)other {
	if (![other isKindOfClass:[self class]]) {
		return NO;
	}
	
	BMEnumerationValue *otherValue = other;
	return self.value == otherValue.value || [self.value isEqual:otherValue.value];
}

- (NSUInteger)hash {
	return [self.value hash];
}

@end
