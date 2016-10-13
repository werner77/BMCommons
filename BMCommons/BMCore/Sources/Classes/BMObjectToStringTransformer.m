//
//  BMObjectToStringTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 04/11/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import "BMObjectToStringTransformer.h"

@implementation BMObjectToStringTransformer 

@synthesize propertyDescriptor = _propertyDescriptor;


- (id)initWithPropertyDescriptor:(BMPropertyDescriptor *)thePropertyDescriptor {
    if ((self = [self init])) {
        self.propertyDescriptor = thePropertyDescriptor;
    }
    return self;
}

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (BMObjectToStringTransformer *)transformerWithPropertyDescriptor:(BMPropertyDescriptor *)descriptor {
    BMObjectToStringTransformer *transformer = [[BMObjectToStringTransformer alloc] initWithPropertyDescriptor:descriptor];
    return transformer;
}

- (id)transformedValue:(id)value {
    return self.propertyDescriptor ? [self.propertyDescriptor callGetterOnTarget:value] : [value description];
}

- (id)reverseTransformedValue:(id)value {
	return nil;
}

@end
