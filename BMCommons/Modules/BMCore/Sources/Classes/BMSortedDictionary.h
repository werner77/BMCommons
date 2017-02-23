//
// Created by Werner Altewischer on 22/10/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractMutableDictionary.h>

/**
 * Dictionary which maintains order by sorting the keys using the supplied comparator or sortDescriptors.
 */
@interface BMSortedDictionary<KeyType, ObjectType> : BMAbstractMutableDictionary<KeyType, ObjectType>

/**
 * Set to sort using the specified comparator, highest precedence
 */
@property (nonatomic, copy) NSComparator comparator;

/**
 * Set to sort using the specified array of sort descriptors, medium precedence
 */
@property (nonatomic, strong) NSArray *sortDescriptors;

/**
 * Set to sort using the specified sort selector, lowest precedence
 */
@property (nonatomic, assign) SEL sortSelector;

@end
