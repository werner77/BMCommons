//
//  BMStringToBooleanValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMStringToBooleanValueTransformer.h>
#import <BMCommons/BMStringHelper.h>

@implementation BMStringToBooleanValueTransformer

+ (Class)transformedValueClass {
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	return [BMStringHelper isEmpty:value] ? nil : [NSNumber numberWithBool:[[value description] boolValue]];
}

- (id)reverseTransformedValue:(id)value {
	return value == nil ? nil : [(NSNumber *)value stringValue];
}

@end
