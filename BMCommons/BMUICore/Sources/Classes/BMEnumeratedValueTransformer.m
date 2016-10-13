//
//  BMEnumeratedValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMEnumeratedValueTransformer.h"
#import "BMEnumeratedValue.h"

@implementation BMEnumeratedValueTransformer

+ (Class)transformedValueClass {
	return [BMEnumeratedValueTransformer class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
    BMEnumeratedValue *enumValue = [BMEnumeratedValue enumeratedValueWithValue:value];
    return enumValue;
}

- (id)reverseTransformedValue:(id)value {
    BMEnumeratedValue *enumValue = value;
    return enumValue.value;
}

@end
