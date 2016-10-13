//
//  BMNumberToStringValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMNumberToStringValueTransformer.h"
#import "NSNumber+BMCommons.h"
#import "BMStringHelper.h"

@implementation BMNumberToStringValueTransformer

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	return [value isKindOfClass:[NSString class]] ? value : [(NSNumber *)value stringValue];
}

- (id)reverseTransformedValue:(id)value {
	return [BMStringHelper isEmpty:value] ? nil : [NSNumber bmNumberWithString:value];
}

@end
