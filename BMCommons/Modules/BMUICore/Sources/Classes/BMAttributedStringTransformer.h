//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Value transformer for transforming a NSString to an NSAttributedString using the specified font, text color and paragraphstyle.
 */
@interface BMAttributedStringTransformer : NSValueTransformer

@property (nullable, nonatomic, strong) UIFont *font;
@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nullable, nonatomic, strong) NSParagraphStyle *paragraphStyle;

@end

NS_ASSUME_NONNULL_END