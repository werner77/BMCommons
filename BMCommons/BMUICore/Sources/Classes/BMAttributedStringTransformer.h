//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Value transformer for transforming a NSString to an NSAttributedString using the specified font, text color and paragraphstyle.
 */
@interface BMAttributedStringTransformer : NSValueTransformer

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;

@end