//
//  UIImage+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 06/09/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

@interface UIImage (BMCommons)

/**
 Optimized and thread safe version to construct a UIImage from NSData.
 */
+ (UIImage *)bmImageWithData:(NSData *)data;

/**
 If set to true (which is the default) JPEGs will be decoded and redrawn upon load which (if done in the background) will speed up image behavior during scrolling because the resulting image from bmImageWithData will be fully decoded already.
 */
+ (void)setBMDecodeJPEGOnLoad:(BOOL)b;
+ (BOOL)isBMDecodeJPEGOnLoad;

/**
 If set to true (which is the default) PNGs will be decoded and redrawn upon load which (if done in the background) will speed up image behavior during scrolling because the resulting image from bmImageWithData will be fully decoded already.
 */
+ (void)setBMDecodePNGOnLoad:(BOOL)b;
+ (BOOL)isBMDecodePNGOnLoad;


@end

#endif
