//
//  BMImageHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/09/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMUICore.h>

/**
 UIImage helper methods. 
 
 Methods that are not in the ThreadSafe category are only safe to call from the main thread.
 */
@interface BMImageHelper : BMUICoreObject {

}

/**
 Scales an image to the specified size losing the aspect ratio (scales to fit) and an optional corner radius to produce a rounded image.
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size withCornerRadius:(CGFloat)cornerRadius;


/**
 Crops an image with the specified crop rectangle and optional corner radius in pixels.
 */
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius;

/**
 * Scales an image in a non-threadsafe manner. 
 
 The aspect ratio of the image is lost, it is scaled to fit.
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)imageSize;


@end

/**
 Thread safe methods which are callable from threads other than the main thread.
 */
@interface BMImageHelper(ThreadSafe)

/**
 * Thread safe implementation for scaling an image with the supplied max resolution and keeping the aspect ratio.
 
 Image is not rotated, OrientationUp is assumed.
 
 @param maxResolution The maximum amount of pixels in either the width or height dimension depending on which is larger.
 */
+ (UIImage *)scaleImage:(UIImage *)image maxResolution:(NSInteger)maxResolution;

/**
 * Scales and rotates the supplied image (to ImageOrientationUp) in a thread safe manner by keeping the aspect ratio.
 
 @param maxResolution The maximum amount of pixels in either the width or height dimension depending on which is larger.
 */
+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(NSInteger)maxResolution;

/**
 Rotates the image to ImageOrientationUp in a thread safe manner by keeping the aspect ratio.
 */
+ (UIImage *)rotateImage:(UIImage *)image;

/**
 Guesses the orientation of the supplied image.
 */
+ (UIInterfaceOrientation)guessOrientationFromImage:(UIImage *)image;

/**
 Inverts the colors of the image such that for RGB: r = 1.0 -r, g = 1.0 - g, b = 1.0 - b.
 */
+ (UIImage *)invertedImageFromImage:(UIImage *)sourceImage;

/**
 Adjusts the brightness of the supplied image with a factor such that r = r * (1 + factor), g = g * (1 + factor) and b = b * (1 + factor).
 */
+ (UIImage*)imageFromImage:(UIImage *)source withBrightness:(CGFloat)brightnessFactor;

/**
 Method which calls scaleAndRotateImage:maxResolution: and calls the specified selector on the specified target upon completion.
 */
+ (void)saveAndScaleImage:(UIImage *)image withMaxResolution:(NSInteger)maxResolution target:(id)target selector:(SEL)selector;

/**
 Method which calls scaleAndRotateImage:maxResolution: and calls the specified selector on the specified target upon completion.
 
 @param targetSize The resulting size of the image after the scale/rotate operation completes.
 */
+ (void)saveAndScaleImage:(UIImage *)image withMaxResolution:(NSInteger)maxResolution target:(id)target selector:(SEL)selector targetSize:(CGSize *)targetSize;

/**
 Extracts a thumbnail image to show for a video at the specified URL.
 */
+ (UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL;

@end
