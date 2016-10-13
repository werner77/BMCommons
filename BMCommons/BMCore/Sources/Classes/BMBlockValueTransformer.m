//
//  BMBlockValueTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMBlockValueTransformer.h"

@implementation BMBlockValueTransformer

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (instancetype)valueTransformerWithTransformationBlock:(BMValueTransformerBlock)transformBlock {
    return [self valueTransformerWithTransformationBlock:transformBlock reverseTransformationBlock:nil];
}

+ (instancetype)valueTransformerWithTransformationBlock:(BMValueTransformerBlock)transformBlock reverseTransformationBlock:(BMValueTransformerBlock)reverseBlock {
    return [[self alloc] initWithTransformationBlock:transformBlock reverseTransformationBlock:reverseBlock];
}

- (id)initWithTransformationBlock:(BMValueTransformerBlock)transformBlock reverseTransformationBlock:(BMValueTransformerBlock)reverseBlock {
    if ((self = [super init])) {
        self.transformationBlock = transformBlock;
        self.reverseTransformationBlock = reverseBlock;
    }
    return self;
}

- (id)transformedValue:(id)value {
    id transformedValue = value;
    if (self.transformationBlock != nil) {
        transformedValue = self.transformationBlock(value);
    }
    return transformedValue;
}

- (id)reverseTransformedValue:(id)value {
    id transformedValue = value;
    if (self.reverseTransformationBlock != nil) {
        transformedValue = self.reverseTransformationBlock(value);
    }
    return transformedValue;
}

@end
