//
//  BMImageHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/09/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//


#import <BMCommons/BMImageHelper.h>

#if TARGET_OS_IPHONE
#import "UIImageToJPEGDataTransformer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

//#import "EXF.h"

#define INTERPOLATION_QUALITY kCGInterpolationDefault

@interface BMImageHelper(Private)

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);

@end

#endif


@implementation BMImageHelper

#if TARGET_OS_IPHONE

+ (UIImage *)scaleImage:(UIImage *)theImage toSize:(CGSize)imageSize {
	UIImage *newImage;
	if ((imageSize.width > 0 && imageSize.height > 0) &&
		(imageSize.width != theImage.size.width || imageSize.height != theImage.size.height)
		) {
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
		[theImage drawInRect:CGRectMake(0,0,imageSize.width,imageSize.height)];
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		newImage = theImage;
	}
	return newImage;
}

+ (UIImage *)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius {
	//create a context to do our clipping in
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	
	//Rounded corners
	CGContextBeginPath(currentContext);
    addRoundedRectToPath(currentContext, clippedRect, cornerRadius, cornerRadius);
    CGContextClosePath(currentContext);
    CGContextClip(currentContext);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	[imageToCrop drawInRect:drawRect];
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

+ (UIImage *)scaleImage:(UIImage *)imageToCrop toSize:(CGSize)size withCornerRadius:(CGFloat)cornerRadius {
	//create a context to do our clipping in
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(currentContext, INTERPOLATION_QUALITY);
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, size.width, size.height);
	
	//Rounded corners
	CGContextBeginPath(currentContext);
    addRoundedRectToPath(currentContext, clippedRect, cornerRadius, cornerRadius);
    CGContextClosePath(currentContext);
    CGContextClip(currentContext);
	
	
	CGFloat widthRatio = size.width / imageToCrop.size.width;
	CGFloat heightRatio = size.height / imageToCrop.size.height;
	CGFloat scaleRatio = MAX(widthRatio, heightRatio);
	
	CGFloat newWidth = scaleRatio * imageToCrop.size.width;
	CGFloat newHeight = scaleRatio * imageToCrop.size.height; 
	
	CGFloat offsetX = (size.width - newWidth)/2;
	CGFloat offsetY = (size.height - newHeight)/2;
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(offsetX,
								 offsetY,
								 newWidth,
								 newHeight);
	
	[imageToCrop drawInRect:drawRect];
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

#endif

@end

#if TARGET_OS_IPHONE

@implementation BMImageHelper(Private)

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0.0f || ovalHeight == 0.0f) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextRestoreGState(context);
}


@end

#endif

@implementation BMImageHelper(ThreadSafe)

#if TARGET_OS_IPHONE

+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(NSInteger)maxResolution orientation:(UIImageOrientation)orient scale:(CGFloat)scale {
    
    if (scale == 0.0f) {
        scale = [UIScreen mainScreen].scale;
    }
    
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
    
    width *= scale;
    height *= scale;
	
	BOOL rescale = NO;
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > maxResolution || height > maxResolution) {
		rescale = YES;
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = maxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = maxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(width, height);
	CGFloat boundHeight;
	switch(orient) {
            
		case UIImageOrientationUp: //EXIF = 1
			if (!rescale) {
				//nothing to do: just return original image
				return image;
			}
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		default:
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invalid image orientation" userInfo:nil] raise];
			
	}
	
	size_t w = (size_t)bounds.size.width;
	size_t h = (size_t)bounds.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate (NULL,
												  w,
												  h,
												  CGImageGetBitsPerComponent(imgRef),
												  4 * w,
												  colorSpace,
												  (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	
	CGContextSetInterpolationQuality(context, INTERPOLATION_QUALITY);
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
	
	CGImageRef imgRefCopy = CGBitmapContextCreateImage(context);
	UIImage *imageCopy = [UIImage imageWithCGImage:imgRefCopy scale:scale orientation:UIImageOrientationUp];
	
	CGImageRelease(imgRefCopy);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	return imageCopy;
}


//Alternative implementation for scaleAndRotateImage, gives better results
+ (UIImage *)scaleAndRotateImage2:(UIImage *)sourceImage maxResolution:(NSInteger)maxResolution {
	
	if (sourceImage == nil) {
		return nil;
	}
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = maxResolution;
	CGFloat targetHeight = maxResolution;
	CGFloat scaleFactor = 0.0;
	
	CGFloat widthFactor = targetWidth / width;
	CGFloat heightFactor = targetHeight / height;
	
	if (widthFactor > heightFactor) {
		scaleFactor = heightFactor; // scale to fit height
	} else {
		scaleFactor = widthFactor; // scale to fit width
	}
	
	CGFloat scaledWidth  = width * scaleFactor;
	CGFloat scaledHeight = height * scaleFactor;
	
	targetWidth = scaledWidth;
	targetHeight = scaledHeight;
	
	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
	}
	
	CGContextRef bitmap;
	
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, (int)targetWidth, (int)targetHeight, CGImageGetBitsPerComponent(imageRef), 4 * (int)targetWidth, colorSpaceInfo, bitmapInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, (int)targetHeight, (int)targetWidth, CGImageGetBitsPerComponent(imageRef), 4 * (int)targetHeight, colorSpaceInfo, bitmapInfo);
		
	}
	CGContextSetInterpolationQuality(bitmap, INTERPOLATION_QUALITY);
	
	// In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the thumbnail point
	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
		CGFloat oldScaledWidth = scaledWidth;
		scaledWidth = scaledHeight;
		scaledHeight = oldScaledWidth;
		
		CGContextRotateCTM (bitmap, M_PI/2);
		CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
		CGFloat oldScaledWidth = scaledWidth;
		scaledWidth = scaledHeight;
		scaledHeight = oldScaledWidth;
		
		CGContextRotateCTM (bitmap, -M_PI/2);
		CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
		// NOTHING
	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
		CGContextRotateCTM (bitmap, -M_PI);
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, scaledWidth, scaledHeight), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	CGColorSpaceRelease(colorSpaceInfo);
	
	return newImage;
}

