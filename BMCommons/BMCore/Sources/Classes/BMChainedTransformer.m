//
//  BMChainedTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 06/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMChainedTransformer.h"

@implementation BMChainedTransformer

+ (instancetype)transformerWithChain:(NSArray *)transformerChain {
    BMChainedTransformer *ret = [self new];
    ret.transformerChain = transformerChain;
    return ret;
}

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    id convertedValue = value;
    for (NSValueTransformer *tranformer in self.transformerChain) {
        convertedValue = [tranformer transformedValue:convertedValue];
    }
    return convertedValue;
}

- (id)reverseTransformedValue:(id)value {
    id convertedValue = value;
    for (NSInteger i = self.transformerChain.count - 1; i >= 0; --i) {
        NSValueTransformer *transformer = [self.transformerChain objectAtIndex:i];
        convertedValue = [transformer reverseTransformedValue:convertedValue];
    }
    return convertedValue;
}

@end
