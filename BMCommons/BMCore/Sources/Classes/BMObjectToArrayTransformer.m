//
//  BMObjectToArrayTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/11/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectToArrayTransformer.h>

@implementation BMObjectToArrayTransformer

+ (Class)transformedValueClass {
	return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSArray class]]) {
        return value;
    } else if (value == nil) {
        return nil;
    } else {
        return @[value];
    }
}

@end
