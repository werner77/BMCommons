//
//  BMNamedObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 07/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol declaring an object with has a name property.
 */
@protocol BMNamedObject<NSObject>

/**
 * The name for the object or null if not defined.
 */
- (nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END