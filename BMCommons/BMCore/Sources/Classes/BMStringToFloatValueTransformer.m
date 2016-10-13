//
//  BMStringToFloatValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMStringToFloatValueTransformer.h"
#import "NSNumber+BMCommons.h"
#import "BMStringHelper.h"

@implementation BMStringToFloatValueTransformer

+ (Class)transformedValueClass {
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	return [BMStringHelper isEmpty:value] ? nil : [NSNumber numberWithFloat:[[value description] floatValue]];
}

- (id)reverseTransformedValue:(id)value {
	return [(NSNumber *)value stringValue];
}

@end
