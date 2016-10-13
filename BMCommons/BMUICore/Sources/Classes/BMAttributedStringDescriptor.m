//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMAttributedStringDescriptor.h"
#import "NSDictionary+BMCommons.h"

@implementation BMAttributedStringDescriptor

+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont {
    BMAttributedStringDescriptor *descriptor = [self new];
    descriptor.color = textColor;
    descriptor.font = textFont;
    return descriptor;
}

+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont range:(NSRange)range {
    BMAttributedStringDescriptor *descriptor = [self attributedStringDescriptorWithColor:textColor font:textFont];
    descriptor.range = range;
    return descriptor;
}

+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont paragraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    BMAttributedStringDescriptor *descriptor = [self attributedStringDescriptorWithColor:textColor font:textFont];
    descriptor.range = range;
    descriptor.paragraphStyle = paragraphStyle;
    return descriptor;
}

- (id)init {
    if ((self = [super init])) {
        self.range = NSMakeRange(0, NSUIntegerMax);
    }
    return self;
}

- (NSDictionary *)attributes {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes bmSafeSetObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes bmSafeSetObject:self.font forKey:NSFontAttributeName];
    [attributes bmSafeSetObject:self.color forKey:NSForegroundColorAttributeName];
    return attributes;
}

- (void)applyToString:(NSMutableAttributedString *)string {
    NSRange effectiveRange = self.range;

    effectiveRange.location = MIN(effectiveRange.location, string.length);
    effectiveRange.length = MIN(effectiveRange.length, string.length - effectiveRange.location);
    [string setAttributes:self.attributes range:effectiveRange];
}

@end