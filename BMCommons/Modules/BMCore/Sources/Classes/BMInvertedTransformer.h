//
//  BMInvertedTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Wraps a NSValueTranformer by inverting it.
 
 Basically the transformedValue: method and reverseTransformedValue: methods are swapped of the NSValueTransformer which is supplied as argument to initWithTransformer:
 This class returns nil as transformedValueClass and returns YES for allowsReverseTransformation.
 */
@interface BMInvertedTransformer : NSValueTransformer {
@private
	NSValueTransformer *_transformer;
}

+ (BMInvertedTransformer *)invertedTransformer:(NSValueTransformer *)transformer;
- (id)initWithTransformer:(NSValueTransformer *)theTransformer;


@end
