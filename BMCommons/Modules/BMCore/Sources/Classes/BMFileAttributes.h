//
//  BMFileAttributes.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMFileAttributes : BMCoreObject

@property (assign) BOOL pinned;
@property (nullable, strong) NSDate *modificationDate;
@property (assign) long long fileSize;
@property (strong) NSString *filePath;
@property (assign) NSTimeInterval expirationTimeInterval;

+ (instancetype)fileAttributesForFileAtPath:(NSString *)filePath fileSize:(long long)fileSize modificationDate:(nullable NSDate *)modificationDate pinned:(BOOL)pinned expirationTimeInterval:(NSTimeInterval)expirationTimeInterval;

- (BOOL)isExpiredWithInterval:(NSTimeInterval)expirationInterval;

- (BOOL)isExpired;

@end

NS_ASSUME_NONNULL_END
