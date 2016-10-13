//
//  UIImageToPNGDataTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 27/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UIImageToPNGDataTransformer.h"


@implementation UIImageToPNGDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	if (value == nil) return nil;
	UIImage *image = value;
	NSData *imageData = UIImagePNGRepresentation(image);
	return imageData;
}

- (id)reverseTransformedValue:(id)value {
	if (value == nil) return nil;
	UIImage *image = [[UIImage alloc] initWithData:value];
	return image;
}

@end
