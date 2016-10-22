//
// Created by Werner Altewischer on 05/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (BMUICore)

/**
 * Size with font method available for iOS >= 7.0
 */
- (CGSize)bmSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constraint lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)bmSizeWithFont:(UIFont *)font;

- (CGSize)bmSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (CGSize)bmSizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)size;

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           textColor:(UIColor *)textColor
              shadow:(NSShadow *)shadow
          actualSize:(CGSize *)actualSize;

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)textAlignment
          actualSize:(CGSize *)actualSize;

- (void)bmDrawInRect:(CGRect)rect
            withFont:(UIFont *)font
       lineBreakMode:(NSLineBreakMode)lineBreakMode
           alignment:(NSTextAlignment)textAlignment
           textColor:(UIColor *)textColor
              shadow:(NSShadow *)shadow
          actualSize:(CGSize *)actualSize;

- (void)bmDrawAtPoint:(CGPoint)point withFont:(UIFont *)font textColor:(UIColor *)textColor shadow:(NSShadow *)shadow actualSize:(CGSize *)actualSize;
- (void)bmDrawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode actualSize:(CGSize *)actualSize;

@end
