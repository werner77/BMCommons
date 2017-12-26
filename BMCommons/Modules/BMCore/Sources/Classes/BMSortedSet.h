//
//  BMSortedSet.h
//  BMCommons
//
//  Created by Werner Altewischer on 25/12/2017.
//

#import <Foundation/Foundation.h>

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

@end
