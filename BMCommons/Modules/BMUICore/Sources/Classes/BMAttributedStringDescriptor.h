//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAttributedStringDescriptor : NSObject

@property (nonatomic, assign) NSRange range;
@property (nullable, nonatomic, strong) UIColor *color;
@property (nullable, nonatomic, strong) UIFont *font;
@property (nullable, nonatomic, strong) NSParagraphStyle *paragraphStyle;

+ (instancetype)attributedStringDescriptorWithColor:(nullable UIColor *)textColor font:(nullable UIFont *)textFont;
+ (instancetype)attributedStringDescriptorWithColor:(nullable UIColor *)textColor font:(nullable UIFont *)textFont range:(NSRange)range;
+ (instancetype)attributedStringDescriptorWithColor:(nullable UIColor *)textColor font:(nullable UIFont *)textFont paragraphStyle:(nullable NSParagraphStyle *)paragraphStyle range:(NSRange)range;

- (NSDictionary *)attributes;
- (void)applyToString:(NSMutableAttributedString *)string;

@end

NS_ASSUME_NONNULL_END