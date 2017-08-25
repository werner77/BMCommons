//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Array which maintains sorting order upon adding/insertion of objects using the specified comparator/sortDescriptors/sortSelector in this order of precedence.
 */
@interface BMSortedArray<ObjectType> : NSMutableArray<ObjectType>

/**
 * Set to sort using the specified comparator, highest precedence
 */
@property (nullable, nonatomic, copy) NSComparator comparator;

/**
 * Set to sort using the specified array of sort descriptors, medium precedence
 */
@property (nullable, nonatomic, strong) NSArray *sortDescriptors;

/**
 * Set to sort using the specified sort selector, lowest precedence
 */
@property (nullable, nonatomic, assign) SEL sortSelector;

@end

NS_ASSUME_NONNULL_END