//
//  BMStringToIntegerValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMStringToIntegerValueTransformer.h"
#import "BMStringHelper.h"

@implementation BMStringToIntegerValueTransformer

+ (Class)transformedValueClass {
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	return [BMStringHelper isEmpty:value] ? nil : [NSNumber numberWithInteger:[[value description] integerValue]];
}

- (id)reverseTransformedValue:(id)value {
	return [(NSNumber *)value stringValue];
}

@end