+ (UIImage *)scaleImage:(UIImage *)image maxResolution:(NSInteger)maxResolution {
	return [BMImageHelper scaleAndRotateImage:image maxResolution:maxResolution orientation:UIImageOrientationUp scale:1.0f];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(NSInteger)maxResolution {
	return [BMImageHelper scaleAndRotateImage:image maxResolution:maxResolution orientation:image.imageOrientation scale:1.0f];
}

+ (UIImage *)rotateImage:(UIImage *)image {
	return [BMImageHelper scaleAndRotateImage:image maxResolution:1000000];
}

+ (UIImage *)invertedImageFromImage:(UIImage *)sourceImage
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = sourceImage.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [sourceImage CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // perform the colour inversion
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    // and return
    return returnImage;
}

+ (UIImage*)imageFromImage:(UIImage *)source withBrightness:(CGFloat)brightnessFactor {
    
    if ( brightnessFactor == 0 ) {
        return source;
    }
    
    CGImageRef imgRef = [source CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return image;
    
}

+ (UIInterfaceOrientation)guessOrientationFromImage:(UIImage *)image {
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSUInteger minColoredXPixel, maxColoredXPixel, minColoredYPixel, maxColoredYPixel;
    
    minColoredXPixel = width;
    maxColoredXPixel = 0;
    minColoredYPixel = height;
    maxColoredYPixel = 0;
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = 0;
    NSUInteger count = width * height;
    
    CGFloat threshold = 1.0f/255.0f;
    
    for (NSUInteger ii = 0 ; ii < count ; ++ii) {
        NSUInteger y = ii/width;
        NSUInteger x = ii%width;
        
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        
        BOOL blackPixel = NO;
        if ((red < threshold && green < threshold && blue < threshold) || alpha < threshold) {
            blackPixel = YES;
        }
        
        if (!blackPixel) {
            minColoredXPixel = MIN(minColoredXPixel, x);
            maxColoredXPixel = MAX(maxColoredXPixel, x);
            minColoredYPixel = MIN(minColoredYPixel, y);
            maxColoredYPixel = MAX(maxColoredYPixel, y);
        }
        
        byteIndex += 4;
    }
    free(rawData);
    
    NSUInteger correctedWidth = maxColoredXPixel - minColoredXPixel + 1;
    NSUInteger correctedHeight = maxColoredYPixel - minColoredYPixel + 1;
    
    float correctedWidthRatio = 1.0f - ((float)correctedWidth)/((float)width);
    float correctedHeightRatio = 1.0f - ((float)correctedHeight)/((float)height);
    
    float consistencyThreshold = 0.1f; //How much of the image is allowed to be black on the other axis
    
    BOOL consistent = correctedHeight > 1 && correctedWidth > 1 && (correctedWidthRatio < consistencyThreshold || correctedHeightRatio < consistencyThreshold);
    
    if (!consistent) {
        correctedHeight = height;
        correctedWidth = width;
    }
    
    if (correctedWidth > correctedHeight) {
        if (UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)image.imageOrientation)) {
            return (UIInterfaceOrientation)image.imageOrientation;
        } else {
            return UIInterfaceOrientationLandscapeLeft;
        }
    } else if (correctedHeight > correctedWidth) {
        if (UIInterfaceOrientationIsPortrait((UIInterfaceOrientation)image.imageOrientation)) {
            return (UIInterfaceOrientation)image.imageOrientation;
        } else {
            return UIInterfaceOrientationPortrait;
        }
    } else {
        return (UIInterfaceOrientation)image.imageOrientation;
    }
}

+ (UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL {
    UIImage *theImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    theImage = [[UIImage alloc] initWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    
    return theImage;
}

+ (void)saveAndScaleImage:(UIImage *)image withMaxResolution:(NSInteger)maxResolution target:(id)target selector:(SEL)selector {
    [self saveAndScaleImage:image withMaxResolution:maxResolution target:target selector:selector targetSize:nil];
}

+ (void)saveAndScaleImage:(UIImage *)image withMaxResolution:(NSInteger)maxResolution target:(id)target selector:(SEL)selector targetSize:(CGSize *)targetSize {
	@autoreleasepool {
        NSData *data = nil;
        if (image) {
            UIImageToJPEGDataTransformer *transformer = [UIImageToJPEGDataTransformer new];
            NSDate *start = [NSDate date];
            UIImage *scaledImage = [self scaleAndRotateImage:image maxResolution:maxResolution];
            LogTrace(@"Scaling time: %f", [[NSDate date] timeIntervalSinceDate:start]);
            
            start = [NSDate date];
            
            data = [transformer transformedValue:scaledImage];
            
            
            LogTrace(@"Transformation time: %f", [[NSDate date] timeIntervalSinceDate:start]);
            LogTrace(@"Image size: %f, %f", image.size.width, image.size.height);
            LogTrace(@"Scaled image size: %f, %f", scaledImage.size.width, scaledImage.size.height);
            if (targetSize) {
                *targetSize = scaledImage.size;
            }
        }
        
        if (![target respondsToSelector:@selector(isDeleted)] || ![target performSelector:@selector(isDeleted)]) {
            [target performSelectorOnMainThread:selector withObject:data waitUntilDone:YES];
        }
    }
}

#endif

@end
