//
//  BMFileBackedMutableArray.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMCache;

/**
 Mutable array which is backed by a temporary file to avoid memory issues for a big number of objects.
 
 All instances of this class use a shared BMCache instance to cache lookups which has a default memory limit set to 20 MB.
 */
@interface BMFileBackedMutableArray<ObjectType> : NSMutableArray<ObjectType>

/**
 The global cache used by all instances to cache lookups.
 */
+ (BMCache *)globalCache;

/**
 The size of the temporary file managed by this instance.
 */
- (unsigned long long)fileSize;

@end
