//
//  NSUserDefaults+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (BMCommons)

/**
 * Safely sets the object for the specified key, ignoring nil key and/or value.
 */
- (void)bmSafeSetObject:(nullable id)object forKey:(nullable NSString *)key;

@end

NS_ASSUME_NONNULL_END