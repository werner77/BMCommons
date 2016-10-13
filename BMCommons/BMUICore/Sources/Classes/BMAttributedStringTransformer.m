//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAttributedStringTransformer.h"
#import "BMAttributedStringDescriptor.h"


@implementation BMAttributedStringTransformer

+ (Class)transformedValueClass {
    return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSString *s = value;
    BMAttributedStringDescriptor *descriptor = [BMAttributedStringDescriptor attributedStringDescriptorWithColor:self.textColor font:self.font paragraphStyle:self.paragraphStyle range:NSMakeRange(0, NSUIntegerMax)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:s];
    [descriptor applyToString:attributedString];
    return attributedString;
}

@end