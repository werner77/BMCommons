//
//  NSDictionary_DeepMutableCopy.h
//
//  Created by Matt Gemmell on 02/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DeepMutableCopy)

/**
 * Returns a deep mutable copy of the receiver by copying all the objects and keys in the receiver.
 */
- (NSMutableDictionary *)bmDeepMutableCopy;

@end
