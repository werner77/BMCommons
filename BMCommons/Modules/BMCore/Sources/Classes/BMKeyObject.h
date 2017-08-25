//
//  BMKeyObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 02/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMKeyObject : BMCoreObject<NSCopying>

/**
 Implement to supply an array of properties that uniquely identify objects of this class.
 
 The properties supplied in this array are used for hash, isEqual: and copyWithZone: implementations.
 */
+ (NSArray *)keyProperties;

@end

NS_ASSUME_NONNULL_END
