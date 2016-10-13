//
//  BMChainedTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 06/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Value transformer that chains other transformers for both forward and reverse transformation.
 */
@interface BMChainedTransformer : NSValueTransformer

+ (instancetype)transformerWithChain:(NSArray *)transformerChain;

/**
 * Array of NSValueTransformer implementations to use in the specified order.
 */
@property (nonatomic, strong) NSArray *transformerChain;

@end
