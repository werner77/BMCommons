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
	UIImage *image = value;
	NSData *imageData = UIImageJPEGRepresentation(image, QUALITY_FACTOR);
	return imageData;
}

- (id)reverseTransformedValue:(id)value {
	if (value == nil) return nil;
	UIImage *image = [[UIImage alloc] initWithData:value];
	return image;
}

@end
