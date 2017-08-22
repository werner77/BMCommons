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

@interface BMBlockValueTransformer : NSValueTransformer

+ (instancetype)valueTransformerWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock;
+ (instancetype)valueTransformerWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock reverseTransformationBlock:(nullable BMValueTransformerBlock)reverseBlock;

- (instancetype)initWithTransformationBlock:(nullable BMValueTransformerBlock)transformBlock reverseTransformationBlock:(nullable BMValueTransformerBlock)reverseBlock;

@property (nonatomic, copy, nullable) BMValueTransformerBlock transformationBlock;
@property (nonatomic, copy, nullable) BMValueTransformerBlock reverseTransformationBlock;

@end

NS_ASSUME_NONNULL_END
