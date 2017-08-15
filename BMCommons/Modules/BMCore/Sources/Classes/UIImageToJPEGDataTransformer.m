//
//  UIImageToJPEGDataTransformer.m
//  BMCommons
//
//  Created by W. Altewischer on 7/13/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "UIImageToJPEGDataTransformer.h"

#define QUALITY_FACTOR 0.8

@implementation UIImageToJPEGDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	if (value == nil) return nil;

#if TARGET_OS_IPHONE
	UIImage *image = value;
	NSData *imageData = UIImageJPEGRepresentation(image, QUALITY_FACTOR);
	return imageData;
#else
    return nil;
#endif
}

- (id)reverseTransformedValue:(id)value {
#if TARGET_OS_IPHONE
	if (value == nil) return nil;
	UIImage *image = [[UIImage alloc] initWithData:value];
	return image;
#else
    return nil;
#endif
}

@end
