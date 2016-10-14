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

@end