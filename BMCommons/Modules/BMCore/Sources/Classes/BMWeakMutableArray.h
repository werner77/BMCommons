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

@end