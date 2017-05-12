//
// Created by Werner Altewischer on 12/05/2017.
//

#import <Foundation/Foundation.h>

/**
 * A thread safe mutable array that maintains weak references to the objects being stored.
 *
 * It safely removes deallocated objects from the array automatically.
 */
@interface BMWeakMutableArray : NSMutableArray

/**
 * Perform the specified block within a synchronization lock to protect the array from being modified by a background thread.
 *
 * @param block
 * @return
 */
- (id)safelyPerformBlock:(id (^)(BMWeakMutableArray *))block;

@end