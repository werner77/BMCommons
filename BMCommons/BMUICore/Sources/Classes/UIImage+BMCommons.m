//
//  UIImage+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 06/09/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "UIImage+BMCommons.h"
#import "NSData+BMCommons.h"

@implementation UIImage (BMCommons)

static BOOL decodeJPEGOnLoad = YES;
static BOOL decodePNGOnLoad = YES;

+ (void)setBMDecodeJPEGOnLoad:(BOOL)b {
    @synchronized([UIImage class]) {
        decodeJPEGOnLoad = b;
    }
}

+ (BOOL)isBMDecodeJPEGOnLoad {
    @synchronized([UIImage class]) {
        return decodeJPEGOnLoad;
    }
}

+ (void)setBMDecodePNGOnLoad:(BOOL)b {
    @synchronized([UIImage class]) {
        decodePNGOnLoad = b;
    }
}

+ (BOOL)isBMDecodePNGOnLoad {
    @synchronized([UIImage class]) {
        return decodePNGOnLoad;
    }
}


+ (UIImage *)bmImageWithData:(NSData *)data {
    UIImage *theImage = nil;
    
    BOOL decodeJPEG = [self isBMDecodeJPEGOnLoad];
    BOOL decodePNG = [self isBMDecodePNGOnLoad];
    
    BOOL isJPEG = NO;
    BOOL isPNG = NO;
    
    if ((decodeJPEG && (isJPEG = [data bmIsJPGData])) || (decodePNG && (isPNG = [data bmIsPNGData]))) {
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
        
        CGImageRef newImage = NULL;
        CGBitmapInfo bitmapInfo;
        if (isJPEG) {
            newImage = CGImageCreateWithJPEGDataProvider(dataProvider,
                                                         NULL, NO,
                                                         kCGRenderingIntentDefault);
            bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst;
        } else if (isPNG) {
            newImage = CGImageCreateWithPNGDataProvider(dataProvider,
                                                         NULL, NO,
                                                         kCGRenderingIntentDefault);
            bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst;
        }
        
        if (newImage) {
            
            //////////
            // force DECODE
            const size_t width = CGImageGetWidth(newImage);
            const size_t height = CGImageGetHeight(newImage);
            
            const CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
            
            const CGContextRef context = CGBitmapContextCreate(
                                                               NULL, /* Where to store the data. NULL = don’t care */
                                                               width, height, /* width & height */
                                                               8, width * 4, /* bits per component, bytes per row */
                                                               colorspace, bitmapInfo);
            
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), newImage);
            CGImageRef drawnImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorspace);
            
            //////////
            theImage = [UIImage imageWithCGImage:drawnImage];
            
            if (drawnImage) {
                CGImageRelease(drawnImage);
            }
        }
        
        if (dataProvider) {
            CGDataProviderRelease(dataProvider);
        }
        
        if (newImage) {
            CGImageRelease(newImage);
        }
    } else {
        theImage = [UIImage imageWithData:data];
    }
    return theImage;
}


@end
