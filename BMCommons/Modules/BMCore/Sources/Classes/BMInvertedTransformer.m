//
//  BMInvertedTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMInvertedTransformer.h>
#import <BMCommons/BMCore.h>

@implementation BMInvertedTransformer {
@private
	NSValueTransformer *_transformer;
}

+ (BMInvertedTransformer *)invertedTransformer:(NSValueTransformer *)transformer {
	return [[BMInvertedTransformer alloc] initWithTransformer:transformer];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	//Not supported
	return nil;
}

- (id)init {
	return [self initWithTransformer:nil];
}

- (id)initWithTransformer:(NSValueTransformer *)theTransformer {
	if ((self = [super init])) {
		if (theTransformer == nil || ![[theTransformer class] allowsReverseTransformation]) {
			return nil;
		}
		_transformer = theTransformer;
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(_transformer);
}

- (id)transformedValue:(id)value {
	return [_transformer reverseTransformedValue:value];
}

- (id)reverseTransformedValue:(id)value {
	return [_transformer transformedValue:value];
}

@end
