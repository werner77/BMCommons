//
//  NSSet+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet (BMCommons)

@end

@interface NSMutableSet(BMCommons)

/**
 * Safely adds an object to the set, ignoring null objects without throwing an exception.
 */
- (void)bmSafeAddObject:(nullable id)object;

@end

@interface NSMutableOrderedSet(BMCommons)

/**
 * Safely adds an object to the set, ignoring null objects without throwing an exception.
 */
- (void)bmSafeAddObject:(nullable id)object;

@end

NS_ASSUME_NONNULL_END

