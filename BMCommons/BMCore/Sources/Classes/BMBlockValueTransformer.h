//
//  BMBlockValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^BMValueTransformerBlock)(id value);

@interface BMBlockValueTransformer : NSValueTransformer

+ (instancetype)valueTransformerWithTransformationBlock:(BMValueTransformerBlock)transformBlock;
+ (instancetype)valueTransformerWithTransformationBlock:(BMValueTransformerBlock)transformBlock reverseTransformationBlock:(BMValueTransformerBlock)reverseBlock;

- (instancetype)initWithTransformationBlock:(BMValueTransformerBlock)transformBlock reverseTransformationBlock:(BMValueTransformerBlock)reverseBlock;

@property (nonatomic, copy) BMValueTransformerBlock transformationBlock;
@property (nonatomic, copy) BMValueTransformerBlock reverseTransformationBlock;

@end
