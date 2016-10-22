//
// Created by Werner Altewischer on 05/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSString+BMUICore.h"
#import "NSDictionary+BMCommons.h"
#import <BMCommons/BMCore.h>

@implementation NSString (BMUICore)

- (CGSize)bmSizeWithFont:(UIFont *)font {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes bmSafeSetObject:font forKey:NSFontAttributeName];
    return [self sizeWithAttributes:attributes];
}

- (CGSize)bmSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self bmSizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)bmSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes bmSafeSetObject:font forKey:NSFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    [attributes bmSafeSetObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    return [self bmSizeWithAttributes:attributes constrainedToSize:size];
}

- (CGSize)bmSizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [self bmSizeWithFont:font constrainedToSize:CGSizeMake(width, font.lineHeight) lineBreakMode:lineBreakMode];
}

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           textColor:(UIColor *)textColor
              shadow:(NSShadow *)shadow
          actualSize:(CGSize *)actualSize {
    [self bmDrawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:NSTextAlignmentLeft textColor:textColor shadow:shadow actualSize:actualSize];
}

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)textAlignment
          actualSize:(CGSize *)actualSize {
    [self bmDrawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:textAlignment textColor:nil shadow:nil actualSize:actualSize];
}

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)textAlignment
           textColor:(UIColor *)textColor
              shadow:(NSShadow *)shadow
            actualSize:(CGSize *)actualSize {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    
    [attributes bmSafeSetObject:font forKey:NSFontAttributeName];
    [attributes bmSafeSetObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes bmSafeSetObject:textColor forKey:NSForegroundColorAttributeName];
    [attributes bmSafeSetObject:textColor forKey:NSStrokeColorAttributeName];
    [attributes bmSafeSetObject:shadow forKey:NSShadowAttributeName];
    
    // Make an integral frame, otherwise on iOS 8.3 and below, some texts are cut off after first character
    rect = CGRectIntegral(rect);
    
    [self drawInRect:rect withAttributes:attributes];
    
    if (actualSize) {
        *actualSize = [self bmSizeWithAttributes:attributes constrainedToSize:rect.size];
    }
}

- (void)bmDrawAtPoint:(CGPoint)point withFont:(UIFont *)font textColor:(UIColor *)textColor shadow:(NSShadow *)shadow actualSize:(CGSize *)actualSize {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes bmSafeSetObject:font forKey:NSFontAttributeName];
    [attributes bmSafeSetObject:textColor forKey:NSForegroundColorAttributeName];
    [attributes bmSafeSetObject:textColor forKey:NSStrokeColorAttributeName];
    [attributes bmSafeSetObject:shadow forKey:NSShadowAttributeName];
    [self drawAtPoint:point withAttributes:attributes];
    
    if (actualSize) {
        *actualSize = [self bmSizeWithAttributes:attributes constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    }
}

- (CGSize)bmSizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)constraintSize {
    CGRect textRect = [self boundingRectWithSize:constraintSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    textRect = CGRectIntegral(textRect);
    return textRect.size;
}

- (void)bmDrawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode actualSize:(CGSize *)actualSize {
    CGRect rect = CGRectMake(point.x, point.y, width, font.lineHeight);
    [self bmDrawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:NSTextAlignmentLeft actualSize:actualSize];
}

@end
