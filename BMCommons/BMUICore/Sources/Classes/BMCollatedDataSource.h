//
// Created by Werner Altewischer on 16/12/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Datasource for use with an index.
 *
 * @see UILocalizedIndexedCollation
 */
@interface BMCollatedDataSource : NSObject

@property (nonatomic, readonly) UILocalizedIndexedCollation *collation;
@property (nonatomic, readonly) SEL stringSelector;

/**
 * Initializes with the supplied collation and stringSelector for ordering.
 *
 * @see UILocalizedIndexedCollation
 */
- (instancetype)initWithCollation:(UILocalizedIndexedCollation *)collation stringSelector:(SEL)stringSelector;

/**
 * Sets data which will be sorted and ordered into sections using the set collation and stringSelector which will be called on every object.
 */
- (void)setData:(NSArray *)data;

/**
 * Returns the sorted data for the supplied section.
 */
- (NSArray *)sortedDataForSection:(NSInteger)section;

/**
 * Returns the number of sections.
 */
- (NSUInteger)sectionCount;

/**
 * Returns the total number of objects within the datasource.
 */
- (NSUInteger)totalObjectCount;

/**
 * Returns the number of objects within the specified section.
 */
- (NSUInteger)objectCountForSection:(NSInteger)section;

/**
 * Returns the data corresponding to the specified indices.
 */
- (id)objectForItem:(NSInteger)item inSection:(NSInteger)section;

@end