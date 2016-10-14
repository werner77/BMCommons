//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMAttributedStringDescriptor : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;

+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont;
+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont range:(NSRange)range;
+ (instancetype)attributedStringDescriptorWithColor:(UIColor *)textColor font:(UIFont *)textFont paragraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

- (NSDictionary *)attributes;
- (void)applyToString:(NSMutableAttributedString *)string;

@end