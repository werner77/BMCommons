//
//  BMBlockValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^BMValueTransformerBlock)(id _Nullable value);

/**
 * Value transformer that uses a block for forward and reverse transformations.
 */
@interface BMBlockValueTransformer : NSValueTransformer

/**
 * Creates a value transformer with the specified forward transformation block.
 *
 * @param transformBlock The block
 */
+ (instancetype)valueTransformerWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock;

/**
 * Creates a value transformer with the specified forward and reverse transformation block.
 *
 * @param transformBlock The forward transformation block
 * @param reverseBlock The reverse transformation block
 */
+ (instancetype)valueTransformerWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock reverseTransformationBlock:(nullable BMValueTransformerBlock)reverseBlock;

- (instancetype)initWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock reverseTransformationBlock:(nullable BMValueTransformerBlock)reverseBlock;

/**
 * The forward transformation block
 */
@property (nonatomic, copy, nullable) BMValueTransformerBlock transformationBlock;

/**
 * The reverse transformation block
 */
@property (nonatomic, copy, nullable) BMValueTransformerBlock reverseTransformationBlock;

@end

NS_ASSUME_NONNULL_END
