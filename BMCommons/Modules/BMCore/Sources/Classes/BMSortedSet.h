//
//  BMSortedSet.h
//  BMCommons
//
//  Created by Werner Altewischer on 25/12/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Set which maintains sorting order according to the comparator, sortDescriptors or sortSelector set (in that order of precedence).
 */
@interface BMSortedSet : NSMutableSet

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

/**
 * Defaults to false. May be set to true if the comparator/sortDescriptors/sortSelector set are consistent
 * with the equals contract, which means that:
 *
 * ordering == NSOrderedSame if, and only if, equals == true.
 *
 * When this property is set to true, the remove operation will be more efficient:
 *
 * O(log(N)) instead of O(N).
 */
@property (nonatomic, assign, getter=isOrderingConsistentWithEquals) BOOL orderingConsistentWithEquals;

@end

NS_ASSUME_NONNULL_END
